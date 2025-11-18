//
//  FoodFactsApp.swift
//  FoodFacts
//
//  Created by Harro Krog on 09.11.25.
//

import SwiftUI

@main
struct FoodFactsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    //    @StateObject private var historyViewModel = HistoryViewModel()
    @StateObject private var rankingViewModel = RankingViewModel()
    //    @StateObject private var alternativesViewModel = AlternativesViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var selectedTab = 2  // Start on Scanner tab

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Ranking", systemImage: "list.number", value: 1) {
                RankingView()
                    .environmentObject(rankingViewModel)
            }

            //            Tab("Verlauf", systemImage: "clock") {
            //                HistoryView()
            //                    .environmentObject(historyViewModel)
            //            }

            Tab("Scanner", systemImage: "barcode.viewfinder", value: 2) {
                ScannerView()
            }

            //            Tab("Alternativen", systemImage: "arrow.left.arrow.right") {
            //                AlternativesView()
            //                    .environmentObject(alternativesViewModel)
            //            }

            Tab(value: 3, role: .search) {
                SearchView()
                    .environmentObject(searchViewModel)
            }
            .customizationID("search")
        }
    }
}

#Preview {
    ContentView()
}
