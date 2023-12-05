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
import Vapor

/*
 You can do whatever you want in this file, just make sure
 to not instanciate the Vapor app, but instead use the instance
 from the VaporProxy by using "VaporProxy.shared.app"
*/

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
