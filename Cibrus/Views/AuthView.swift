//
//  AppleSignInView.swift
//  ElevenstoicMotivation
//
//  Sign in with Apple authentication view
//

import AuthenticationServices
import Env
import Models
import SwiftUI

struct AuthView: View {
    @Environment(AuthenticationManager.self) private var authManager
    @Environment(\.dismiss) var dismiss

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appleSignInCoordinator: AppleSignInCoordinator?

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Center Content
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Sign in to Cibrus and\nsecure your data")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        Text(
                            "Keep your subscription and settings even if you\nswitch to a new device, uninstall the app, or\nclear the app data"
                        )
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    }
                }

                Spacer()

                // MARK: - Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        startAppleSignIn()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.title3)

                            Text("Sign in with Apple")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .foregroundStyle(.white)
                    }

                    // Anonymous Sign In Button
                    Button(action: {
                        handleAnonymousSignIn()
                    }) {
                        HStack(spacing: 12) {
                            Image(
                                systemName:
                                    "person.crop.circle.badge.questionmark"
                            )
                            .font(.title3)

                            Text("Continue as Guest")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 24)

                // MARK: - Footer
                VStack(spacing: 8) {
                    Text("By continuing, I confirm that I agree to all")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)

                    Link(
                        "Terms & Conditions",
                        destination: URL(
                            string:
                                "https://docs.google.com/document/d/1cZ9khrXcmMfHn6lIGbnGjtAacqqh_xUivoGFKoaU1mk/edit?usp=sharing"
                        )!
                    )
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.blue)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.bottom, 20)
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .tint(.blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
    }

    // MARK: - Logic

    private func startAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [
            request
        ])

        appleSignInCoordinator = AppleSignInCoordinator { result in
            handleSignInWithApple(result: result)
        }

        controller.delegate = appleSignInCoordinator
        controller.performRequests()
    }

    private func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let appleIDCredential = authorization.credential
                    as? ASAuthorizationAppleIDCredential,
                let identityToken = appleIDCredential.identityToken,
                let tokenString = String(data: identityToken, encoding: .utf8)
            else {
                errorMessage = "Failed to get Apple ID token"
                return
            }

            isLoading = true
            Task {
                do {
                    try await authManager.signInWithApple(idToken: tokenString)
                } catch {
                    await MainActor.run {
                        errorMessage =
                            "Sign in failed: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }

        case .failure(let error):
            let authError = error as? ASAuthorizationError
            if authError?.code != .canceled {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
        }
    }

    private func handleAnonymousSignIn() {
        isLoading = true
        Task {
            do {
                try await authManager.signInAnonymously()
            } catch {
                await MainActor.run {
                    errorMessage =
                        "Anonymous sign in failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    var completion: (Result<ASAuthorization, Error>) -> Void

    init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        completion(.success(authorization))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        completion(.failure(error))
    }
}

#Preview {
    AuthView()
}
