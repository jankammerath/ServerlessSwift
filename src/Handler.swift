/* 
    Copyright 2023 Jan Kammerath

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

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
