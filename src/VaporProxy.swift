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
import Vapor

class VaporProxy {
    /* singleton instance of the VaporProxy class */
    static let shared = VaporProxy()
    
    var app = Vapor.Application()
    let port = 8585
    private var running = false
    
    /* returns true if the vapor app is running */
    func isRunning() -> Bool {
        return running
    }

    /* starts the vapor app that listens on the
        defined port. The port is used to connect
        to the app through this proxy class */
    func start() {
        guard !running else {
            print("Vapor app is already running, not starting it")
            return
        }

        let address = BindAddress.hostname("127.0.0.1", port: 8585)
        app.http.server.configuration.address = address

        DispatchQueue.global().async {
            do {
                self.running = true
                try self.app.run()
            } catch {
                print("Failed to start app: \(error)")
                self.running = false
            }
        }
    }
    
    /* handles api gateway requests and forwards them
        to the vapor app running on the defined port */
    func handle(request: APIGatewayRequest) async throws -> APIGatewayResponse {
        // perform an http request to the vapor app
        let client = HTTPClient()
        var url = "http://127.0.0.1:\(port)" + request.path
        var headers = HTTPHeaders()
        var body: HTTPClient.Body?

        let httpMethod = HTTPMethod(rawValue: request.requestContext.httpMethod)

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

        let httpRequest = try HTTPClient.Request(url: url, method: httpMethod, headers: headers, body: body)
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
