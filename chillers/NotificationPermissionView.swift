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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 24) {
                Spacer()
                
                // Notification Icon
                Circle()
                    .fill(.accent)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .accent.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 12) {
                    Text("Stay in the loop!")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Text("Get notified when there are chillers near you and cool events happening")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            
            // Benefits Section
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    NotificationBenefitRow(
                        icon: "snowflake",
                        iconColor: .accent,
                        title: "Stay Connected",
                        description: "Know when chillers are around to hang out"
                    )
                    
                    NotificationBenefitRow(
                        icon: "calendar",
                        iconColor: .blue,
                        title: "Events & Parties",
                        description: "Don't miss out on the fun happening nearby"
                    )
                }
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        requestNotifications()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Enable Notifications")
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.accent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .accent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isLoading)
                    
                    Button {
                        skipNotifications()
                    } label: {
                        Text("Maybe Later")
                            .font(.body.weight(.medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                    .disabled(isLoading)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }
    
    private func requestNotifications() {
        isLoading = true
        
        Task {
            await appState.requestNotificationPermissions()
            
            await MainActor.run {
                completeLogin()
            }
        }
    }
    
    private func skipNotifications() {
        appState.notificationPermissionRequested = true
        appState.notificationPermissionStatus = .denied
        UserDefaults.standard.set(true, forKey: "notification_permission_requested")
        UserDefaults.standard.set(UNAuthorizationStatus.denied.rawValue, forKey: "notification_permission_status")
        completeLogin()
    }
    
    private func completeLogin() {
        isLoading = false
        
        // Complete the login process with the saved phone number
        if let user = appState.currentUser {
            appState.login(phoneNumber: user.phoneNumber)
        }
        
        // Navigate back to main app
        appState.navigationPath = NavigationPath()
    }
}

struct NotificationBenefitRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(iconColor.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        NotificationPermissionView()
            .environment(AppState())
    }
} 