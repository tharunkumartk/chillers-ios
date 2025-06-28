import SwiftUI
import Supabase

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
            .padding(.top, 16)
            .padding(.bottom, 24)
            
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
                    .id("prompt-\(currentStep)") // Force view refresh for animation
                
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
                        .id("textField-\(currentStep)") // Force view refresh for animation
                    
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
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
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
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStep += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
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
                    // User is now fully logged in, always go to passphrase page
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appState.navigationPath.append(AppDestination.passphrase)
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
        
        do {
            // 1. Upload images to Supabase Storage
            print("Uploading images...")
            var imageUrls: [String] = []
            
            for (index, image) in appState.onboardingData.profileImages.enumerated() {
                if !image.size.equalTo(.zero) {
                    let imageUrl = try await uploadImage(image, userId: userId, index: index)
                    imageUrls.append(imageUrl)
                }
            }
            print("Images uploaded: \(imageUrls.count)")
            
            // 2. Create user profile
            print("Creating user profile...")
            let userProfile = UserProfile(
                id: UUID(),
                userId: userId,
                firstName: appState.onboardingData.firstName.isEmpty ? nil : appState.onboardingData.firstName,
                lastName: appState.onboardingData.lastName.isEmpty ? nil : appState.onboardingData.lastName,
                height: appState.onboardingData.height.isEmpty ? nil : appState.onboardingData.height,
                age: appState.onboardingData.age.isEmpty ? nil : Int(appState.onboardingData.age),
                company: appState.onboardingData.company.isEmpty ? nil : appState.onboardingData.company,
                school: appState.onboardingData.school.isEmpty ? nil : appState.onboardingData.school,
                bio: nil,
                location: nil,
                gender: nil,
                sexuality: nil,
                profileImages: imageUrls,
                tags: appState.onboardingData.prompts.compactMap { prompt in
                    prompt.isComplete ? "\(prompt.question): \(prompt.answer)" : nil
                },
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // 3. Save profile to database
            try await SupabaseManager.shared.client
                .from("user_profiles")
                .insert(userProfile)
                .execute()
            print("User profile created successfully")
            
            // 4. Save user prompts to database
            print("Creating user prompts...")
            for prompt in appState.onboardingData.prompts {
                if prompt.isComplete {
                    let userPrompt = [
                        "user_id": userId.uuidString,
                        "question": prompt.question,
                        "answer": prompt.answer
                    ]
                    
                    try await SupabaseManager.shared.client
                        .from("user_prompts")
                        .insert(userPrompt)
                        .execute()
                }
            }
            print("User prompts created successfully")
            
            // 5. Update existing user record to mark profile as complete
            print("Completing user profile...")
            try await appState.completeUserProfile(with: appState.onboardingData)
            print("User profile marked as complete")
            
            // 6. Update local app state - user is now fully logged in
            await MainActor.run {
                if let currentUser = appState.currentUser {
                    appState.currentUser = User(
                        id: currentUser.id,
                        phoneNumber: currentUser.phoneNumber,
                        name: appState.onboardingData.fullName.isEmpty ? currentUser.name : appState.onboardingData.fullName
                    )
                }
                appState.isLoggedIn = true
            }
            print("Profile save completed successfully")
            
        } catch {
            print("Error in saveUserProfile: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError - code: \(postgrestError.code ?? "none"), message: \(postgrestError.message)")
            }
            throw error
        }
    }
    
    private func uploadImage(_ image: UIImage, userId: UUID, index: Int) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let fileName = "\(userId)_\(index)_\(UUID().uuidString).jpg"
        
        try await SupabaseManager.shared.dbClient.storage
            .from("profile-images")
            .upload(path: fileName, file: imageData)
        
        let publicURL = try SupabaseManager.shared.dbClient.storage
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
