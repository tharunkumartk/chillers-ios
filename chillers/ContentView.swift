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
                if appState.showSplashScreen {
                    SplashScreenView()
                } else if appState.isLoggedIn {
                    MainTabView()
                } else if !appState.hasSeenOnboardingIntro {
                    OnboardingView()
                } else {
                    LoginView()
                }
            }
            .navigationDestination(for: AppDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.navigationPath)
        
    }

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .passphrase:
            PassphraseView()
        case .waitlist:
            WaitlistView()
        case .onboarding:
            OnboardingView()
        case .onboardingBasicInfo:
            OnboardingBasicInfoView()
        case .onboardingPhotos:
            OnboardingPhotosView()
        case .onboardingPrompts:
            OnboardingPromptsView()
        case .main:
            MainTabView()
        case .login:
            LoginView()
        case .phoneEntry:
            LoginView()
        case .otpVerification(let phoneNumber):
            OTPVerificationView(phoneNumber: phoneNumber)
        case .notificationPermission:
            NotificationPermissionView()
        case .parties:
            PartiesView()
        case .partyDetail(let event):
            PartyDetailView(event: event)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
