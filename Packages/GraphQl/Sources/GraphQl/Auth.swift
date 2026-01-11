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

    private struct AppleLoginResponse: Decodable {
        struct AuthPayloadNode: Decodable {
            let accessToken: String
            let refreshToken: String
            let user: UserNode
        }
        let appleLogin: AuthPayloadNode
    }

    private struct AnonymousLoginResponse: Decodable {
        struct AuthPayloadNode: Decodable {
            let accessToken: String
            let refreshToken: String
            let user: UserNode
        }
        let anonymousLogin: AuthPayloadNode
    }

    private struct RefreshTokenResponse: Decodable {
        struct AuthPayloadNode: Decodable {
            let accessToken: String
            let refreshToken: String
            let user: UserNode
        }
        let refreshToken: AuthPayloadNode
    }

    private struct LogoutResponse: Decodable {
        struct LogoutPayloadNode: Decodable {
            let success: Bool
            let message: String
        }
        let logout: LogoutPayloadNode
    }

    private struct UserNode: Decodable {
        let id: Int
        let username: String?
        let email: String?
        let appleId: String?
        let isPremium: Bool
        let createdAt: String
        let updatedAt: String
        let lastLoginAt: String?
    }
    
    public func appleLogin(idToken: String) async throws -> AuthPayload {
        let queryString = """
            mutation AppleLogin {
                appleLogin(input: { idToken: "\(idToken)" }) {
                    accessToken
                    refreshToken
                    user {
                        id
                        username
                        email
                        appleId
                        isPremium
                        createdAt
                        updatedAt
                        lastLoginAt
                    }
                }
            }
            """

        let response: AppleLoginResponse = try await execute(query: queryString)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let createdAt = dateFormatter.date(from: response.appleLogin.user.createdAt),
              let updatedAt = dateFormatter.date(from: response.appleLogin.user.updatedAt) else {
            throw GraphQLClientError.invalidResponse
        }

        let lastLoginAt = response.appleLogin.user.lastLoginAt.flatMap { dateFormatter.date(from: $0) }

        let user = User(
            id: response.appleLogin.user.id,
            username: response.appleLogin.user.username,
            email: response.appleLogin.user.email,
            appleId: response.appleLogin.user.appleId,
            isPremium: response.appleLogin.user.isPremium,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastLoginAt: lastLoginAt
        )

        return AuthPayload(
            accessToken: response.appleLogin.accessToken,
            refreshToken: response.appleLogin.refreshToken,
            user: user
        )
    }

    public func anonymousLogin() async throws -> AuthPayload {
        let queryString = """
            mutation AnonymousLogin {
                anonymousLogin {
                    accessToken
                    refreshToken
                    user {
                        id
                        username
                        email
                        appleId
                        isPremium
                        createdAt
                        updatedAt
                        lastLoginAt
                    }
                }
            }
            """

        let response: AnonymousLoginResponse = try await execute(query: queryString)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let createdAt = dateFormatter.date(from: response.anonymousLogin.user.createdAt),
              let updatedAt = dateFormatter.date(from: response.anonymousLogin.user.updatedAt) else {
            throw GraphQLClientError.invalidResponse
        }

        let lastLoginAt = response.anonymousLogin.user.lastLoginAt.flatMap { dateFormatter.date(from: $0) }

        let user = User(
            id: response.anonymousLogin.user.id,
            username: response.anonymousLogin.user.username,
            email: response.anonymousLogin.user.email,
            appleId: response.anonymousLogin.user.appleId,
            isPremium: response.anonymousLogin.user.isPremium,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastLoginAt: lastLoginAt
        )

        return AuthPayload(
            accessToken: response.anonymousLogin.accessToken,
            refreshToken: response.anonymousLogin.refreshToken,
            user: user
        )
    }

    public func refreshToken(refreshToken: String) async throws -> AuthPayload {
        let queryString = """
            mutation RefreshToken {
                refreshToken(input: { refreshToken: "\(refreshToken)" }) {
                    accessToken
                    refreshToken
                    user {
                        id
                        username
                        email
                        appleId
                        isPremium
                        createdAt
                        updatedAt
                        lastLoginAt
                    }
                }
            }
            """

        let response: RefreshTokenResponse = try await execute(query: queryString)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let createdAt = dateFormatter.date(from: response.refreshToken.user.createdAt),
              let updatedAt = dateFormatter.date(from: response.refreshToken.user.updatedAt) else {
            throw GraphQLClientError.invalidResponse
        }

        let lastLoginAt = response.refreshToken.user.lastLoginAt.flatMap { dateFormatter.date(from: $0) }

        let user = User(
            id: response.refreshToken.user.id,
            username: response.refreshToken.user.username,
            email: response.refreshToken.user.email,
            appleId: response.refreshToken.user.appleId,
            isPremium: response.refreshToken.user.isPremium,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastLoginAt: lastLoginAt
        )

        return AuthPayload(
            accessToken: response.refreshToken.accessToken,
            refreshToken: response.refreshToken.refreshToken,
            user: user
        )
    }

    public func logout(refreshToken: String) async throws -> LogoutPayload {
        let queryString = """
            mutation Logout {
                logout(input: { refreshToken: "\(refreshToken)" }) {
                    success
                    message
                }
            }
            """

        let response: LogoutResponse = try await execute(query: queryString)

        return LogoutPayload(
            success: response.logout.success,
            message: response.logout.message
        )
    }
}
