import Vapor
import Leaf

extension Controller {

   /// Token introspection flow when accessing a protected resource
   ///
   /// Endpoint /oauth/token is called with Basic Authentication to check if the access_token is valid
   /// - valid: show page
   /// - invalid: show unauthorized page
   ///
   func introspection(_ request: Request) async throws -> View {

      let access_token = request.cookies["access_token"]?.string
      let refresh_token = request.cookies["refresh_token"]?.string

      guard
         let access_token,
         let refresh_token
      else { 
         return try await request.view.render("unauthorized")
      }

      let introspection = try await introspection(accessToken: access_token, refreshToken: refresh_token, request)

      // Invalid access token
      guard
         let introspection,
         introspection.active == true
      else {
         return try await request.view.render("unauthorized")
      }

      return try await request.view.render("introspection-success")
   }

}
