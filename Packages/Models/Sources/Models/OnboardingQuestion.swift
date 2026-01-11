//
//  OnboardingQuestion.swift
//  ElevenstoicMotivation
//
//  Data model for onboarding questions
//

import Foundation

public struct GoalItem: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let title: String

    public init(_ title: String) {
        self.title = title
    }
}

// MARK: - Question Types

public enum QuestionType: String, Sendable {
    case singleSelection = "single_selection"
    case multiSelection = "multi_selection"
    case textField = "text_field"
    case streak = "streak"
    case notification = "notification"
    case icon = "icon"
}

// MARK: - Onboarding Question Model

public struct OnboardingQuestion: Identifiable, Sendable {
    public let id: String
    public let type: QuestionType
    public let headerTitle: String
    public let headerSubtitle: String
    public let options: [GoalItem]? 
    public let placeholder: String? 

    public init(
        id: String,
        type: QuestionType,
        headerTitle: String,
        headerSubtitle: String,
        options: [GoalItem]? = nil,
        placeholder: String? = nil,
    ) {
        self.id = id
        self.type = type
        self.headerTitle = headerTitle
        self.headerSubtitle = headerSubtitle
        self.options = options
        self.placeholder = placeholder
    }
}
