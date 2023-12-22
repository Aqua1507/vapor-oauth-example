import Fluent
import FluentSQLiteDriver
import Vapor
import VaporOAuth
import Leaf

public func configure(_ app: Application) throws {

   //      =============================================================
   //      Debugging
   //      =============================================================

   app.logger.logLevel = .notice

   //      =============================================================
   //      PORT
   //      =============================================================

   app.http.server.configuration.port = 8090

   //      =============================================================
   //      Database
   //      =============================================================

   app.databases.use(.sqlite(.file("local-db")), as: .sqlite)
   app.sessions.use(.fluent)

   //      =============================================================
   //      Migrations
   //      =============================================================

   // Create Tables
   app.migrations.add(CreateAuthor())
   app.migrations.add(CreateAccessToken())
   app.migrations.add(CreateRefreshToken())
   app.migrations.add(SessionRecord.migration)
   app.migrations.add(CreateResourceServer())
   app.migrations.add(CreateClient())
   app.migrations.add(CreateAuthorizationCode())

   // Seed
   app.migrations.add(SeedAuthor())
   app.migrations.add(SeedResourceServer())
   app.migrations.add(SeedClient())

   try app.autoMigrate().wait()

   //      =============================================================
   //      OAuth / Session Middleware
   //      =============================================================

   app.middleware.use(app.sessions.middleware, at: .beginning)
   app.middleware.use(OAuthUserSessionAuthenticator())
   app.middleware.use(Author.sessionAuthenticator())


   //      =============================================================
   //      JWT
   //      =============================================================

   app.jwt.signers.use(.hs256(key: "test"))

   //      =============================================================
   //      Leaf
   //      =============================================================

   app.views.use(.leaf)

   //      =============================================================
   //      OAuth configuration
   //      =============================================================

   // authorizeHandler
   // Creates authorization code that can be exchanged with a token
   // via the tokenManager

   // codeManager
   // Manages authorization codes 

   // tokenManager
   // Manages everything related to access and refresh tokens

   // clientRetriever
   // Manages clients who can request authorization

   // resourceServerRetriever
   // Manages resource servers who can access introspection (token_info endpoint)

   app.lifecycle.use(
      OAuth2(
         codeManager: MyCodeManger(app: app),
         tokenManager: MyTokenManager(app: app),
         clientRetriever: MyClientRetriever(app: app),
         authorizeHandler: MyAuthorizeHandler(),
         validScopes: ["admin"],
         resourceServerRetriever: MyResourceServerRetriever(app: app),
         oAuthHelper: .remote(
            tokenIntrospectionEndpoint: "",
            client: app.client,
            resourceServerUsername: "",
            resourceServerPassword: ""
         )
      )
   )


   try Routes(app)

}
