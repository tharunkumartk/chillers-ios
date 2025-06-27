//
//  AppState.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI
import UserNotifications

// MARK: - App State Management
@Observable
class AppState {
    var isLoggedIn: Bool = false
    var navigationPath = NavigationPath()
    var currentUser: User?
    var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    var notificationPermissionRequested: Bool = false
    
    private let tokenKey = "user_auth_token"
    private let userKey = "user_data"
    private let notificationStatusKey = "notification_permission_status"
    private let notificationRequestedKey = "notification_permission_requested"
    
    init() {
        checkAuthToken()
        loadNotificationSettings()
    }
    
    private func checkAuthToken() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           !token.isEmpty,
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.isLoggedIn = true
            self.currentUser = user
        }
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
    
    func login(phoneNumber: String) {
        // Generate a mock token (in real app, this would come from your API)
        let token = UUID().uuidString
        let user = User(id: UUID(), phoneNumber: phoneNumber, name: "User")
        
        // Save to UserDefaults
        UserDefaults.standard.set(token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
        
        self.currentUser = user
        self.isLoggedIn = true
        navigationPath = NavigationPath() // Clear navigation stack
    }
    
    func logout() {
        // Clear stored data
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: notificationStatusKey)
        UserDefaults.standard.removeObject(forKey: notificationRequestedKey)
        
        self.currentUser = nil
        self.isLoggedIn = false
        self.notificationPermissionStatus = .notDetermined
        self.notificationPermissionRequested = false
        navigationPath = NavigationPath() // Clear navigation stack
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
    case main
    case login
    case phoneEntry
    case notificationPermission
    case parties
    case partyDetail(Party)
} 