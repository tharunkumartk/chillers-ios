//
//  ContentView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var bindableAppState = appState

        NavigationStack(path: $bindableAppState.navigationPath) {
            Group {
                if appState.isLoggedIn {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .navigationDestination(for: AppDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        
    }

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .onboarding:
            OnboardingView()
        case .main:
            MainTabView()
        case .login:
            LoginView()
        case .phoneEntry:
            LoginView()
        case .notificationPermission:
            NotificationPermissionView()
        case .parties:
            PartiesView()
        case .partyDetail(let party):
            PartyDetailView(party: party)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
