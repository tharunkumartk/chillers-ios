import SwiftUI

struct ComingSoonView: View {
    @Environment(AppState.self) private var appState
    @State private var currentTextIndex = 0
    @State private var textOpacity = 1.0
    @State private var timeRemaining = ""
    @State private var countdownTimer: Timer?
    
    private let animatedTexts = [
        "almost there",
        "the wait is almost over", 
        "get ready to swipe"
    ]
    
    // Target date: 6/28/25 12pm PST
    private let targetDate: Date = {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 28
        components.hour = 12 // 12pm
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(identifier: "America/Los_Angeles") // PST
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            VStack(spacing: 20) {
                Text("swipe to let other chillers in")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("coming soon")
                    .font(.title2)
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                
                // Countdown timer
                VStack(spacing: 8) {
                    Text(timeRemaining)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(animatedTexts[currentTextIndex])
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: 0.5), value: textOpacity)
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("we'll notify you when it's time to start swiping")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
               
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            startTextAnimation()
            startCountdownTimer()
        }
        .onDisappear {
            countdownTimer?.invalidate()
        }
    }
    
    private func startTextAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
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
    
    private func startCountdownTimer() {
        updateCountdown()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateCountdown()
        }
    }
    
    private func updateCountdown() {
        let now = Date()
        let timeInterval = targetDate.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            timeRemaining = "It's time!"
            countdownTimer?.invalidate()
        } else {
            let days = Int(timeInterval) / 86400
            let hours = Int(timeInterval) % 86400 / 3600
            let minutes = Int(timeInterval) % 3600 / 60
            let seconds = Int(timeInterval) % 60
            
            if days > 0 {
                timeRemaining = "\(days)d \(hours)h \(minutes)m \(seconds)s"
            } else if hours > 0 {
                timeRemaining = "\(hours)h \(minutes)m \(seconds)s"
            } else if minutes > 0 {
                timeRemaining = "\(minutes)m \(seconds)s"
            } else {
                timeRemaining = "\(seconds)s"
            }
        }
    }
}

#Preview {
    NavigationStack {
        ComingSoonView()
            .environment(AppState())
    }
} 