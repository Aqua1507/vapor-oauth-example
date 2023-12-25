import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {

   /// Generate new Access Token in exchange for the Refresh Token
   func generateAccessToken(clientID: String, userID: String?, scopes: [String]?, expiryTime: Int) async throws -> VaporOAuth.AccessToken {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager().generateAccessToken()")
      print("-----------------------------")
      print("Parameters:")
      print("clientID: \(clientID)")
      print("userID: \(userID)")
      print("scopes: \(scopes)")
      print("expiryTime: \(expiryTime)")
      print("-----------------------------")
#endif

      let accessTokenUniqueId = UUID().uuidString

      // Expiry time 1 minutes for testing purposes
      let expiryTimeAccessToken = Date(timeIntervalSinceNow: TimeInterval(60))

      let jwt = try createJWT(
         subject: userID ?? "",
         expiration: expiryTimeAccessToken,
         issuer: "OAuth Server",
         audience: clientID,
         jti: accessTokenUniqueId,
         issuedAtTime: Date()
      )

      // Access Token for Database
      let accessToken = try createAccessToken(
         tokenString: accessTokenUniqueId,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: expiryTimeAccessToken
      )

      try await accessToken.save(on: app.db)

      // Access Token for Client: replace the token with the JWT
      accessToken.tokenString = jwt

      return accessToken

   }


}
