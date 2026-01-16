import Env
import Models
import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case getStarted = 0
    case age
    case gender
    case goals
    case allergies
}

@available(iOS 18.0, *)
public struct OnboardingFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationManager.self) private var authManager

    @State private var currentStep: OnboardingStep = .getStarted

    public init() {}

    @ViewBuilder
    private var currentScreen: some View {
        switch currentStep {
        case .getStarted:
            OnboardingGetStarted()
        case .age:
            GoalSelectionContent(
                headerTitle: "How old are you?",
                items: [
                    GoalItem("Under 18"),
                    GoalItem("18-24"),
                    GoalItem("25-34"),
                    GoalItem("35-44"),
                    GoalItem("45+"),
                ],
                isSingleSelection: true
            )
        case .gender:
            GoalSelectionContent(
                headerTitle: "How do you identify?",
                items: [
                    GoalItem("Male"),
                    GoalItem("Female"),
                    GoalItem("Non-binary"),
                    GoalItem("Prefer not to say"),
                ],
                isSingleSelection: true
            )
        case .goals:
            GoalSelectionContent(
                headerTitle: "What are your health goals?",
                items: [
                    GoalItem("Clear skin"),
                    GoalItem("Brain fog"),
                    GoalItem("Injury recovery"),
                    GoalItem("Deep sleep"),
                    GoalItem("Anti aging"),
                    GoalItem("Bloat-free"),
                    GoalItem("Executive energy"),
                ],
                isSingleSelection: false
            )
        case .allergies:
            TextFieldContent(
                headerTitle: "Do you have any allergies?",
                headerSubtitle:
                    "This helps us personalize your recommendations",
                placeholder: "e.g., nuts, dairy, gluten..."
            )
        }
    }

    private var continueButton: some View {
        Button(action: advance) {
            Text(buttonText)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.vertical, 16)
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showProgressHeader {
                    progressHeader
                }

                currentScreen
                    .transition(transitionForCurrentScreen)
                    .id(currentStep)
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .overlay(alignment: .bottom) {
                continueButton
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
        }
    }

    private var stepsWithProgress: [OnboardingStep] {
        [.age, .gender, .goals, .allergies]
    }

    private var showProgressHeader: Bool {
        stepsWithProgress.contains(currentStep)
    }

    private var progressHeader: some View {
        let currentIndex = stepsWithProgress.firstIndex(of: currentStep) ?? 0
        let progress =
            Double(currentIndex + 1) / Double(stepsWithProgress.count)

        return HStack(spacing: 16) {
            Image(systemName: "chevron.left")
                .foregroundColor(.secondary)
                .font(.system(size: 16))

            ProgressBar(progress: progress)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var isLastStep: Bool {
        currentStep == .allergies
    }

    private var buttonText: String {
        switch currentStep {
        case .getStarted:
            return "Get Started"
        case .allergies:
            return "Complete"
        default:
            return "Continue"
        }
    }

    private var transitionForCurrentScreen: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private func advance() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        if isLastStep {
            authManager.completeOnboarding()
        } else {
            if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1)
            {
                currentStep = nextStep
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingFlowView().withPreviewEnviroment()
}
