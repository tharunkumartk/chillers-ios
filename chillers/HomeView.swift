//
//  HomeView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Person Model

struct Person: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let age: Int
    let height: String
    let location: String
    let distance: String
    let status: String
    let company: String
    let university: String
    let images: [String]
    let prompts: [Prompt]
}

struct Prompt: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - Home View

struct HomeView: View {
    @State private var currentPersonIndex = 0
    @State private var showLikeAnimation = false
    @State private var showPassAnimation = false
    @State private var isAnimating = false
    @State private var dragOffset = CGSize.zero
    
    private let people: [Person] = [
        Person(
            name: "Amaya",
            age: 24,
            height: "5'6\"",
            location: "Palo Alto",
            distance: "2 miles away",
            status: "",
            company: "Google",
            university: "Stanford University",
            images: [
                "https://picsum.photos/400/500?random=1",
                "https://picsum.photos/400/500?random=2",
                "https://picsum.photos/400/500?random=3",
                "https://picsum.photos/400/500?random=4"
            ],
            prompts: [
                Prompt(question: "My simple pleasures", answer: "Coffee and my favourite show"),
                Prompt(question: "I'm looking for", answer: "Someone who loves adventure"),
                Prompt(question: "My love language is", answer: "Quality time and good food"),
                Prompt(question: "You should leave a comment if", answer: "You can make me laugh")
            ]
        ),
        Person(
            name: "Sofia",
            age: 26,
            height: "5'5\"",
            location: "University District",
            distance: "3 miles away",
            status: "Recently active",
            company: "Meta",
            university: "UC Berkeley",
            images: [
                "https://picsum.photos/400/500?random=5",
                "https://picsum.photos/400/500?random=6",
                "https://picsum.photos/400/500?random=7",
                "https://picsum.photos/400/500?random=8"
            ],
            prompts: [
                Prompt(question: "Two truths and a lie", answer: "I speak 4 languages, I've been skydiving, I'm afraid of butterflies"),
                Prompt(question: "My greatest strength", answer: "Making people feel comfortable"),
                Prompt(question: "I go crazy for", answer: "Late night conversations and pizza"),
                Prompt(question: "The key to my heart is", answer: "Genuine kindness and humor")
            ]
        ),
        Person(
            name: "Emma",
            age: 22,
            height: "5'7\"",
            location: "Cambridge",
            distance: "1 mile away",
            status: "",
            company: "Apple",
            university: "MIT",
            images: [
                "https://picsum.photos/400/500?random=9",
                "https://picsum.photos/400/500?random=10",
                "https://picsum.photos/400/500?random=11",
                "https://picsum.photos/400/500?random=12"
            ],
            prompts: [
                Prompt(question: "I'm known for", answer: "Always having the best playlists"),
                Prompt(question: "My ideal Sunday", answer: "Farmers market, hiking, and cooking together"),
                Prompt(question: "I value", answer: "Authenticity and deep conversations"),
                Prompt(question: "Let's debate this topic", answer: "Pineapple on pizza (I'm team yes!)")
            ]
        )
    ]
    
    var currentPerson: Person? {
        guard currentPersonIndex < people.count else { return nil }
        return people[currentPersonIndex]
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            if let person = currentPerson {
                PersonCardView(person: person, dragOffset: dragOffset)
                    .offset(x: dragOffset.width, y: dragOffset.height * 0.1)
                    .rotationEffect(.degrees(dragOffset.width / 20))
                    .opacity(isAnimating ? 0 : 1)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                if abs(value.translation.width) > 100 {
                                    if value.translation.width > 0 {
                                        likeAction()
                                    } else {
                                        passAction()
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                
                // Floating X button
                VStack {
                    Spacer()
                    HStack {
                        Button(action: passAction) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Button(action: likeAction) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.green.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 40)
                }
            } else {
                // End of profiles
                VStack(spacing: 20) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("No more chillers nearby!")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text("Check back later for more profiles")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Animation overlays
            if showLikeAnimation {
                LikeAnimationView()
            }
            
            if showPassAnimation {
                PassAnimationView()
            }
        }
    }
    
    private func likeAction() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = true
            showLikeAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            nextPerson()
        }
    }
    
    private func passAction() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = true
            showPassAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            nextPerson()
        }
    }
    
    private func nextPerson() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPersonIndex += 1
            isAnimating = false
            showLikeAnimation = false
            showPassAnimation = false
            dragOffset = .zero
        }
    }
}

// MARK: - Person Card View

struct PersonCardView: View {
    let person: Person
    let dragOffset: CGSize
    @State private var currentImageIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with name and status
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(person.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("• \(person.status)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    
                    Text(person.distance)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // First image
                AsyncImage(url: URL(string: person.images[0])) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 400)
                        .overlay {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        }
                }
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Combined bio section
                VStack(spacing: 16) {
                    // Top row: Age, Height, Location - Horizontally scrollable
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Age
                            HStack(spacing: 6) {
                                Image(systemName: "birthday.cake")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("\(person.age)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .cornerRadius(8)
                            
                            // Height
                            HStack(spacing: 6) {
                                Image(systemName: "ruler")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text(person.height)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .cornerRadius(8)
                            
                            // Location
                            HStack(spacing: 6) {
                                Image(systemName: "location")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text(person.location)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                    
                    // University row
                    HStack(spacing: 8) {
                        Image(systemName: "graduationcap")
                            .font(.title2)
                            .foregroundColor(.primary)
                        
                        Text(person.university)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Interspersed images and prompts (starting from second image)
                ForEach(0 ..< max(person.images.count - 1, person.prompts.count), id: \.self) { index in
                    // Add image if available (skip first image since it's shown before bio)
                    if index + 1 < person.images.count {
                        AsyncImage(url: URL(string: person.images[index + 1])) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 400)
                                .overlay {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                                }
                        }
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    
                    // Add prompt if available
                    if index < person.prompts.count {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(person.prompts[index].question)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(person.prompts[index].answer)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
                
                // Bottom spacing
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 80)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Animation Views

struct LikeAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("chiller")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scale = 1.2
                    opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scale = 0.8
                        opacity = 0
                    }
                }
            }
        }
    }
}

struct PassAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "xmark")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scale = 1.2
                    opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scale = 0.8
                        opacity = 0
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
