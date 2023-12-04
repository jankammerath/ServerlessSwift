import AWSLambdaEvents
import AWSLambdaRuntime
import AsyncHTTPClient
import Vapor

struct HelloWorld: Content {
    let message: String
}

@main
struct APIGatewayProxyLambda: LambdaHandler {
    typealias Event = APIGatewayRequest
    typealias Output = APIGatewayResponse

    init(context: LambdaInitializationContext) async throws {
        print("Serverless Swift cold started!")

        Task {
            // instanciate the vapor application
            let vaporApp = Vapor.Application()

            // define the routes for the vapor app
            vaporApp.get { req in
                return HelloWorld(message: "Hello, world!")
            }

            // run the app locally, so we can proxy to it
            let vaporAddress = BindAddress.hostname("127.0.0.1", port: 8585)
            vaporApp.http.server.configuration.address = vaporAddress

            try? vaporApp.run()
        }
    }

    /*
        This handles the request from API Gateway and returns a response
        by executing the Vapor application and returning the json response
    */
    func handle(_ request: APIGatewayRequest, context: LambdaContext) async throws -> APIGatewayResponse {
        // perform an http request to the vapor app
        let client = HTTPClient()
        var url = "http://127.0.0.1:8585" + request.path
        var headers = HTTPHeaders()
        var body: HTTPClient.Body?

        print("Context http method is: " + request.Context.httpMethod)

        if let queryString = request.queryStringParameters {
            url += "?" + queryString.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        }

        if let bodyString = request.body {
            let bodyData = Data(bodyString.utf8)
            body = .byteBuffer(ByteBuffer(data: bodyData))
            headers.add(name: "Content-Length", value: "\(bodyData.count)")
            headers.add(name: "Content-Type", value: "application/json")
        }

        for (key, value) in request.headers {
            headers.add(name: key, value: value)
        }

        let httpRequest = try HTTPClient.Request(url: url, method: .POST, headers: headers, body: body)
        let response = try await client.execute(request: httpRequest).get()

        let bodyString = response.body!.getString(at: 0, length: response.body!.readableBytes)

        var gatewayResponse = APIGatewayResponse(statusCode: .init(code: response.status.code))
        gatewayResponse.body = bodyString
        for (key, value) in response.headers {
            gatewayResponse.headers?[key] = value
        }

        return gatewayResponse
    }
}
