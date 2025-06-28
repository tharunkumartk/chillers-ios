//
//  AppState.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI
import UserNotifications
import Supabase

// MARK: - App State Management
@Observable
class AppState {
    var isLoggedIn: Bool = false
    var navigationPath = NavigationPath()
    var currentUser: User?
    var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    var notificationPermissionRequested: Bool = false
    var onboardingData = OnboardingData()
    
    private let tokenKey = "user_auth_token"
    private let userKey = "user_data"
    private let notificationStatusKey = "notification_permission_status"
    private let notificationRequestedKey = "notification_permission_requested"
    
    init() {
        checkAuthToken()
        loadNotificationSettings()
        setupAuthListener()
    }
    

    
    private func loadNotificationSettings() {
        notificationPermissionRequested = UserDefaults.standard.bool(forKey: notificationRequestedKey)
        let statusRawValue = UserDefaults.standard.integer(forKey: notificationStatusKey)
        notificationPermissionStatus = UNAuthorizationStatus(rawValue: statusRawValue) ?? .notDetermined
    }
    
    private func saveNotificationSettings() {
        UserDefaults.standard.set(notificationPermissionRequested, forKey: notificationRequestedKey)
        UserDefaults.standard.set(notificationPermissionStatus.rawValue, forKey: notificationStatusKey)
    }
    
    func requestNotificationPermissions() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.notificationPermissionStatus = granted ? .authorized : .denied
                self.notificationPermissionRequested = true
                self.saveNotificationSettings()
            }
        } catch {
            await MainActor.run {
                self.notificationPermissionStatus = .denied
                self.notificationPermissionRequested = true
                self.saveNotificationSettings()
            }
        }
    }
    
    func checkNotificationPermissionStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        await MainActor.run {
            self.notificationPermissionStatus = settings.authorizationStatus
            self.saveNotificationSettings()
        }
    }
    
    // MARK: - Supabase Authentication Methods
    
    /// Set up auth state listener
    private func setupAuthListener() {
        Task {
            for await (event: event, session: session) in SupabaseManager.shared.authStateChanges() {
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        if let session = session {
                            handleAuthSession(session)
                        }
                    case .signedOut:
                        handleSignOut()
                    case .tokenRefreshed:
                        if let session = session {
                            saveSession(session)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    /// Handle successful authentication session
    func handleAuthSession(_ session: Session) {
        Task {
            do {
                // Check if user exists in our database, create if not
                let databaseUser = try await getOrCreateUser(from: session)
                
                await MainActor.run {
                    self.currentUser = User(
                        id: databaseUser.id,
                        phoneNumber: databaseUser.phoneNumber,
                        name: databaseUser.name ?? "User"
                    )
                    self.isLoggedIn = true
                    self.saveSession(session)
                    
                    // Check if profile is complete
                    if !databaseUser.profileComplete {
                        // Navigate to onboarding
                        self.navigationPath.append(AppDestination.onboarding)
                    } else if !self.notificationPermissionRequested {
                        // Navigate to notification permission if not requested yet
                        self.navigationPath.append(AppDestination.notificationPermission)
                    } else {
                        // Clear navigation stack to go to main app
                        self.navigationPath = NavigationPath()
                    }
                }
            } catch {
                await MainActor.run {
                    print("Error handling auth session: \(error)")
                }
            }
        }
    }
    
    /// Get existing user or create new one
    private func getOrCreateUser(from session: Session) async throws -> DatabaseUser {
        let userId = UUID(uuidString: session.user.id.uuidString)!
        let phoneNumber = session.user.phone ?? ""
        
        // Try to get existing user
        do {
            let existingUser: DatabaseUser = try await SupabaseManager.shared.client
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            return existingUser
        } catch {
            // User doesn't exist, create new one
            let newUser = DatabaseUser(
                id: userId,
                phoneNumber: phoneNumber,
                name: nil,
                profileComplete: false,
                approvalStatus: .pending,
                vouchCount: 0,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            let createdUser: DatabaseUser = try await SupabaseManager.shared.client
                .from("users")
                .insert(newUser)
                .select()
                .single()
                .execute()
                .value
            
            return createdUser
        }
    }
    
    /// Handle sign out
    private func handleSignOut() {
        clearStoredData()
        self.currentUser = nil
        self.isLoggedIn = false
        self.navigationPath = NavigationPath()
    }
    
    /// Save session to UserDefaults
    private func saveSession(_ session: Session) {
        UserDefaults.standard.set(session.accessToken, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
    }
    
    /// Send OTP to phone number
    func sendOTP(to phoneNumber: String) async throws {
        try await SupabaseManager.shared.sendOTP(to: phoneNumber)
    }
    
    func logout() {
        Task {
            do {
                try await SupabaseManager.shared.signOut()
                // handleSignOut() will be called automatically by the auth state listener
            } catch {
                // If Supabase signout fails, still clear local data
                await MainActor.run {
                    handleSignOut()
                }
            }
        }
    }
    
    /// Clear all stored data
    private func clearStoredData() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: notificationStatusKey)
        UserDefaults.standard.removeObject(forKey: notificationRequestedKey)
        
        self.notificationPermissionStatus = .notDetermined
        self.notificationPermissionRequested = false
    }
    
    /// Check for existing Supabase session on app startup
    private func checkAuthToken() {
        Task {
            do {
                let session = try await SupabaseManager.shared.currentSession
                if let session = session {
                    await MainActor.run {
                        handleAuthSession(session)
                    }
                }
            } catch {
                // No valid session found, user needs to log in
                await MainActor.run {
                    self.isLoggedIn = false
                }
            }
        }
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: UUID
    let phoneNumber: String
    let name: String
}

// MARK: - Party Model
struct Party: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let hostName: String
    let date: Date
    let time: String
    let imageURL: String
    let attendeesCount: Int
    let attendees: [Attendee]
    let description: String
    let location: String
    
    init(title: String, hostName: String, date: Date, time: String, imageURL: String, attendeesCount: Int = 0, attendees: [Attendee] = [], description: String = "", location: String = "") {
        self.id = UUID()
        self.title = title
        self.hostName = hostName
        self.date = date
        self.time = time
        self.imageURL = imageURL
        self.attendeesCount = attendeesCount
        self.attendees = attendees
        self.description = description
        self.location = location
    }
}

// MARK: - Attendee Model
struct Attendee: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let avatarURL: String?
    
    init(name: String, avatarURL: String? = nil) {
        self.id = UUID()
        self.name = name
        self.avatarURL = avatarURL
    }
}

// MARK: - Navigation Destinations
enum AppDestination: Hashable {
    case onboarding
    case onboardingBasicInfo
    case onboardingPhotos
    case onboardingPrompts
    case main
    case login
    case phoneEntry
    case otpVerification(String) // Phone number parameter
    case notificationPermission
    case parties
    case partyDetail(Party)
} 