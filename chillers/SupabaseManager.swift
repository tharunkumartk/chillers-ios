import Foundation
import Supabase

// MARK: - Supabase Configuration
@Observable
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // Replace these with your actual Supabase URL and anon key
        guard let supabaseURL = URL(string: "https://tjjbdqrdcmihegtqmdez.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqamJkcXJkY21paGVndHFtZGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEwNjk4MzYsImV4cCI6MjA2NjY0NTgzNn0.IaQG8HXobhBsCsNVTdJwByMthkZc-Rqa-0gFEfWVAko"
        )
    }
    
    // MARK: - Authentication Methods
    
    /// Send OTP to phone number
    func sendOTP(to phoneNumber: String) async throws {
        try await client.auth.signInWithOTP(
            phone: phoneNumber
        )
    }
    
    /// Verify OTP and sign in
    func verifyOTP(phone: String, token: String) async throws -> AuthResponse {
        let response = try await client.auth.verifyOTP(
            phone: phone,
            token: token,
            type: .sms
        )
        return response
    }
    
    /// Get current session
    var currentSession: Session? {
        get async throws {
            try await client.auth.session
        }
    }
    
    /// Get current user
    var currentUser: Supabase.User? {
        get async throws {
            try await client.auth.user()
        }
    }
    
    /// Sign out current user
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    /// Listen to auth state changes
    func authStateChanges() -> AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        client.auth.authStateChanges
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