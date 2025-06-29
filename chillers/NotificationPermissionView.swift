//
//  NotificationPermissionView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI
import UserNotifications

struct NotificationPermissionView: View {
    @Environment(AppState.self) private var appState
    @State private var isLoading = false
    @State private var currentTextIndex = 0
    @State private var textOpacity = 1.0
    
    private let animatedTexts = [
        "spontaneous vibes",
        "last minute plans",
        "when the party starts"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            VStack(spacing: 20) {
                Text("if you wanna stay up to date")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("on spontaneous parties")
                    .font(.title2)
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                
                Text(animatedTexts[currentTextIndex])
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .opacity(textOpacity)
                    .animation(.easeInOut(duration: 0.5), value: textOpacity)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button {
                    requestNotifications()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Yes, Keep Me Posted")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.accent, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .accent.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isLoading)
                
                Button {
                    skipNotifications()
                } label: {
                    Text("Maybe Later")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
                .disabled(isLoading)
                
                Text("we'll let you know when chillers are around")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            startTextAnimation()
        }
    }
    
    private func startTextAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                textOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentTextIndex = (currentTextIndex + 1) % animatedTexts.count
                withAnimation(.easeInOut(duration: 0.5)) {
                    textOpacity = 1.0
                }
            }
        }
    }
    
    private func requestNotifications() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        isLoading = true
        
        Task {
            await appState.requestNotificationPermissions()
            
            // Registration for remote notifications is now handled automatically
            // by the AppDelegate lifecycle methods
            
            await MainActor.run {
                completeLogin()
            }
        }
    }
    
    private func skipNotifications() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        appState.notificationPermissionRequested = true
        appState.notificationPermissionStatus = .denied
        UserDefaults.standard.set(true, forKey: "notification_permission_requested")
        UserDefaults.standard.set(UNAuthorizationStatus.denied.rawValue, forKey: "notification_permission_status")
        completeLogin()
    }
    
    private func completeLogin() {
        isLoading = false
        
        // User is already authenticated via Supabase at this point
        // Just clear navigation to go to main app with animation
        withAnimation(.easeInOut(duration: 0.4)) {
            appState.navigationPath = NavigationPath()
        }
    }
}

#Preview {
    NavigationStack {
        NotificationPermissionView()
            .environment(AppState())
    }
} 