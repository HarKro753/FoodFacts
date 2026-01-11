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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(rankingManager)
                .environment(searchManager)
                .environment(scannerManager)
                .environment(labelProductsManager)
                .task {
                    await rankingManager.fetchFoodGroups()
                }
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Int = 2

    var body: some View {
        if #available(iOS 18.0, *) {
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
        } else {
            TabView(selection: $selectedTab) {
                RankingView()
                    .tabItem {
                        Label("Ranking", systemImage: "list.number")
                    }
                    .tag(1)
                ScannerView()
                    .tabItem {
                        Label("Scanner", systemImage: "barcode.viewfinder")
                    }
                    .tag(2)
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(3)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(RankingManager())
        .environment(SearchManager())
        .environment(ScannerManager())
        .environment(LabelProductsManager())
}
