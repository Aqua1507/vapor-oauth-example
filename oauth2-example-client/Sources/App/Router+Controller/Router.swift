import Vapor

struct Router: RouteCollection {

   func boot(routes: RoutesBuilder) throws {
      routes.get("client-login", use: Controller().clientLogin)
      routes.get("callback", use: Controller().callback)
      routes.get(use: Controller().home)
      routes.get("protected-page", use: Controller().protectedPage)
      routes.get("refresh", use: Controller().refreshTokenPage)
      routes.get("client-logout", use: Controller().clientLogout)
   }
   
}
