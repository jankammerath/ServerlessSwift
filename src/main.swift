import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

// MARK: - Run Lambda

// FIXME: Use proper Event abstractions once added to AWSLambdaRuntime
@main
struct APIGatewayProxyLambda: LambdaHandler {
    typealias Event = APIGatewayRequest
    typealias Output = APIGatewayResponse

    init(context: LambdaInitializationContext) async throws {}

    func handle(_ request: APIGatewayRequest, context: LambdaContext) async throws -> APIGatewayResponse {
        context.logger.debug("hello, api gateway!")
        return APIGatewayResponse(statusCode: .ok, body: "hello, world!")
    }
}