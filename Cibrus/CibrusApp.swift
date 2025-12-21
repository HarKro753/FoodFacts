//
//  FoodFactsApp.swift
//  FoodFacts
//
//  Created by Harro Krog on 09.11.25.
//

import Env
import SwiftUI

@main
struct FoodFactsApp: App {
    @State private var rankingManager = RankingManager()
    @State private var searchManager = SearchManager()
    @State private var scannerManager = ScannerManager()
    @State private var labelProductsManager = LabelProductsManager()
    @State private var alternativesManager = AlternativesManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(rankingManager)
                .environment(searchManager)
                .environment(scannerManager)
                .environment(labelProductsManager)
                .environment(alternativesManager)
                .task {
                    await rankingManager.fetchFoodGroups()
                }
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 2

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Ranking", systemImage: "list.number", value: 1) {
                RankingView()
            }

            Tab("Scanner", systemImage: "barcode.viewfinder", value: 2) {
                ScannerView()
            }

            Tab(value: 3, role: .search) {
                SearchView()
            }
            .customizationID("search")
        }
    }
}

#Preview {
    ContentView()
        .environment(RankingManager())
        .environment(SearchManager())
        .environment(ScannerManager())
        .environment(LabelProductsManager())
        .environment(AlternativesManager())
}
