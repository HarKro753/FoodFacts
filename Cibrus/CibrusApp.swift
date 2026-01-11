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
    @State private var searchManager = SearchManager()
    @State private var scannerManager = ScannerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(searchManager)
                .environment(scannerManager)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Int = 2

    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
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

                ScannerView()
                    .tabItem {
                        Label("Scanner", systemImage: "barcode.viewfinder")
                    }
                    .tag(1)
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(2)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SearchManager())
        .environment(ScannerManager())
}
