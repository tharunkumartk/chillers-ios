import Foundation
import Supabase

// MARK: - Supabase Configuration

@Observable
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let authClient: SupabaseClient
    let dbClient: SupabaseClient
    
    private init() {
        // Replace these with your actual Supabase URL and keys
        guard let supabaseURL = URL(string: "https://tjjbdqrdcmihegtqmdez.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }
        
        // Auth client with anon key for authentication operations
        self.authClient = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqamJkcXJkY21paGVndHFtZGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEwNjk4MzYsImV4cCI6MjA2NjY0NTgzNn0.IaQG8HXobhBsCsNVTdJwByMthkZc-Rqa-0gFEfWVAko"
        )
        
        // Database client with service role key (bypasses RLS)
        self.dbClient = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqamJkcXJkY21paGVndHFtZGV6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTA2OTgzNiwiZXhwIjoyMDY2NjQ1ODM2fQ.MEv6UBZ9NTKyXst39j7NfPHv1PrN9mZK8TitomP5h5E"
        )
    }
    
    // For backwards compatibility
    var client: SupabaseClient {
        return dbClient
    }
    
    // MARK: - Authentication Methods
    
    /// Send OTP to phone number
    func sendOTP(to phoneNumber: String) async throws {
        try await authClient.auth.signInWithOTP(
            phone: phoneNumber
        )
    }
        
    /// Verify OTP and sign in
    func verifyOTP(phone: String, token: String) async throws -> AuthResponse {
        let response = try await authClient.auth.verifyOTP(
            phone: phone,
            token: token,
            type: .sms
        )
        return response
    }
    
    /// Get current session
    var currentSession: Session? {
        get async throws {
            try await authClient.auth.session
        }
    }
    
    /// Get current user
    var currentUser: Supabase.User? {
        get async throws {
            try await authClient.auth.user()
        }
    }
    
    /// Sign out current user
    func signOut() async throws {
        try await authClient.auth.signOut()
    }
    
    /// Listen to auth state changes
    func authStateChanges() -> AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        authClient.auth.authStateChanges
    }
    
    // MARK: - Database Query Helpers
    
    /// Check if current user is approved
    func isCurrentUserApproved() async throws -> Bool {
        let user = try await authClient.auth.user()
        
        let databaseUser: DatabaseUser = try await dbClient
            .from("users")
            .select()
            .eq("id", value: user.id.uuidString)
            .single()
            .execute()
            .value
        
        return databaseUser.approvalStatus == .approved
    }
    
    // MARK: - Event Methods
    
    /// Fetch events
    func fetchEvents() async throws -> [DatabaseEvent] {
        try await dbClient
            .from("events")
            .select()
            .order("event_date", ascending: true)
            .execute()
            .value
    }
    
    /// Update event attendance
    func updateEventAttendance(
        eventId: UUID,
        status: AttendeeStatus
    ) async throws {
        let userId = try await currentUser?.id
        
        // Check if attendance record exists
        let existing: [EventAttendee] = try await dbClient
            .from("event_attendees")
            .select()
            .eq("event_id", value: eventId)
            .eq("user_id", value: userId?.uuidString ?? "")
            .execute()
            .value
        
        if existing.isEmpty {
            // Create new attendance
            try await dbClient
                .from("event_attendees")
                .insert([
                    "event_id": eventId.uuidString,
                    "user_id": userId?.uuidString ?? "",
                    "status": status.rawValue
                ])
                .execute()
        } else {
            // Update existing attendance
            try await dbClient
                .from("event_attendees")
                .update(["status": status.rawValue])
                .eq("event_id", value: eventId)
                .eq("user_id", value: userId?.uuidString ?? "")
                .execute()
        }
    }
    
    /// Get event attendees
    func getEventAttendees(eventId: UUID) async throws -> [EventAttendee] {
        try await dbClient
            .from("event_attendees")
            .select()
            .eq("event_id", value: eventId)
            .execute()
            .value
    }
    
    /// Get current user's attendance status for an event
    func getCurrentUserAttendanceStatus(eventId: UUID) async throws -> AttendeeStatus? {
        let userId = try await currentUser?.id
        
        let attendees: [EventAttendee] = try await dbClient
            .from("event_attendees")
            .select()
            .eq("event_id", value: eventId)
            .eq("user_id", value: userId?.uuidString ?? "")
            .execute()
            .value
        
        return attendees.first?.status
    }
    
    /// Get user profile by ID
    func getUserProfile(userId: UUID) async throws -> UserProfile? {
        let profiles: [UserProfile] = try await dbClient
            .from("user_profiles")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return profiles.first
    }
    
    /// Get database user by ID
    func getDatabaseUser(userId: UUID) async throws -> DatabaseUser? {
        let users: [DatabaseUser] = try await dbClient
            .from("users")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        return users.first
    }
    
    /// Update user profile with APN device token
    func updateAPNDeviceToken(userId: UUID, deviceToken: String) async throws {
        try await dbClient
            .from("user_profiles")
            .update(["apn_device_token": deviceToken])
            .eq("user_id", value: userId)
            .execute()
    }

}

// MARK: - Supabase User Extension

extension Supabase.User {
    /// Convert Supabase User to local User model
    func toLocalUser() -> User {
        return User(
            id: UUID(uuidString: id.uuidString) ?? UUID(),
            phoneNumber: phone ?? "",
            name: userMetadata["name"]?.stringValue ?? "User"
        )
    }
}
