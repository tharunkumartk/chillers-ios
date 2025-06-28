import SwiftUI

struct OnboardingPromptsView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep = 0
    @State private var responses: [String] = ["", "", ""]
    @State private var isLoading = false
    @FocusState private var isFieldFocused: Bool
    
    private let totalSteps = 3
    private let prompts = [
        "pick any three people in your blunt rotation",
        "whats ur biggest red flag",
        "what's your biggest hot take in 8 words"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    
                    Text("onboarding")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 40)
            
            Spacer()
            
            // Current Prompt
            VStack(spacing: 24) {
                Text(prompts[currentStep])
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                
                VStack(spacing: 8) {
                    TextField("Your answer...", text: $responses[currentStep], axis: .vertical)
                        .font(.body)
                        .focused($isFieldFocused)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isFieldFocused ? .accent : .clear, lineWidth: 2)
                        )
                        .lineLimit(3...6)
                    
                    HStack {
                        Text("\(responses[currentStep].count)/100 characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .onChange(of: responses[currentStep]) { _, newValue in
                    if newValue.count > 100 {
                        responses[currentStep] = String(newValue.prefix(100))
                    }
                }
            }
            
            Spacer()
            
            // Bottom Continue Button
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    
                    Button {
                        continueToNext()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text(currentStep < totalSteps - 1 ? "next" : "complete")
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            canContinue && !isLoading 
                                ? .accent 
                                : Color.gray.opacity(0.3),
                            in: RoundedRectangle(cornerRadius: 25)
                        )
                        .shadow(
                            color: canContinue && !isLoading 
                                ? .accent.opacity(0.3) 
                                : .clear, 
                            radius: 8, x: 0, y: 4
                        )
                    }
                    .disabled(!canContinue || isLoading)
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .transition(.opacity.combined(with: .move(edge: .trailing)))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFieldFocused = true
            }
        }
    }
    
    private var canContinue: Bool {
        !responses[currentStep].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func continueToNext() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFieldFocused = true
            }
        } else {
            // Last step, complete onboarding
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        guard canContinue else { return }
        
        isLoading = true
        
                 // Save responses to onboarding data
         var promptResponses: [PromptResponse] = []
         for (index, response) in responses.enumerated() {
             if !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                 var promptResponse = PromptResponse()
                 promptResponse.question = prompts[index]
                 promptResponse.answer = response
                 promptResponses.append(promptResponse)
             }
         }
        appState.onboardingData.prompts = promptResponses
        
        Task {
            do {
                try await saveUserProfile()
                
                await MainActor.run {
                    // Navigate to notification permission or main app with animation
                    withAnimation(.easeInOut(duration: 0.4)) {
                        if !appState.notificationPermissionRequested {
                            appState.navigationPath.append(AppDestination.notificationPermission)
                        } else {
                            appState.navigationPath = NavigationPath()
                        }
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("Failed to save profile: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    private func saveUserProfile() async throws {
        guard let userId = appState.currentUser?.id else {
            throw NSError(domain: "ProfileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user found"])
        }
        
        // Upload images to Supabase Storage
        var imageUrls: [String] = []
        
        for (index, image) in appState.onboardingData.profileImages.enumerated() {
            if !image.size.equalTo(.zero) {
                let imageUrl = try await uploadImage(image, userId: userId, index: index)
                imageUrls.append(imageUrl)
            }
        }
        
        // Create user profile
        let userProfile = UserProfile(
            id: UUID(),
            userId: userId,
            bio: nil,
            school: appState.onboardingData.school.isEmpty ? nil : appState.onboardingData.school,
            company: appState.onboardingData.company.isEmpty ? nil : appState.onboardingData.company,
            location: nil,
            height: appState.onboardingData.height.isEmpty ? nil : Int(appState.onboardingData.height),
            gender: nil,
            sexuality: nil,
            age: appState.onboardingData.age.isEmpty ? nil : Int(appState.onboardingData.age),
            profileImages: imageUrls,
            tags: appState.onboardingData.prompts.compactMap { prompt in
                prompt.isComplete ? "\(prompt.question): \(prompt.answer)" : nil
            },
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Save to database
        try await SupabaseManager.shared.client
            .from("user_profiles")
            .insert(userProfile)
            .execute()
        
        // Update user as profile complete
        try await SupabaseManager.shared.client
            .from("users")
            .update(["profile_complete": true])
            .eq("id", value: userId)
            .execute()
        
        // Update local state - user profile is now complete
    }
    
    private func uploadImage(_ image: UIImage, userId: UUID, index: Int) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let fileName = "\(userId)_\(index)_\(UUID().uuidString).jpg"
        
        try await SupabaseManager.shared.client.storage
            .from("profile-images")
            .upload(path: fileName, file: imageData)
        
        let publicURL = try SupabaseManager.shared.client.storage
            .from("profile-images")
            .getPublicURL(path: fileName)
        
        return publicURL.absoluteString
    }
}

#Preview {
    NavigationStack {
        OnboardingPromptsView()
            .environment(AppState())
    }
} 