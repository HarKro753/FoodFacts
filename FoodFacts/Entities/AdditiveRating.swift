//
//  AdditiveRating.swift
//  FoodFacts
//
//  Created by Harro Krog on 12.11.25.
//

import Foundation

struct AdditiveRating: Codable, Hashable {
    let rating: String
    let description: String
    let numberOfAdditives: Int
    let additives: [Additive]
}

struct Additive: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let risk: String?
    let additiveTypeId: Int?
    let additiveType: AdditiveType?
    let additiveHealthRisks: [AdditiveHealthRiskRelation]?
}

struct AdditiveType: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
}

struct AdditiveHealthRiskRelation: Codable, Identifiable, Hashable {
    let additiveId: Int
    let healthRiskId: Int
    let healthRisk: HealthRisk

    var id: String { "\(additiveId)-\(healthRiskId)" }

    func hash(into hasher: inout Hasher) {
        hasher.combine(additiveId)
        hasher.combine(healthRiskId)
        hasher.combine(healthRisk)
    }

    static func == (lhs: AdditiveHealthRiskRelation, rhs: AdditiveHealthRiskRelation) -> Bool {
        lhs.additiveId == rhs.additiveId && lhs.healthRiskId == rhs.healthRiskId && lhs.healthRisk == rhs.healthRisk
    }
}

struct HealthRisk: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}
