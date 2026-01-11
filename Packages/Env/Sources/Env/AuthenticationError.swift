import Foundation

public enum AuthenticationError: LocalizedError {
    case noRefreshToken
    case invalidToken

    public var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available"
        case .invalidToken:
            return "Invalid authentication token"
        }
    }
}
