//
//  chillersApp.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

@main
struct chillersApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onOpenURL { url in
                    // Handle deep links for Supabase auth
                    SupabaseManager.shared.client.auth.handle(url)
                }
        }
    }
}
