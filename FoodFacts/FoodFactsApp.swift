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

    var body: some View {
        TabView {
            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "list.number")
                }

            ScannerView()
                .tabItem {
                    Label("Scanner", systemImage: "barcode.viewfinder")
                }

            HistoryView()
                .environmentObject(historyViewModel)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
    }
}

#Preview {
    ContentView()
}
