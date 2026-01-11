import Foundation
import Models
import Observation
import GraphQl

@available(iOS 15.0, *)
@MainActor
@Observable
public class AuthenticationManager {
    public static let shared = AuthenticationManager()

    private var isAuthenticated: Bool = false
    private var currentUser: User?
    private var sessionRestored: Bool = false
    private var hasCompletedOnboarding: Bool = false

    private let graphQLClient = GraphQLClient.shared

    private init() {
        self.isAuthenticated = SharedUserDefaults.isAuthenticated
        self.hasCompletedOnboarding = SharedUserDefaults.hasCompletedOnboarding
        if isAuthenticated {
            Task {
                await self.restoreSession()
            }
        } else {
            self.sessionRestored = true
        }
    }

    public func getIsAuthenticated() -> Bool {
        return isAuthenticated
    }

    public func getCurrentUser() -> User? {
        return currentUser
    }

    public func getSessionRestored() -> Bool {
        return sessionRestored
    }

    public func getHasCompletedOnboarding() -> Bool {
        return hasCompletedOnboarding
    }

    public func completeOnboarding() {
        self.hasCompletedOnboarding = true
        SharedUserDefaults.hasCompletedOnboarding = true
    }

    public func signInWithApple(idToken: String) async throws {
        let authPayload = try await graphQLClient.appleLogin(idToken: idToken)
        updatePersistentStorage(
            accessToken: authPayload.accessToken,
            refreshToken: authPayload.refreshToken
        )
        SharedUserDefaults.isGuest = false
        self.currentUser = authPayload.user
        self.isAuthenticated = true
        self.sessionRestored = true
    }

    public func signInAnonymously() async throws {
        let authPayload = try await graphQLClient.anonymousLogin()
        updatePersistentStorage(
            accessToken: authPayload.accessToken,
            refreshToken: authPayload.refreshToken
        )
        SharedUserDefaults.isGuest = true
        self.currentUser = authPayload.user
        self.isAuthenticated = true
        self.sessionRestored = true
    }

    public func refreshToken() async throws {
        guard let token = SharedUserDefaults.refreshToken else {
            throw AuthenticationError.noRefreshToken
        }

        let authPayload = try await graphQLClient.refreshToken(
            refreshToken: token
        )

        updatePersistentStorage(
            accessToken: authPayload.accessToken,
            refreshToken: authPayload.refreshToken
        )
        self.currentUser = authPayload.user
        self.isAuthenticated = true
    }

    public func signOut() async {
        let token = SharedUserDefaults.refreshToken
        self.clearLocalState()
        if let token = token {
            try? await graphQLClient.logout(refreshToken: token)
        }
    }

    private func restoreSession() async {
        do {
            try await self.refreshToken()
            self.sessionRestored = true
        } catch {
            print("⚠️ Session restoration failed: \(error)")
            clearLocalState()
            self.sessionRestored = true
        }
    }

    private func updatePersistentStorage(
        accessToken: String,
        refreshToken: String
    ) {
        SharedUserDefaults.accessToken = accessToken
        SharedUserDefaults.refreshToken = refreshToken
    }

    private func clearLocalState() {
        SharedUserDefaults.clearAuthentication()
        self.currentUser = nil
        self.isAuthenticated = false
        self.sessionRestored = false
    }
}
