import Foundation
import Models
import RevenueCat
import SwiftUI

@available(macOS 14.0, *)
@MainActor
@Observable
public class SubscriptionManager {
    public static let shared = SubscriptionManager()

    public private(set) var status: SubscriptionStatus = .loading

    public private(set) var products: [SubscriptionProduct] = []

    public private(set) var isPurchasing = false

    public private(set) var isLoadingProducts = false

    private init() {}

    public func configure() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: "appl_FyesdYqbyoQsvbrJMCxQGKHIeAO")

        Task {
            await refreshSubscriptionStatus()
        }
    }

    public func fetchProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let offerings = try await Purchases.shared.offerings()

            guard let currentOffering = offerings.current else {
                status = .error("No subscription offerings available")
                return
            }

            products = currentOffering.availablePackages.compactMap { package in
                mapToSubscriptionProduct(package: package)
            }

            products.sort { product1, product2 in
                product1.storeProduct.price < product2.storeProduct.price
            }

        } catch {
            status = .error(error.localizedDescription)
        }
    }

    public func purchase(product: SubscriptionProduct) async throws {
        guard !isPurchasing else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await Purchases.shared.purchase(
                product: product.storeProduct
            )

            if result.userCancelled {
                throw SubscriptionError.userCancelled
            }

            await refreshSubscriptionStatus()

        } catch {
            if let purchaseError = error as? ErrorCode {
                throw SubscriptionError.purchaseFailed(
                    purchaseError.localizedDescription
                )
            }
            throw SubscriptionError.purchaseFailed(error.localizedDescription)
        }
    }

    public func restorePurchases() async throws {
        do {
            _ = try await Purchases.shared.restorePurchases()
            await refreshSubscriptionStatus()
        } catch {
            throw SubscriptionError.restoreFailed(error.localizedDescription)
        }
    }

    public func refreshSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateStatus(from: customerInfo)
        } catch {
            status = .error(error.localizedDescription)
        }
    }

    // MARK: - Private Helpers

    private func updateStatus(from customerInfo: CustomerInfo) {
        if let premiumEntitlement = customerInfo.entitlements[
            SubscriptionTier.premium.entitlementId
        ],
            premiumEntitlement.isActive
        {
            status = .subscribed(
                tier: .premium,
                expirationDate: premiumEntitlement.expirationDate,
                willRenew: premiumEntitlement.willRenew
            )
        } else {
            status = .free
        }
    }

    private func mapToSubscriptionProduct(package: Package)
        -> SubscriptionProduct?
    {
        let storeProduct = package.storeProduct

        var introOffer: SubscriptionProduct.IntroductoryOffer?
        if let introDiscount = storeProduct.introductoryDiscount {
            let period = formatSubscriptionPeriod(
                introDiscount.subscriptionPeriod
            )
            let periodUnitString = formatPeriodUnit(
                introDiscount.subscriptionPeriod.unit
            )
            introOffer = SubscriptionProduct.IntroductoryOffer(
                price: introDiscount.localizedPriceString,
                period: period,
                periodUnit: periodUnitString,
                cycles: introDiscount.numberOfPeriods
            )
        }

        var pricePerMonth: String?
        if storeProduct.subscriptionPeriod?.unit == .year {
            let monthlyPrice = storeProduct.price / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale =
                storeProduct.priceFormatter?.locale ?? Locale.current
            pricePerMonth = formatter.string(from: monthlyPrice as NSNumber)
        }

        return SubscriptionProduct(
            id: storeProduct.productIdentifier,
            title: storeProduct.localizedTitle,
            description: storeProduct.localizedDescription,
            price: storeProduct.localizedPriceString,
            pricePerMonth: pricePerMonth,
            introductoryOffer: introOffer,
            storeProduct: storeProduct
        )
    }
    
    private func formatSubscriptionPeriod(_ period: SubscriptionPeriod)
           -> String
       {
           let value = period.value
           let unit = period.unit

           switch unit {
           case .day:
               return value == 1 ? "day" : "\(value) days"
           case .week:
               return value == 1 ? "week" : "\(value) weeks"
           case .month:
               return value == 1 ? "month" : "\(value) months"
           case .year:
               return value == 1 ? "year" : "\(value) years"
           @unknown default:
               return "\(value) periods"
           }
       }

       private func formatPeriodUnit(_ unit: SubscriptionPeriod.Unit) -> String {
           switch unit {
           case .day:
               return "day"
           case .week:
               return "week"
           case .month:
               return "month"
           case .year:
               return "year"
           @unknown default:
               return "period"
           }
       }
}
