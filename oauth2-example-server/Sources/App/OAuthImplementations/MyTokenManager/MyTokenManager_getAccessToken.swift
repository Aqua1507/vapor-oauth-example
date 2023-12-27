import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {

   /// Get Access Token for the token introspection
   func getAccessToken(_ accessToken: String) async throws -> VaporOAuth.AccessToken? {

#if DEBUG
         print("\n-----------------------------")
         print("MyTokenManager() \(#function)")
         print("-----------------------------")
         print("Parameter accessToken:: \(accessToken)")
         print("-----------------------------")
#endif

      let token: String?
      do {
         let jwt = try app.jwt.signers.verify(accessToken, as: MyAccessToken.self)
         token = jwt.jti
      } catch {
         token = accessToken
      }

      

      // Check in database if the access_token exists
      guard
         let token,
         let accessToken = try await MyAccessToken.query(on: app.db)
            //.filter(\.$tokenString == jwt.jti)
            .filter(\.$tokenString == token)
            .first()
      else {
         return nil
      }

      // Delete expired access tokens for this user
      if let id = accessToken.id {
         let expiredTokens = try await MyAccessToken
            .query(on: app.db)
            .filter(\.$userID == accessToken.userID)
            .filter(\.$expiryTime < accessToken.expiryTime)
            .filter(\.$id != id)
            .all()

#if DEBUG
         print("\n-----------------------------")
         print("MyTokenManager() \(#function)")
         print("-----------------------------")
         print("Count of expired tokens for this user: \(expiredTokens.count)")
         print("Those access tokens have been deleted.")
         print("-----------------------------")
#endif

         try await expiredTokens.delete(on: app.db)
      }

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager() \(#function)")
      print("-----------------------------")
      print("Database access token: \(accessToken)")
      print("-----------------------------")
#endif

      // Return token from the database
      return accessToken
   }


}
