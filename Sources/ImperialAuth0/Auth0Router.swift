import Vapor
import Foundation


public class Auth0Router : FederatedServiceRouter {
    public let baseURL : String
    public let tokens : FederatedServiceTokens
    public let callbackCompletion : (Request, String) throws -> (EventLoopFuture<ResponseEncodable>)
    public var scope : [String] = []
    public let callbackURL : String
    public let accessTokenURL : String
    public let service : OAuthService = .auth0

    private func serviceUrl(path : String) -> String {
        return self.baseURL.finished(with: "/") + path
    }

    public required init(callback : String, completion : @escaping (Request, String) throws -> (EventLoopFuture<ResponseEncodable>)) throws {
        let auth = try Auth0Auth()
        self.tokens = auth
        self.baseURL = "https://\(auth.domain)"
        self.accessTokenURL = baseURL.finished(with: "/") + "oauth/token"
        self.callbackURL = callback
        self.callbackCompletion = completion
    }

    public func authURL(_ request : Request) throws -> String {

        let stateValue = [ Int8 ].random(count: 16).base64
        let auth = try Auth0Auth()
        var components = URLComponents()
        components.scheme = "https"
        components.host = auth.domain
        components.path = "/authorize"
        components.queryItems = [
            clientIDItem,
            .init(name: "redirect_uri", value: auth.callbackURL),
            .init(name: "response_type", value: "code"),
            .init(name: "state", value: stateValue)
        ]

        guard let url = components.url else {
            throw Abort(.internalServerError)
        }

        return url.absoluteString
    }

//    public func fetchToken(from request: Request) throws -> EventLoopFuture<String> {
//        let code: String
//        if let queryCode: String = try request.query.get(at: "code") {
//            code = queryCode
//        } else if let error: String = try request.query.get(at: "error") {
//            throw Abort(.badRequest, reason: error)
//        } else {
//            throw Abort(.badRequest, reason: "Missing 'code' key in URL query")
//        }
//
//        let body = Auth0CallbackBody(clientId: self.tokens.clientID, clientSecret: self.tokens.clientSecret, code: code)
//
//        return try body.encode(to: request).flatMap(to: Response.self) { request in
//            guard let url = URL(string: self.accessTokenURL) else {
//                throw Abort(.internalServerError, reason: "Unable to convert String '\(self.accessTokenURL)' to URL")
//            }
//            request.http.method = .POST
//            request.http.url = url
//            return try request.make(Client.self).send(request)
//        }.flatMap(to: String.self) { response in
//            return response.content.get(String.self, at: ["access_token"])
//            // TODO: refresh_token, id_token, token_type ?
//        }
//    }

//    public func callback(_ request: Request) throws -> EventLoopFuture<Response> {
//        return try self.fetchToken(from: request).flatMap(to: ResponseEncodable.self) { accessToken in
//            let session = try request.session()
//
//            session.setAccessToken(accessToken)
//            try session.set("access_token_service", to: OAuthService.auth0)
//
//            return try self.callbackCompletion(request, accessToken)
//        }.flatMap(to: Response.self) { response in
//            return try response.encode(for: request)
//        }
//    }

    public func callbackBody(with code : String) -> ResponseEncodable {
        return Auth0CallbackBody(
                clientId: tokens.clientID,
                clientSecret: tokens.clientSecret,
//                grantType: "authorization_code",
                code: code
//                redirectUri: callbackURL,
//                scope: scope.joined(separator: " "
        )
    }
}
