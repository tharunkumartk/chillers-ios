import SwiftUI

struct PassphraseView: View {
    @Environment(AppState.self) private var appState
    @State private var passphrase = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var isFieldFocused: Bool
    
    // Sample valid passphrases - in a real app, this would be checked against a database
    private let validPassphrases = ["nodiddy"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 24) {
                Spacer()
                
                // Logo
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .shadow(color: .accent.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 12) {
                    Text("chillers")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            
            // Main Content
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("know a brother?")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("enter the passphrase if you have one")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    TextField("passphrase", text: $passphrase)
                        .font(.body)
                        .focused($isFieldFocused)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isFieldFocused ? .accent : (showError ? .red : .clear), lineWidth: 2)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            checkPassphrase()
                        }
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 16) {
                    // Continue with passphrase button
                    Button {
                        checkPassphrase()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("continue")
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            !passphrase.isEmpty && !isLoading 
                                ? .accent 
                                : Color.gray.opacity(0.3),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .shadow(
                            color: !passphrase.isEmpty && !isLoading 
                                ? .accent.opacity(0.3) 
                                : .clear, 
                            radius: 8, x: 0, y: 4
                        )
                    }
                    .disabled(passphrase.isEmpty || isLoading)
                    
                    // No passphrase button
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            appState.navigationPath.append(AppDestination.waitlist)
                        }
                    } label: {
                        Text("no, i don't have one")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFieldFocused = true
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showError)
    }
    
    private func checkPassphrase() {
        guard !passphrase.isEmpty else { return }
        
        isLoading = true
        showError = false
        
                // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if validPassphrases.contains(passphrase.lowercased()) {
                // Valid passphrase - proceed to notification permission or main app
                withAnimation(.easeInOut(duration: 0.4)) {
                    if !appState.notificationPermissionRequested {
                        appState.navigationPath.append(AppDestination.notificationPermission)
                    } else {
                        appState.navigationPath = NavigationPath()
                    }
                }
            } else {
                // Invalid passphrase
                errorMessage = "invalid passphrase"
                showError = true
                
                // Clear field and refocus
                passphrase = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFieldFocused = true
                }
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        PassphraseView()
            .environment(AppState())
    }
} 