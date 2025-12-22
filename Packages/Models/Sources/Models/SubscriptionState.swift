import Foundation
import RevenueCat

/// Represents the various subscription tiers available
public enum SubscriptionTier: String, CaseIterable {
  case free
  case premium

  public var entitlementId: String {
    switch self {
    case .free:
      return ""
    case .premium:
      return "premium"
    }
  }
}

/// Represents the current subscription status
public enum SubscriptionStatus: Equatable {
  case loading
  case free
  case subscribed(tier: SubscriptionTier, expirationDate: Date?, willRenew: Bool)
  case error(String)

  public var isPremium: Bool {
    if case .subscribed(let tier, _, _) = self, tier == .premium {
      return true
    }
    return false
  }

  public var isFree: Bool {
    if case .free = self {
      return true
    }
    return false
  }
}

/// Represents a subscription product with pricing and trial information
public struct SubscriptionProduct: Identifiable {
  public let id: String
  public let title: String
  public let description: String
  public let price: String
  public let pricePerMonth: String?
  public let introductoryOffer: IntroductoryOffer?
  public let storeProduct: StoreProduct

  public struct IntroductoryOffer {
    public let price: String
    public let period: String
    public let periodUnit: String
    public let cycles: Int

    public var isFreeTrialAvailable: Bool {
      price == "$0.00" || price.contains("Free")
    }

    public init(price: String, period: String, periodUnit: String, cycles: Int) {
      self.price = price
      self.period = period
      self.periodUnit = periodUnit
      self.cycles = cycles
    }
  }

  public init(
    id: String,
    title: String,
    description: String,
    price: String,
    pricePerMonth: String?,
    introductoryOffer: IntroductoryOffer?,
    storeProduct: StoreProduct
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.price = price
    self.pricePerMonth = pricePerMonth
    self.introductoryOffer = introductoryOffer
    self.storeProduct = storeProduct
  }
}

public enum SubscriptionError: LocalizedError {
  case purchaseFailed(String)
  case restoreFailed(String)
  case productsFetchFailed(String)
  case userCancelled

  public var errorDescription: String? {
    switch self {
    case .purchaseFailed(let message):
      return "Purchase failed: \(message)"
    case .restoreFailed(let message):
      return "Restore failed: \(message)"
    case .productsFetchFailed(let message):
      return "Failed to load products: \(message)"
    case .userCancelled:
      return "Purchase cancelled"
    }
  }
}
