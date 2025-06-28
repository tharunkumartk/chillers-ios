import SwiftUI

struct OnboardingBasicInfoView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep = 0
    @State private var isLoading = false
    @FocusState private var isFieldFocused: Bool
    
    // Create a bindable reference to access bindings
    private var bindableAppState: AppState {
        appState
    }
    
    private let totalSteps = 6
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with logo and title
                HStack {
                    HStack(spacing: 8) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        
                        Text(stepTitleShort)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    HStack(spacing: 4) {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            Circle()
                                .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Content - positioned higher to avoid keyboard
                VStack(spacing: 0) {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Text(stepTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            if let subtitle = stepSubtitle {
                                Text(subtitle)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        // Input field
                        VStack(spacing: 16) {
                            TextField(stepPlaceholder, text: stepBinding)
                                .font(.body)
                                .focused($isFieldFocused)
                                .keyboardType(currentStep == 3 ? .numberPad : .default) // Age step
                                .padding(16)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isFieldFocused ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                                .id("textField-\(currentStep)") // Force view refresh for animation
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Continue button - positioned at bottom right with keyboard padding
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
                                    Image(systemName: "arrow.right")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(width: 56, height: 56)
                            .background(canContinue ? Color.accentColor : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: canContinue ? Color.accentColor.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!canContinue || isLoading)
                        .animation(.easeInOut(duration: 0.2), value: canContinue)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30) // Moderate padding to stay above keyboard
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFieldFocused = true
            }
        }

        .onTapGesture {
            isFieldFocused = false
        }
    }
    
    // MARK: - Computed Properties
    
    private var stepTitleShort: String {
        return "onboarding"
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "what's your first name?"
        case 1: return "what's your last name?"
        case 2: return "how tall are you?"
        case 3: return "how old are you?"
        case 4: return "where do you work?"
        case 5: return "where do you study?"
        default: return ""
        }
    }
    
    private var stepSubtitle: String? {
        return nil
    }
    
    private var stepIcon: String {
        switch currentStep {
        case 0: return "person.fill"
        case 1: return "building.2.fill"
        case 2: return "graduationcap.fill"
        case 3: return "location.fill"
        case 4: return "calendar"
        case 5: return "ruler.fill"
        case 6: return "person.2.fill"
        case 7: return "text.quote"
        default: return "person.fill"
        }
    }
    
    private var stepPlaceholder: String {
        switch currentStep {
        case 0: return "first name"
        case 1: return "last name"
        case 2: return "height (e.g. 5'8\")"
        case 3: return "age"
        case 4: return "company"
        case 5: return "school"
        default: return ""
        }
    }
    
    private var stepBinding: Binding<String> {
        @Bindable var bindableState = bindableAppState
        switch currentStep {
        case 0: return $bindableState.onboardingData.firstName
        case 1: return $bindableState.onboardingData.lastName
        case 2: return $bindableState.onboardingData.height
        case 3: return $bindableState.onboardingData.age
        case 4: return $bindableState.onboardingData.company
        case 5: return $bindableState.onboardingData.school
        default: return .constant("")
        }
    }
    

    
    private var canContinue: Bool {
        !stepBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Actions
    
    private func continueToNext() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStep += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isFieldFocused = true
            }
        } else {
            // Last step, continue to photos
            withAnimation(.easeInOut(duration: 0.3)) {
                appState.navigationPath.append(AppDestination.onboardingPhotos)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingBasicInfoView()
            .environment(AppState())
    }
} 