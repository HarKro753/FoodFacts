//
//  SharedUserDefaults.swift
//  Env
//
//  Shared user defaults for app-wide settings
//

import Foundation

public enum SharedUserDefaults: Sendable {
    nonisolated(unsafe) static let suite = UserDefaults(
        suiteName: "group.com.cibrus.foodfacts"
    )!

    // MARK: - Access Token
    public static var accessToken: String? {
        get { suite.string(forKey: "accessToken") }
        set {
            suite.set(newValue, forKey: "accessToken")
            suite.set(newValue != nil, forKey: "isAuthenticated")
        }
    }

    // MARK: - Refresh Token
    public static var refreshToken: String? {
        get { suite.string(forKey: "refreshToken") }
        set { suite.set(newValue, forKey: "refreshToken") }
    }

    // MARK: - Authentication State
    public static var isAuthenticated: Bool {
        get { suite.bool(forKey: "isAuthenticated") }
        set { suite.set(newValue, forKey: "isAuthenticated") }
    }

    // MARK: - Guest State
    public static var isGuest: Bool {
        get { suite.bool(forKey: "isGuest") }
        set { suite.set(newValue, forKey: "isGuest") }
    }

    // MARK: - Onboarding State
    public static var hasCompletedOnboarding: Bool {
        get { suite.bool(forKey: "hasCompletedOnboarding") }
        set { suite.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    // MARK: - Clear Methods
    public static func clearAuthentication() {
        suite.removeObject(forKey: "accessToken")
        suite.removeObject(forKey: "refreshToken")
        suite.removeObject(forKey: "isAuthenticated")
        suite.removeObject(forKey: "isGuest")
    }
}
