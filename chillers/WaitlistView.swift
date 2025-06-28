import SwiftUI

struct WaitlistView: View {
    @Environment(AppState.self) private var appState
    @State private var currentTextIndex = 0
    @State private var textOpacity = 1.0
    
    private let animatedTexts = [
        "hang tight",
        "good things come to those who wait",
        "we're building something special"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            VStack(spacing: 20) {
                Text("you'll be added soon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("if you're a chiller")
                    .font(.title2)
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                
                Text(animatedTexts[currentTextIndex])
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .opacity(textOpacity)
                    .animation(.easeInOut(duration: 0.5), value: textOpacity)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("we'll notify you when it's your turn")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button {
                    appState.logout()
                } label: {
                    Text("Sign Out")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            startTextAnimation()
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
}

#Preview {
    NavigationStack {
        WaitlistView()
            .environment(AppState())
    }
} 