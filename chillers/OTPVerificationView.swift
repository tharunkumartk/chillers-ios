import SwiftUI

struct OTPVerificationView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let phoneNumber: String
    @State private var otpCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var resendCooldown = 0
    @State private var canResend = false
    
    @FocusState private var isOTPFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 24) {
                Spacer()
                
                // SMS Icon
                Circle()
                    .fill(.accent)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "message.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .accent.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 12) {
                    Text("Verify your phone")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Text("We sent a 6-digit code to\n\(formatPhoneNumber(phoneNumber))")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            
            // OTP Input Section
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    // OTP Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification Code")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        OTPInputField(otpCode: $otpCode, isFieldFocused: $isOTPFieldFocused)
                    }
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Resend option
                    HStack {
                        Text("Didn't receive the code?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button {
                            resendOTP()
                        } label: {
                            if resendCooldown > 0 {
                                Text("Resend in \(resendCooldown)s")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.gray)
                            } else {
                                Text("Resend")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.accent)
                            }
                        }
                        .disabled(resendCooldown > 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Verify Button
                Button {
                    verifyOTP()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Verify")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        otpCode.count == 6 && !isLoading
                            ? .accent
                            : Color.gray.opacity(0.3)
                    )
                    .foregroundColor(otpCode.count == 6 && !isLoading ? .white : .gray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: otpCode.count == 6 && !isLoading
                            ? .accent.opacity(0.3)
                            : .clear,
                        radius: 8, x: 0, y: 4
                    )
                }
                .disabled(otpCode.count != 6 || isLoading)
                .animation(.easeInOut(duration: 0.2), value: otpCode.count == 6)
                .animation(.easeInOut(duration: 0.2), value: isLoading)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundColor(.accent)
                }
            }
        }
        .onAppear {
            startResendCooldown()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isOTPFieldFocused = true
            }
        }
        .onTapGesture {
            isOTPFieldFocused = false
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleanNumber.count >= 10 {
            let areaCode = String(cleanNumber.prefix(3))
            let firstThree = String(cleanNumber.dropFirst(3).prefix(3))
            let lastFour = String(cleanNumber.dropFirst(6).prefix(4))
            return "(\(areaCode)) \(firstThree)-\(lastFour)"
        }
        return number
    }
    
    private func startResendCooldown() {
        resendCooldown = 30
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            resendCooldown -= 1
            if resendCooldown <= 0 {
                timer.invalidate()
                canResend = true
            }
        }
    }
    
    private func resendOTP() {
        Task {
            do {
                try await SupabaseManager.shared.sendOTP(to: phoneNumber)
                startResendCooldown()
                errorMessage = ""
            } catch {
                errorMessage = "Failed to resend code. Please try again."
            }
        }
    }
    
    private func verifyOTP() {
        guard otpCode.count == 6 else { return }
        
        isLoading = true
        errorMessage = ""
        isOTPFieldFocused = false
        
        Task {
            do {
                let response = try await SupabaseManager.shared.verifyOTP(
                    phone: phoneNumber,
                    token: otpCode
                )
                
                await MainActor.run {
                    appState.handleAuthSession(response.session!)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Invalid code. Please try again."
                    otpCode = ""
                    isLoading = false
                    isOTPFieldFocused = true
                }
            }
        }
    }
}

// MARK: - OTP Input Field
struct OTPInputField: View {
    @Binding var otpCode: String
    @FocusState.Binding var isFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.quaternary)
                        .frame(width: 48, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    index == otpCode.count && isFieldFocused ? .accent : .clear,
                                    lineWidth: 2
                                )
                        )
                    
                    Text(index < otpCode.count ? String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]) : "")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .background {
            TextField("", text: $otpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFieldFocused)
                .opacity(0)
                .onChange(of: otpCode) { _, newValue in
                    // Limit to 6 digits
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count <= 6 {
                        otpCode = String(filtered.prefix(6))
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        OTPVerificationView(phoneNumber: "+15551234567")
            .environment(AppState())
    }
} 
