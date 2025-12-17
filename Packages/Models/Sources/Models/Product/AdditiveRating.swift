//
//  AdditiveRating.swift
//  Cibrus - Product Scanner
//
//  Created by Harro Krog on 29.11.25.
//
public struct AdditiveRating: Codable, Hashable {
    public let rating: String
    public let description: String
    public let numberOfAdditives: Int
    public let additives: [Additive]
    
    public init(rating: String, description: String, numberOfAdditives: Int, additives: [Additive]) {
        self.rating = rating
        self.description = description
        self.numberOfAdditives = numberOfAdditives
        self.additives = additives
    }
}

public struct Additive: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let description: String?
    public let risk: String?
    public let additiveTypeId: Int?
    public let additiveType: AdditiveType?
    public let additiveHealthRisks: [AdditiveHealthRiskRelation]?
    
    public init(id: Int, name: String, description: String?, risk: String?, additiveTypeId: Int?, additiveType: AdditiveType?, additiveHealthRisks: [AdditiveHealthRiskRelation]?) {
        self.id = id
        self.name = name
        self.description = description
        self.risk = risk
        self.additiveTypeId = additiveTypeId
        self.additiveType = additiveType
        self.additiveHealthRisks = additiveHealthRisks
    }
}

public struct AdditiveType: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let description: String?
    
    public init(id: Int, name: String, description: String?) {
        self.id = id
        self.name = name
        self.description = description
    }
}

public struct AdditiveHealthRiskRelation: Codable, Identifiable, Hashable {
    public let additiveId: Int
    public let healthRiskId: Int
    public let healthRisk: HealthRisk

    public var id: String { "\(additiveId)-\(healthRiskId)" }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(additiveId)
        hasher.combine(healthRiskId)
        hasher.combine(healthRisk)
    }

    public static func == (lhs: AdditiveHealthRiskRelation, rhs: AdditiveHealthRiskRelation) -> Bool {
        lhs.additiveId == rhs.additiveId && lhs.healthRiskId == rhs.healthRiskId && lhs.healthRisk == rhs.healthRisk
    }
    
    public init(additiveId: Int, healthRiskId: Int, healthRisk: HealthRisk) {
        self.additiveId = additiveId
        self.healthRiskId = healthRiskId
        self.healthRisk = healthRisk
    }
}

public struct HealthRisk: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

