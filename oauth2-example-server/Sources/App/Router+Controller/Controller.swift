import Vapor
import Leaf
import VaporOAuth
import Fluent

struct Controller {

   func signin(_ request: Request) async throws -> Response {

      let user = try request.auth.require(Author.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().signin()")
      print("-----------------------------")
      print("Credentials authenticator / Fluent:")
      print("\(user)")
      print("-----------------------------")
#endif

      // Log in OAuth user with credentials

      let oauth_user = OAuthUser(
            userID: user.id?.uuidString,
            username: user.username,
            emailAddress: "",
            password: user.password
         )

      request.auth.login(oauth_user)

      return request.redirect(to: "http://localhost:8090/oauth/login-forward")

   }


   func auth(_ request: Request) async throws -> ClientResponse {


      let state = request.session.data["state"] ?? ""
      let client_id = request.session.data["client_id"] ?? ""
      let scope = request.session.data["scope"] ?? ""
      let redirect_uri = request.session.data["redirect_uri"] ?? ""
      let csrfToken = request.session.data["CSRFToken"] ?? ""


#if DEBUG
      print("\n-----------------------------")
      print("Controller().signin()")
      print("-----------------------------")
      print("state: \(state)")
      print("client_id: \(client_id)")
      print("scope: \(scope)")
      print("redirect_uri: \(redirect_uri)")
      print("csrfToken: \(csrfToken)")
      print("-----------------------------")
#endif

      struct Temp: Content {
         let applicationAuthorized: Bool
         let csrfToken: String
      }

      let content = Temp(
         applicationAuthorized: true,
         csrfToken: csrfToken
      )

      let authorize = URI(string: "http://localhost:8090/oauth/authorize?client_id=\(client_id)&redirect_uri=\(redirect_uri)&response_type=code&scope=\(scope)&state=\(state)")

#if DEBUG
      print("\n-----------------------------")
      print("Controller().signin()")
      print("-----------------------------")
      print("url: \(authorize)")
      print("-----------------------------")
#endif

      let cookie = request.cookies["vapor-session"] ?? ""

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Cookie", "vapor-session=\(cookie.string)")
      )

#if DEBUG
      print("\n-----------------------------")
      print("Controller().signin()")
      print("-----------------------------")
      print("headers: \(headers)")
      print("uri: \(authorize)")
      print("content: \(content)")
      print("-----------------------------")
#endif

      let response =  try await request.client.post(authorize, headers: headers, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().signin()")
      print("-----------------------------")
      print("response: \(response.status)")
      print("-----------------------------")
#endif

      return response

   }




}
