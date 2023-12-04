import Vapor
import VaporAWSLambdaRuntime

let app = Application()

struct Pong: Content {
    let pong: String
}

app.get("ping") { (_) -> Pong in
    Pong(pong: "hello")
}

app.servers.use(.lambda)

try app.run()