//
//  LoginView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Phone Number Entry View
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var phoneNumber = ""
    @State private var isLoading = false
    @FocusState private var isPhoneFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 24) {
                Spacer()
                
                // Logo/Icon
                Circle()
                    .fill(.accent)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .accent.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 12) {
                    Text("Welcome to chillers")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Text("Enter your phone number to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            
            // Phone Input Section
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    // Phone Number Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            // Country Code
                            HStack(spacing: 4) {
                                Text("🇺🇸")
                                    .font(.title3)
                                Text("+1")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                            
                            // Phone Input
                            TextField("(555) 123-4567", text: $phoneNumber)
                                .font(.body.weight(.medium))
                                .keyboardType(.phonePad)
                                .focused($isPhoneFieldFocused)
                                .textContentType(.telephoneNumber)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isPhoneFieldFocused ? .accent : .clear, lineWidth: 2)
                                )
                                .onChange(of: phoneNumber) { _, newValue in
                                    phoneNumber = formatPhoneNumber(newValue)
                                }
                        }
                    }
                    
                    // Info Text
                    Text("We'll send you a verification code")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Continue Button
                Button {
                    loginWithPhoneNumber()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Continue")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        isPhoneNumberValid && !isLoading 
                            ? .accent 
                            : Color.gray.opacity(0.3)
                    )
                    .foregroundColor(isPhoneNumberValid && !isLoading ? .white : .gray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: isPhoneNumberValid && !isLoading 
                            ? .accent.opacity(0.3) 
                            : .clear, 
                        radius: 8, x: 0, y: 4
                    )
                }
                .disabled(!isPhoneNumberValid || isLoading)
                .animation(.easeInOut(duration: 0.2), value: isPhoneNumberValid)
                .animation(.easeInOut(duration: 0.2), value: isLoading)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            // Auto-focus on phone field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPhoneFieldFocused = true
            }
        }
        .onTapGesture {
            isPhoneFieldFocused = false
        }
    }
    
    private var isPhoneNumberValid: Bool {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleanNumber.count == 10
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if cleanNumber.count <= 10 {
            let mask = "(XXX) XXX-XXXX"
            var result = ""
            var index = cleanNumber.startIndex
            
            for char in mask where index < cleanNumber.endIndex {
                if char == "X" {
                    result.append(cleanNumber[index])
                    index = cleanNumber.index(after: index)
                } else {
                    result.append(char)
                }
            }
            return result
        }
        return String(cleanNumber.prefix(10))
    }
    
    private func loginWithPhoneNumber() {
        guard isPhoneNumberValid else { return }
        
        isLoading = true
        isPhoneFieldFocused = false
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            
            // Save phone number temporarily
            let user = User(id: UUID(), phoneNumber: "+1\(cleanNumber)", name: "User")
            appState.currentUser = user
            
            // Navigate to notification permission view if not requested yet
            if !appState.notificationPermissionRequested {
                appState.navigationPath.append(AppDestination.notificationPermission)
            } else {
                // Complete login if notifications already handled
                appState.login(phoneNumber: "+1\(cleanNumber)")
            }
            
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environment(AppState())
    }
    
} 
