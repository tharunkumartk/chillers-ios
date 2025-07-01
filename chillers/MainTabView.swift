//
//  MainTabView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationView {
            TabView {
                ExploreView()
                    .tabItem {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                        Text("Confessions")
                    }
                
                HomeView()
                    .tabItem {
                        Image(systemName: "snowflake")
                        Text("Chillers")
                    }

                ProfileView()
                    .tabItem {
                        Image(systemName: "calendar.badge.plus")
                        Text("Events")
                    }
            }
            .navigationBarTitle("Chillers", displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle")
                        .font(.title)
                }
            )
            .onAppear {
                // Check current notification permission status when app appears
                Task {
                    await appState.checkNotificationPermissionStatus()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}