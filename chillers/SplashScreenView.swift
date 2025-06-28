import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
}

#Preview {
    SplashScreenView()
} 