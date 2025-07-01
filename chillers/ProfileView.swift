//
//  ProfileView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack {
            // Display user information
            Text("User Profile")
                .font(.largeTitle)
                .padding()
            
            // Example user information
            Text("Name: \(appState.user.name)")
                .font(.title2)
                .padding()
            
            Text("Email: \(appState.user.email)")
                .font(.title2)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
} 