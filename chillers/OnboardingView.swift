//
//  OnboardingView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentTextIndex = 0
    @State private var textOpacity = 1.0
    
    private let animatedTexts = [
        "let's set up your profile",
        "time to get chilly",
        "make some new friends"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            VStack(spacing: 20) {
                Text("welcome to chillers")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(animatedTexts[currentTextIndex])
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .opacity(textOpacity)
                    .animation(.easeInOut(duration: 0.5), value: textOpacity)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        appState.navigationPath.append(AppDestination.onboardingBasicInfo)
                    }
                } label: {
                    Text("Set Up Profile")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.accent, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(30)
        .navigationBarHidden(true)
        .transition(.opacity.combined(with: .move(edge: .leading)))
        .onAppear {
            startTextAnimation()
        }
    }
    
    private func startTextAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                textOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentTextIndex = (currentTextIndex + 1) % animatedTexts.count
                withAnimation(.easeInOut(duration: 0.5)) {
                    textOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
            .environment(AppState())
            
    }
}
