//
//  chillersApp.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil
    
    override init() {
        super.init()
        AppDelegate.instance = self
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Use the shared AppState instance to handle the token
        AppState.shared?.handleAPNDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle registration failure
        print("Failed to register for remote notifications: \(error)")
    }
}

@main
struct chillersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var appState: AppState
    
    init() {
        // Create AppState instance and set as shared
        let state = AppState()
        AppState.shared = state
        self._appState = State(initialValue: state)
    }
    
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
