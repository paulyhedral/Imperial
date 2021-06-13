import Vapor
import ImperialCore

public class Auth0Auth: FederatedServiceTokens {
    public static var domain: String = "AUTH0_DOMAIN"
    public static var idEnvKey: String = "AUTH0_CLIENT_ID"
    public static var secretEnvKey: String = "AUTH0_CLIENT_SECRET"
    public static var callbackURLEnvKey: String = "AUTH0_CALLBACK_URL"
    public var domain: String
    public var clientID: String
    public var clientSecret: String
    public var callbackURL: String

    public required init() throws {
        let domainError = ImperialError.missingEnvVar(Auth0Auth.domain)
        let idError = ImperialError.missingEnvVar(Auth0Auth.idEnvKey)
        let secretError = ImperialError.missingEnvVar(Auth0Auth.secretEnvKey)
        let callbackURLError = ImperialError.missingEnvVar(Auth0Auth.callbackURLEnvKey)

        self.domain = try Environment.get(Auth0Auth.domain).value(or: domainError)
        self.clientID = try Environment.get(Auth0Auth.idEnvKey).value(or: idError)
        self.clientSecret = try Environment.get(Auth0Auth.secretEnvKey).value(or: secretError)
        self.callbackURL = try Environment.get(Auth0Auth.callbackURLEnvKey).value(or: callbackURLError)
    }
}
