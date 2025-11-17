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
    @StateObject private var historyViewModel = HistoryViewModel()
    @StateObject private var rankingViewModel = RankingViewModel()
    @StateObject private var alternativesViewModel = AlternativesViewModel()

    var body: some View {
        TabView {
            Tab("Ranking", systemImage: "list.number") {
                RankingView()
                    .environmentObject(rankingViewModel)
            }

//            Tab("Verlauf", systemImage: "clock") {
//                HistoryView()
//                    .environmentObject(historyViewModel)
//            }

            Tab("Scanner", systemImage: "barcode.viewfinder") {
                ScannerView()
            }

//            Tab("Alternativen", systemImage: "arrow.left.arrow.right") {
//                AlternativesView()
//                    .environmentObject(alternativesViewModel)
//            }

            Tab(role: .search) {
                SearchView()
            }
            .customizationID("search")
        }
    }
}

#Preview {
    ContentView()
}
