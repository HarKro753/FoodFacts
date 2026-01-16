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
    @State private var authManager = AuthenticationManager.shared

    var body: some Scene {
        WindowGroup {
            OnboardingOrMainDecider()
                .environment(searchManager)
                .environment(scannerManager)
                .environment(authManager)
        }
    }
}

struct OnboardingOrMainDecider: View {
    @Environment(AuthenticationManager.self) private var authManager

    var body: some View {
        ZStack {
            if !authManager.getSessionRestored() {
                ProgressView()
                    .tint(.blue)
            } else if !authManager.getHasCompletedOnboarding() {
                OnboardingFlowView()
                    .transition(.opacity)
            } else if !authManager.getIsAuthenticated() {
                AuthView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authManager.getSessionRestored())
        .animation(.easeInOut, value: authManager.getHasCompletedOnboarding())
        .animation(.easeInOut, value: authManager.getIsAuthenticated())
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

extension View {
    func withPreviewEnviroment() -> some View {
        return
            self
            .environment(SearchManager())
            .environment(ScannerManager())
            .environment(AuthenticationManager.shared)
    }
}

#Preview {
    ContentView()
        .withPreviewEnviroment()
}
