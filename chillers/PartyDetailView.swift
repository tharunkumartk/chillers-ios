//
//  PartyDetailView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Party Detail View
struct PartyDetailView: View {
    let event: DatabaseEvent
    @Environment(\.dismiss) private var dismiss
    @State private var hostName: String = "chillers app"
    @State private var attendees: [EventAttendee] = []
    @State private var currentUserStatus: AttendeeStatus?
    @State private var isLoading = false
    @State private var isEditingRSVP = false
    
    private let supabaseManager = SupabaseManager.shared
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: event.eventDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    // Title above image
                    VStack(alignment: .leading, spacing: 12) {
                        Text(event.title)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Hero Image with date/time pills overlay
                AsyncImage(url: URL(string: event.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        )
                }
                .frame(height: 300)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    // Date and time pills overlay
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                // Date pill
                                Text(formattedDate)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Capsule())
                                
                                // Time pill (if available)
                                if let eventTime = event.eventTime {
                                    Text(eventTime)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.7))
                                        .clipShape(Capsule())
                                }
                            }
                            Spacer()
                        }
                        .padding(16)
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Additional event details
                    VStack(alignment: .leading, spacing: 8) {
                        if let location = event.location, !location.isEmpty {
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.accentColor)
                                Text(location)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Spots info
                        if let totalSpots = event.totalSpots, let remaining = event.spotsRemaining {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.accentColor)
                                Text("\(remaining) of \(totalSpots) spots remaining")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // RSVP Deadline
                        if let deadline = event.rsvpDeadline {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.accentColor)
                                Text("RSVP by \(deadline, style: .date)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Host Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hosted by")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(hostName.prefix(1).uppercased()))
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(hostName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Event Host")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Co-hosts
                    if !event.coHosts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Co-hosts")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("\(event.coHosts.count) co-host(s)")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Theme
                    if let theme = event.theme, !theme.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Theme")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(theme)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Description
                    if let description = event.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(description)
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
                            
                            Text("\(attendees.filter { $0.status == .going }.count) people")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                        
                        if isLoading {
                            ProgressView("Loading attendees...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        } else if attendees.filter({ $0.status == .going }).isEmpty {
                            Text("No one has joined yet. Be the first!")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(attendees.filter { $0.status == .going }) { attendee in
                                    EventAttendeeCardView(attendee: attendee)
                                }
                            }
                        }
                    }
                    
                    // RSVP Section
                    VStack(alignment: .leading, spacing: 16) {
                        if let status = currentUserStatus, !isEditingRSVP {
                            HStack {
                                Text(status.rawValue.capitalized)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button {
                                    isEditingRSVP = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pencil")
                                        Text("Edit your RSVP")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    Button {
                                        Task {
                                            await updateRSVP(.going)
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "hand.thumbsup.fill")
                                            Text("Going")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.accentColor)
                                        .cornerRadius(12)
                                    }
                                    
                                    Button {
                                        Task {
                                            await updateRSVP(.maybe)
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "questionmark.circle.fill")
                                            Text("Maybe")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.accentColor)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                
                                Button {
                                    Task {
                                        await updateRSVP(.notGoing)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Can't Go")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadEventData()
        }
    }
    
    private func loadEventData() async {
        isLoading = true
        
        async let hostNameTask = loadHostName()
        async let attendeesTask = loadAttendees()
        async let userStatusTask = loadCurrentUserStatus()
        
        await hostNameTask
        await attendeesTask
        await userStatusTask
        
        isLoading = false
    }
    
    private func loadHostName() async {
        do {
            if let user = try await supabaseManager.getDatabaseUser(userId: event.hostId) {
                hostName = user.name ?? "chillers app"
            }
        } catch {
            print("Error loading host name: \(error)")
            hostName = "chillers app"
        }
    }
    
    private func loadAttendees() async {
        do {
            attendees = try await supabaseManager.getEventAttendees(eventId: event.id)
        } catch {
            print("Error loading attendees: \(error)")
            attendees = []
        }
    }
    
    private func loadCurrentUserStatus() async {
        do {
            currentUserStatus = try await supabaseManager.getCurrentUserAttendanceStatus(eventId: event.id)
        } catch {
            print("Error loading current user status: \(error)")
            currentUserStatus = nil
        }
    }
    
    private func updateRSVP(_ status: AttendeeStatus) async {
        do {
            try await supabaseManager.updateEventAttendance(eventId: event.id, status: status)
            currentUserStatus = status
            isEditingRSVP = false
            // Reload attendees to update the count
            await loadAttendees()
        } catch {
            print("Error updating RSVP: \(error)")
        }
    }
}

// MARK: - Event Attendee Card View
struct EventAttendeeCardView: View {
    let attendee: EventAttendee
    @State private var userName: String = "Loading..."
    
    private let supabaseManager = SupabaseManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.accentColor.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(userName.prefix(1)))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(userName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if attendee.status != .going {
                    Text(attendee.status.rawValue.capitalized)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            await loadUserName()
        }
    }
    
    private func loadUserName() async {
        do {
            if let user = try await supabaseManager.getDatabaseUser(userId: attendee.userId) {
                userName = user.name ?? "Unknown User"
            }
        } catch {
            print("Error loading user name: \(error)")
            userName = "Unknown User"
        }
    }
}

#Preview {
    let sampleEvent = DatabaseEvent(
        id: UUID(),
        hostId: UUID(),
        title: "Alex's Birthday Bash",
        description: "Come celebrate Alex's birthday with an amazing night of music, dancing, and great vibes! We'll have a DJ, open bar, and tons of surprises throughout the night.",
        location: "123 Party Street, San Francisco",
        eventDate: Date(),
        eventTime: "9:00pm",
        imageUrl: "https://picsum.photos/400/300?random=1",
        spotsRemaining: 5,
        totalSpots: 50,
        rsvpDeadline: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
        coHosts: [],
        waitlistEnabled: true,
        isOpenInvite: false,
        theme: "Birthday Party",
        status: .upcoming,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    NavigationStack {
        PartyDetailView(event: sampleEvent)
    }
} 