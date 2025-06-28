import SwiftUI
import PhotosUI
import UIKit

struct OnboardingPhotosView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedPhotoIndex: Int?
    @State private var showingImagePicker = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Create a bindable reference to access bindings
    private var bindableAppState: AppState {
        appState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo and title
            HStack {
                HStack(spacing: 8) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text("onboarding")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            VStack(spacing: 8) {
                Text("add your photos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                Text("upload 4 photos to complete your profile")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }
            
            // Photo Grid
            VStack(spacing: 16) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        PhotoSlotView(
                            image: safeGetImage(at: index),
                            index: index,
                            onTap: {
                                selectedPhotoIndex = index
                                showingImagePicker = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                HStack {
                    Text("\(filledSlotsCount)/4 photos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 32)
            
            Spacer()
            
            // Continue button
            HStack {
                Spacer()
                
                Button {
                    continueToPrompts()
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
            .padding(.bottom, 60)
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: selectedImageBinding)
        }
        .onAppear {
            // Initialize profile images if empty
            if appState.onboardingData.profileImages.count < 4 {
                appState.onboardingData.profileImages = Array(repeating: UIImage(), count: 4)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filledSlotsCount: Int {
        appState.onboardingData.profileImages.filter { !$0.size.equalTo(.zero) }.count
    }
    
    private var canContinue: Bool {
        filledSlotsCount >= 4
    }
    
    private func safeGetImage(at index: Int) -> UIImage? {
        guard index < appState.onboardingData.profileImages.count else { return nil }
        let image = appState.onboardingData.profileImages[index]
        return image.size.equalTo(.zero) ? nil : image
    }
    
    private var selectedImageBinding: Binding<UIImage?> {
        Binding(
            get: {
                guard let index = selectedPhotoIndex else { return nil }
                return safeGetImage(at: index)
            },
            set: { newImage in
                guard let index = selectedPhotoIndex, let image = newImage else { return }
                if index < appState.onboardingData.profileImages.count {
                    appState.onboardingData.profileImages[index] = image
                }
            }
        )
    }
    
    // MARK: - Actions
    
    private func continueToPrompts() {
        guard canContinue else { return }
        appState.navigationPath.append(AppDestination.onboardingPrompts)
    }
}

// MARK: - Photo Slot View
struct PhotoSlotView: View {
    let image: UIImage?
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Always use the original image since editing is disabled
            if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingPhotosView()
            .environment(AppState())
    }
} 