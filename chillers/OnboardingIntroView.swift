import SwiftUI

struct OnboardingIntroView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0
    @State private var isLoading = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false
    
    private let totalPages = 2
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            VStack(spacing: 20) {
                Text(currentPage == 0 ? "hey" : "so we made an app for chillers to find other chillers")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(showTitle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8), value: showTitle)
                
                Text(currentPage == 0
                    ? "we realized it was really hard to meet other chillers, and parties are lame without chillers."
                    : "people submit their profile, and other chillers on the app decide if the person is a chiller or not.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .opacity(showSubtitle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8), value: showSubtitle)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Bottom Button
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
                                Text(currentPage == 0 ? "next" : "give it a shot")
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            .accent,
                            in: RoundedRectangle(cornerRadius: 25)
                        )
                        .shadow(
                            color: .accent.opacity(0.3),
                            radius: 8, x: 0, y: 4
                        )
                    }
                    .disabled(isLoading)
                    .opacity(showButton ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8), value: showButton)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .overlay(
            // Debug mode indicator
            VStack {
                HStack {
                    Text("DEBUG MODE")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.leading, 20)
                Spacer()
            }
        )
        .onAppear {
            startSequentialAnimation()
        }
    }
    
    private func continueToNext() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        if currentPage < totalPages - 1 {
            // First, hide all elements
            showTitle = false
            showSubtitle = false
            showButton = false
            
            // Wait for elements to fade out, then change page content
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentPage += 1
                }
                
                // Start animations for new page after content changes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    startSequentialAnimation()
                }
            }
        } else {
            // Last page, go to basic info onboarding
            withAnimation(.easeInOut(duration: 0.3)) {
                appState.navigationPath.append(AppDestination.onboardingBasicInfo)
            }
        }
    }
    
    private func startSequentialAnimation() {
        // Reset all states first
        showTitle = false
        showSubtitle = false
        showButton = false
        
        // Show title with haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let softImpact = UIImpactFeedbackGenerator(style: .soft)
            softImpact.impactOccurred()
            showTitle = true
        }
        
        // Show subtitle with haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let softImpact = UIImpactFeedbackGenerator(style: .soft)
            softImpact.impactOccurred()
            showSubtitle = true
        }
        
        // Show button with haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            let softImpact = UIImpactFeedbackGenerator(style: .soft)
            softImpact.impactOccurred()
            showButton = true
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingIntroView()
            .environment(AppState())
    }
}
