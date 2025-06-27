//
//  PartyDetailView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Party Detail View
struct PartyDetailView: View {
    let party: Party
    @Environment(\.dismiss) private var dismiss
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: party.date)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
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
                .frame(height: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 24) {
                    // Title and basic info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(party.title)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.yellow)
                                Text("\(formattedDate) at \(party.time)")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            
                            if !party.location.isEmpty {
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.yellow)
                                    Text(party.location)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Host Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Host")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(party.hostName.prefix(1)))
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(party.hostName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Party Host")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Description
                    if !party.description.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(party.description)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    }
                    
                    // Attendees Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Who's Going")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(party.attendeesCount) people")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.yellow)
                        }
                        
                        if !party.attendees.isEmpty {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                ForEach(party.attendees) { attendee in
                                    AttendeeCardView(attendee: attendee)
                                }
                            }
                        } else {
                            Text("No one has joined yet. Be the first!")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    // Info about viewing party details
                    Text("Party details for viewing only")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .background(Circle().fill(Color(.systemGray5)).frame(width: 32, height: 32))
                }
            }
            
            // Removed non-working share button
        }
    }
}

// MARK: - Attendee Card View
struct AttendeeCardView: View {
    let attendee: Attendee
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatarURL = attendee.avatarURL, !avatarURL.isEmpty {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray4))
                        .overlay(
                            Text(String(attendee.name.prefix(1)))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(attendee.name.prefix(1)))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    )
            }
            
            Text(attendee.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let sampleAttendees = [
        Attendee(name: "Sarah Johnson"),
        Attendee(name: "Mike Chen"),
        Attendee(name: "Emma Davis"),
        Attendee(name: "Alex Rodriguez")
    ]
    
    let sampleParty = Party(
        title: "Alex's Birthday Bash",
        hostName: "Alex Rodriguez",
        date: Date(),
        time: "9:00pm",
        imageURL: "https://picsum.photos/400/300?random=1",
        attendeesCount: 45,
        attendees: sampleAttendees,
        description: "Come celebrate Alex's birthday with an amazing night of music, dancing, and great vibes! We'll have a DJ, open bar, and tons of surprises throughout the night.",
        location: "123 Party Street, San Francisco"
    )
    
    NavigationStack {
        PartyDetailView(party: sampleParty)
    }
} 