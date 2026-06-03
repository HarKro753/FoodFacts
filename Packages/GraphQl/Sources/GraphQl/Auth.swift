//
//  Auth.swift
//  GraphQL
//
//  Created by Harro Krog on 19.12.25.
//

import Foundation
import Models

@available(iOS 15.0, *)
public struct AuthPayload {
    public let accessToken: String
    public let refreshToken: String
    public let user: User

    public init(accessToken: String, refreshToken: String, user: User) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
    }
}

@available(iOS 15.0, *)
public struct LogoutPayload {
    public let success: Bool
    public let message: String

    public init(success: Bool, message: String) {
        self.success = success
        self.message = message
    }
}

@available(iOS 15.0, *)
extension GraphQLClient {
    public func appleLogin(idToken: String) async throws -> AuthPayload {
        _ = idToken
        return MockGraphQLStore.shared.authPayload()
    }

    public func anonymousLogin() async throws -> AuthPayload {
        MockGraphQLStore.shared.authPayload()
    }

    public func refreshToken(refreshToken: String) async throws -> AuthPayload {
        _ = refreshToken
        return MockGraphQLStore.shared.authPayload()
    }

    public func logout(refreshToken: String) async throws -> LogoutPayload {
        _ = refreshToken
        return MockGraphQLStore.shared.logoutPayload()
    }
}
