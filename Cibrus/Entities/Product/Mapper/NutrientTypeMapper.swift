//
//  NutrientTypeMapper.swift
//  Cibrus - Product Scanner
//
//  Created by Harro Krog on 29.11.25.
//


import Foundation
import SwiftUI

struct NutrientTypeMapper {
    static func icon(for nutrientType: String) -> String {
        switch nutrientType {
        // Basic Nutrients - Energy
        case "ENERGY_KCAL", "ENERGY":
            return "bolt.fill"
        case "ENERGY_FROM_FAT":
            return "bolt.circle.fill"

        // Fats
        case "FAT":
            return "circle.fill"
        case "SATURATED_FAT":
            return "exclamationmark.circle.fill"
        case "TRANS_FAT":
            return "exclamationmark.triangle.fill"
        case "UNSATURATED_FAT":
            return "circle.dotted"
        case "MONOUNSATURATED_FAT":
            return "circle.lefthalf.filled"
        case "POLYUNSATURATED_FAT":
            return "circle.righthalf.filled"
        case "OMEGA_3_FAT", "OMEGA3_FAT":
            return "drop.triangle.fill"
        case "OMEGA_6_FAT", "OMEGA6_FAT":
            return "drop.triangle"
        case "OMEGA_9_FAT", "OMEGA9_FAT":
            return "drop.circle.fill"

        // Essential Fatty Acids
        case "ALPHA_LINOLENIC_ACID":
            return "aqi.low"
        case "EICOSAPENTAENOIC_ACID":
            return "waveform.path.ecg"
        case "DOCOSAHEXAENOIC_ACID":
            return "waveform"
        case "LINOLEIC_ACID":
            return "aqi.medium"

        // Cholesterol
        case "CHOLESTEROL":
            return "heart.circle.fill"

        // Carbohydrates
        case "CARBOHYDRATES", "CARBS":
            return "square.fill"
        case "SUGARS", "SUGAR":
            return "sparkle"
        case "ADDED_SUGARS":
            return "plus.circle.fill"
        case "SUCROSE":
            return "square.grid.2x2.fill"
        case "GLUCOSE":
            return "square.circle.fill"
        case "FRUCTOSE":
            return "square.dotted"
        case "LACTOSE":
            return "square.lefthalf.filled"
        case "STARCH":
            return "square.stack.fill"

        // Fiber
        case "FIBER":
            return "leaf.fill"
        case "SOLUBLE_FIBER":
            return "leaf.circle.fill"
        case "INSOLUBLE_FIBER":
            return "leaf"

        // Proteins
        case "PROTEIN", "PROTEINS":
            return "flame.fill"

        // Salt & Sodium
        case "SALT":
            return "cube.fill"
        case "SODIUM":
            return "drop.fill"
        case "CHLORIDE":
            return "drop.circle"

        // Alcohol
        case "ALCOHOL":
            return "wineglass.fill"

        // Vitamins - Fat Soluble
        case "VITAMIN_A", "VITAMINA":
            return "sun.max.fill"
        case "VITAMIN_D", "VITAMIND":
            return "sun.min.fill"
        case "VITAMIN_E", "VITAMINE":
            return "shield.fill"
        case "VITAMIN_K", "VITAMINK":
            return "shield.lefthalf.filled"
        case "BETA_CAROTENE":
            return "sun.horizon.fill"

        // Vitamins - Water Soluble
        case "VITAMIN_C", "VITAMINC":
            return "star.fill"
        case "VITAMIN_B1", "VITAMINB1":
            return "star.circle.fill"
        case "VITAMIN_B2", "VITAMINB2":
            return "star.circle"
        case "VITAMIN_PP", "VITAMINPP":
            return "star.square.fill"
        case "VITAMIN_B6", "VITAMINB6":
            return "star.square"
        case "VITAMIN_B9", "VITAMINB9", "FOLATES":
            return "star.leadinghalf.filled"
        case "VITAMIN_B12", "VITAMINB12":
            return "star.slash.fill"
        case "BIOTIN":
            return "sparkles"
        case "PANTOTHENIC_ACID":
            return "star.bubble.fill"

        // Minerals - Major
        case "CALCIUM":
            return "cross.case.fill"
        case "PHOSPHORUS":
            return "diamond.fill"
        case "MAGNESIUM":
            return "hexagon.fill"
        case "POTASSIUM":
            return "bolt.heart.fill"

        // Minerals - Trace
        case "IRON":
            return "bolt.shield.fill"
        case "ZINC":
            return "shield.checkered"
        case "COPPER":
            return "circle.hexagonpath.fill"
        case "MANGANESE":
            return "hexagon"
        case "SELENIUM":
            return "shield.slash.fill"
        case "CHROMIUM":
            return "diamond"
        case "MOLYBDENUM":
            return "hexagon.lefthalf.filled"
        case "IODINE":
            return "drop.triangle.fill"

        // Fruits & Vegetables
        case "VEGETABLE_PERCANTAGE", "FRUITS_VEGETABLES_NUTS":
            return "carrot.fill"

        // Caffeine
        case "CAFFEINE":
            return "mug.fill"

        // Generic Categories
        case "VITAMINS":
            return "star.fill"
        case "MINERALS":
            return "sparkles"
        case "ADDITIVES":
            return "exclamationmark.triangle.fill"
        case "PRESERVATIVES":
            return "flask.fill"

        default:
            return "circle"
        }
    }
}
