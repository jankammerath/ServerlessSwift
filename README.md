# Serverless Swift with Vapor and AWS SAM

This is a boilerplate application that shows how to run a serverless Swift application on AWS Lambda using AWS SAM. The Lambda operates on Linux running on AWS Graviton2 CPUs with an arm64 architecture. It uses a local proxy to interact with the [Vapor](https://vapor.codes/) framework. This code is part of my article [Serverless Swift With Vapor On AWS Using AWS SAM And Lambda](https://medium.com/@jankammerath/serverless-swift-with-vapor-on-aws-using-aws-sam-and-lambda-3bd89bed5325). If you're interested in running Swift code on AWS Lambda, this may serve as boilerplate.

## How to use it yourself

You can simply work with the code in `App.swift` inside the `src` folder. The configuration is very simple. Once the Lambda starts, the `App()` function is called which you can use to setup Vapor and your routes. Whenver a request is sent to the Lambda function it'll forward it to the Vapor app using the VaporProxy class.

```swift
struct HelloWorld: Content {
    let message: String
}

/*
    This App() function is called in the Handler when it first
    initializes. Routes and any configuration should be done here.
    Make sure to retain the App() function or replace it in the Handler.
*/
func App() {
    // this is the Vapor app instance from the Vapor Proxy
    let app = VaporProxy.shared.app
    app.get { req in
        return HelloWorld(message: "Hello, world!")
    }
}
```

## Running locally

To run the application locally with AWS SAM, you can use the `sam-launch.sh` script or run it yourself. Make sure to build the application before trying to run or re-run it. 

```bash
make build
sam local start-api --template template.yaml
```

Note that the performance characteristics of running this application locally using AWS SAM is entirely different from running it on AWS. SAM will use approx 30-40% more memory than the binary will consume with the actual Lambda on AWS. The invocation of SAM will also take more time than it will when actually running on Lambda with API Gateway.

## Deploying to AWS

You can deploy the application to AWS using either AWS SAM or CloudFormation. With AWS SAM, you can simply use the `sam deploy --guided` command and SAM will guide you through the deployment of the app. If you want to use CloudFormation instead, you need to put the `bootstrap` binary in `bin/` into a zip file and upload it to the S3 bucket that you want to host the code on. The configuration of `AWS::Lambda::Function` is almost identical to `AWS::Serverless::Function`.

## Performance

The vapor integration curently uses the `AsyncHTTPClient` and thus the local [loopback](https://tldp.org/LDP/nag/node66.html) on the Lambda instance. Vapor is initialized when the Lambda container first starts making the cold start take around 800-900ms on a 128 MB arm64 container running Amazon Linux 2. There is no measurable performance impact on using the loopback adapter within the VaporProxy class that then sends the HTTP request to the vapor app running on port `8585`.

### Sample logs

The logs give an insight on the performance of the approx. 117 MB binary file within the Lambda. The Lambda cold start with the binary is a little less than 1 second. The log also shows how Vapor runs through the entire lifecycle of the Lambda and is reused for subsequent requests to the same Lambda container. The memory consumption of 39 MB on a 128 MB instance is perfectly in line with web frameworks of Vapor's scale (e.g. Go Gin). The logs do not show any reasonable performance impact of the usage of the loopback adapter in the VaporProxy class.

|   timestamp   |                                                                                 message                                                                                  |
|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1701787103739 | INIT_START Runtime Version: provided:al2.v27 Runtime Version ARN: arn:aws:lambda:eu-central-1::runtime:2314d913d88add4107e4119c38e7eff2379525a1b70c242c2fbbd5f44af167a2  |
| 1701787103873 | 2023-12-05T14:38:23+0000 info Lambda : [AWSLambdaRuntimeCore] lambda runtime starting with LambdaConfiguration                                                           |
| 1701787103873 | General(logLevel: info))                                                                                                                                                 |
| 1701787103873 | Lifecycle(id: 92791806392, maxTimes: 0, stopSignal: TERM)                                                                                                                |
| 1701787103873 | RuntimeEngine(ip: 127.0.0.1, port: 9001, requestTimeout: nil                                                                                                             |
| 1701787103911 | Serverless Swift cold started!                                                                                                                                           |
| 1701787103911 | 2023-12-05T14:38:23+0000 notice codes.vapor.application : [Vapor] Server starting on http://127.0.0.1:8585                                                               |
| 1701787103915 | START RequestId: e02bf583-11eb-44f2-8d98-07fc237d7e66 Version: $LATEST                                                                                                   |
| 1701787103971 | 2023-12-05T14:38:23+0000 info codes.vapor.application : request-id=1ECCFC3A-2850-48D5-AEF6-C2B5BC57F78E [Vapor] GET /                                                    |
| 1701787104050 | END RequestId: e02bf583-11eb-44f2-8d98-07fc237d7e66                                                                                                                      |
| 1701787104050 | REPORT RequestId: e02bf583-11eb-44f2-8d98-07fc237d7e66 Duration: 134.84 ms Billed Duration: 310 ms Memory Size: 128 MB Max Memory Used: 38 MB Init Duration: 174.16 ms   |
| 1701787107561 | START RequestId: efe792b1-e61c-4f0b-911c-9d9971ea8140 Version: $LATEST                                                                                                   |
| 1701787107562 | 2023-12-05T14:38:27+0000 info codes.vapor.application : request-id=BB06BD73-7FAE-4F72-A919-2FFEA78DA74F [Vapor] GET /                                                    |
| 1701787107571 | END RequestId: efe792b1-e61c-4f0b-911c-9d9971ea8140                                                                                                                      |
| 1701787107571 | REPORT RequestId: efe792b1-e61c-4f0b-911c-9d9971ea8140 Duration: 9.96 ms Billed Duration: 10 ms Memory Size: 128 MB Max Memory Used: 39 MB                               |
| 1701787108545 | START RequestId: 34be4e5f-6a3e-43d2-8abf-ab0d4d5393f5 Version: $LATEST                                                                                                   |
| 1701787108547 | 2023-12-05T14:38:28+0000 info codes.vapor.application : request-id=594AF1A0-BBDF-41A9-99B5-04D8036FAB83 [Vapor] GET /                                                    |
| 1701787108550 | END RequestId: 34be4e5f-6a3e-43d2-8abf-ab0d4d5393f5                                                                                                                      |
| 1701787108550 | REPORT RequestId: 34be4e5f-6a3e-43d2-8abf-ab0d4d5393f5 Duration: 4.41 ms Billed Duration: 5 ms Memory Size: 128 MB Max Memory Used: 39 MB                                |
| 1701787109485 | START RequestId: 98ae7cc5-519b-46cf-b40a-59db39132c84 Version: $LATEST                                                                                                   |
| 1701787109486 | 2023-12-05T14:38:29+0000 info codes.vapor.application : request-id=509365D5-C043-4689-A85A-1AB3B15E4265 [Vapor] GET /                                                    |
| 1701787109489 | END RequestId: 98ae7cc5-519b-46cf-b40a-59db39132c84                                                                                                                      |
| 1701787109489 | REPORT RequestId: 98ae7cc5-519b-46cf-b40a-59db39132c84 Duration: 3.87 ms Billed Duration: 4 ms Memory Size: 128 MB Max Memory Used: 39 MB                                |
| 1701787110266 | START RequestId: d8b21815-7be8-41df-b842-9f44aad27ccf Version: $LATEST                                                                                                   |
| 1701787110268 | 2023-12-05T14:38:30+0000 info codes.vapor.application : request-id=46EF492E-BA96-41B0-B0E2-A950F96FD601 [Vapor] GET /                                                    |
| 1701787110270 | END RequestId: d8b21815-7be8-41df-b842-9f44aad27ccf                                                                                                                      |
| 1701787110270 | REPORT RequestId: d8b21815-7be8-41df-b842-9f44aad27ccf Duration: 3.35 ms Billed Duration: 4 ms Memory Size: 128 MB Max Memory Used: 39 MB                                |
| 1701787110986 | START RequestId: 59d747ac-30fd-426f-801d-b2b49947672b Version: $LATEST                                                                                                   |
| 1701787110988 | 2023-12-05T14:38:30+0000 info codes.vapor.application : request-id=2F31B2B2-087E-4F37-84D7-85A9319FBFD1 [Vapor] GET /                                                    |
| 1701787110989 | END RequestId: 59d747ac-30fd-426f-801d-b2b49947672b                                                                                                                      |
| 1701787110989 | REPORT RequestId: 59d747ac-30fd-426f-801d-b2b49947672b Duration: 2.60 ms Billed Duration: 3 ms Memory Size: 128 MB Max Memory Used: 39 MB                                |
| 1701787111712 | START RequestId: e475820b-3d58-4c13-978d-33dfb8ab5643 Version: $LATEST                                                                                                   |
| 1701787111713 | 2023-12-05T14:38:31+0000 info codes.vapor.application : request-id=94ED794E-BCA4-4038-A775-5A08FE5CAE15 [Vapor] GET /                                                    |
| 1701787111714 | END RequestId: e475820b-3d58-4c13-978d-33dfb8ab5643                                                                                                                      |
| 1701787111714 | REPORT RequestId: e475820b-3d58-4c13-978d-33dfb8ab5643 Duration: 2.46 ms Billed Duration: 3 ms Memory Size: 128 MB Max Memory Used: 40 MB                                |
| 1701787126949 | START RequestId: f0acbc2c-942c-476e-8626-a91baebf2150 Version: $LATEST                                                                                                   |
| 1701787126950 | 2023-12-05T14:38:46+0000 info codes.vapor.application : request-id=43AE11AB-539B-41D7-B8D6-A54778181FC5 [Vapor] GET /                                                    |
| 1701787126969 | END RequestId: f0acbc2c-942c-476e-8626-a91baebf2150                                                                                                                      |
| 1701787126969 | REPORT RequestId: f0acbc2c-942c-476e-8626-a91baebf2150 Duration: 20.38 ms Billed Duration: 21 ms Memory Size: 128 MB Max Memory Used: 40 MB                              |
| 1701787127554 | START RequestId: 8d1b3dd6-dd75-43c1-987f-104a8214f3bc Version: $LATEST                                                                                                   |
| 1701787127555 | 2023-12-05T14:38:47+0000 info codes.vapor.application : request-id=C265146E-89A9-4D36-AB33-FED4A169994F [Vapor] GET /                                                    |
| 1701787127570 | END RequestId: 8d1b3dd6-dd75-43c1-987f-104a8214f3bc                                                                                                                      |
| 1701787127570 | REPORT RequestId: 8d1b3dd6-dd75-43c1-987f-104a8214f3bc Duration: 16.09 ms Billed Duration: 17 ms Memory Size: 128 MB Max Memory Used: 40 MB                              |