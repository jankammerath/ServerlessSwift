# Serverless Swift with Vapor and AWS SAM

This is a boilerplate application that shows how to run a serverless Swift application on AWS Lambda using AWS SAM. The Lambda operates on Linux running on AWS Graviton2 CPUs with an arm64 architecture. It uses a local proxy to interact with the [Vapor](https://vapor.codes/) framework. This code is part of my article [Serverless Swift With Vapor On AWS Using AWS SAM And Lambda](https://medium.com/@jankammerath/serverless-swift-with-vapor-on-aws-using-aws-sam-and-lambda-3bd89bed5325). If you're interested in running Swift code on AWS Lambda, this may serve as boilerplate.

## A note on Vapor

The vapor integration curently uses the `AsyncHTTPClient` and thus the local loopback on the Lambda instance. Also Vapor does not seem to be initialized when the Lambda cold starts, but with every invocation of the Lambda. That still needs fixing and testing. 

## Running locally

To run the application locally with AWS SAM, you can use the `sam-launch.sh` script or run it yourself. Make sure to build the application before trying to run or re-run it. 

```bash
make build
sam local start-api --template template.yaml
`
