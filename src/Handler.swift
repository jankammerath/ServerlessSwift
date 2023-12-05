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

        let app = VaporProxy.shared.app
        app.get { req in
            return HelloWorld(message: "Hello, world!")
        }
            
        VaporProxy.shared.start()
    }

    /*
        This handles the request from API Gateway and returns a response
        by executing the Vapor application and returning the json response
    */
    func handle(_ request: APIGatewayRequest, context: LambdaContext) async throws -> APIGatewayResponse {
        return try! await VaporProxy.shared.handle(request: request)
    }
}
