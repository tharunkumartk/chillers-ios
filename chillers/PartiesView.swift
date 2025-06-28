//
//  PartiesView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Parties View
struct PartiesView: View {
    @Environment(AppState.self) private var appState
    @State private var parties: [Party] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Logo and Title
                HStack {
                    HStack(spacing: 8) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        
                        Text("parties")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Removed non-working plus button
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color(.systemBackground))
                
                // Horizontally swipable parties
                TabView {
                    ForEach(parties) { party in
                        NavigationLink(destination: PartyDetailView(party: party)) {
                            PartyCardView(party: party)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .onAppear {
            loadMockParties()
        }
    }
    
    private func loadMockParties() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Mock attendees
        let attendees = [
            Attendee(name: "Sarah Johnson"),
            Attendee(name: "Mike Chen"),
            Attendee(name: "Emma Davis"),
            Attendee(name: "Jake Wilson"),
            Attendee(name: "Lisa Martinez"),
            Attendee(name: "Chris Brown"),
            Attendee(name: "Anna Kim"),
            Attendee(name: "David Lee")
        ]
        
        parties = [
            Party(
                title: "Alex's Birthday Bash",
                hostName: "Alex Rodriguez",
                date: formatter.date(from: "2025-06-28") ?? Date(),
                time: "9:00pm",
                imageURL: "https://picsum.photos/400/300?random=1",
                attendeesCount: 45,
                attendees: attendees,
                description: "Come celebrate Alex's birthday with an amazing night of music, dancing, and great vibes! We'll have a DJ, open bar, and tons of surprises throughout the night.",
                location: "123 Party Street, Downtown"
            )
        ]
    }
}

// MARK: - Party Card View
struct PartyCardView: View {
    let party: Party
    @Environment(\.colorScheme) var colorScheme
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: party.date)
    }
    
    private var cardGradient: LinearGradient {
        let gradients = [
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.mint.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.pink.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.8), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ]
        
        let index = abs(party.id.hashValue) % gradients.count
        return gradients[index]
    }
    
    private var buttonColor: Color {
        let colors: [Color] = [.yellow, .purple, .blue, .green, .red, .indigo, .teal]
        let index = abs(party.id.hashValue) % colors.count
        return colors[index].opacity(0.8)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with title
            VStack(alignment: .leading, spacing: 8) {
                Text(party.title)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Party Image
            AsyncImage(url: URL(string: party.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    )
            }
            .frame(height: 250)
            .clipped()
            
            // Date, Time, and Host Info
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(textColor)
                    
                    Text(party.time)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor.opacity(0.7))
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {
                        // Add to calendar action
                    }) {
                        Image(systemName: "calendar")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 44, height: 44)
                            .background(buttonColor)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        // Share action
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 44, height: 44)
                            .background(buttonColor)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                
                // Host info
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(textColor.opacity(0.6))
                    
                    Text("Hosted by")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor.opacity(0.6))
                    
                    Spacer()
                }
                
                HStack {
                    // Host avatar placeholder
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(party.hostName.prefix(1)))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(textColor)
                        )
                    
                    Text(party.hostName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    if party.attendeesCount > 0 {
                        Text("\(party.attendeesCount) going")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    PartiesView()
        .environment(AppState())
} 
