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
    @State private var events: [DatabaseEvent] = []
    @State private var selectedTab = "Upcoming"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentUserId: UUID?
    
    private let supabaseManager = SupabaseManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Simple Header with Logo and Parties
                SimpleHeaderView()
                
                // Tabs
                CustomSegmentedControl(
                    selection: $selectedTab,
                    options: ["Upcoming", "Hosting", "Open invites"]
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Events ScrollView
                if isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text("Error loading events")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await loadEvents()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    // Horizontally scrollable events
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(filteredEvents) { event in
                                NavigationLink(destination: PartyDetailView(event: event)) {
                                    EventCardView(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Coming Soon Card - Always at the end
                            ComingSoonCardView()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .scrollDisabled(false)
                }
                
                Spacer()
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .task {
            await loadCurrentUser()
            await loadEvents()
        }
        .refreshable {
            await loadEvents()
        }
    }
    
    var filteredEvents: [DatabaseEvent] {
        switch selectedTab {
        case "Upcoming":
            return events.filter { $0.status == .upcoming && $0.eventDate >= Date() }
        case "Hosting":
            guard let currentUserId = currentUserId else { return [] }
            return events.filter {
                $0.hostId == currentUserId || $0.coHosts.contains(currentUserId)
            }
        case "Open invites":
            return events.filter { $0.isOpenInvite && $0.status == .upcoming }
        default:
            return events
        }
    }
    
    private func loadCurrentUser() async {
        do {
            let user = try await supabaseManager.currentUser
            currentUserId = user?.id
        } catch {
            print("Error loading current user: \(error)")
        }
    }
    
    private func loadEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await supabaseManager.fetchEvents()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error loading events: \(error)")
        }
    }
}

// MARK: - Simple Header View

struct SimpleHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Text("parties")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.black)
    }
}

// MARK: - Event Card View

struct EventCardView: View {
    let event: DatabaseEvent
    @Environment(\.colorScheme) var colorScheme
    @State private var hostName: String = "Loading..."
    @State private var attendeeCount: Int = 0
    @State private var currentUserStatus: AttendeeStatus?
    
    private let supabaseManager = SupabaseManager.shared
    
    private var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(event.eventDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(event.eventDate) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: event.eventDate)
        }
    }
    
    private var statusColor: Color {
        switch currentUserStatus {
        case .going:
            return .blue
        case .maybe:
            return .orange
        case .notGoing:
            return .red
        case .none:
            return .gray
        case .waitlist:
            return .gray
        }
    }
    
    private var statusText: String {
        switch currentUserStatus {
        case .going:
            return "GOING"
        case .maybe:
            return "MAYBE"
        case .notGoing:
            return "NOT GOING"
        case .waitlist: 
            return "WAITLIST"
        case .none:
            return "RSVP"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: event.imageUrl ?? "")) { image in
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
                .frame(width: 280, height: 200)
                .clipped()
                
                // Status Badge
                Text(statusText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 12)
                    .padding(.trailing, 12)
            }
            
            // Event Details
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(event.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Date and Time
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let eventTime = event.eventTime {
                        Text("• \(eventTime)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                // Host info
                HStack {
                    Text("Hosted by")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack {
                    // Host avatar
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(String(hostName.prefix(1)))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                        )
                    
                    Text(hostName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("BS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(width: 280)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .task {
            await loadEventData()
        }
    }
    
    private func loadEventData() async {
        async let hostNameTask = loadHostName()
        async let attendeeCountTask = loadAttendeeCount()
        async let statusTask = loadCurrentUserStatus()
        
        await hostNameTask
        await attendeeCountTask
        await statusTask
    }
    
    private func loadHostName() async {
        do {
            if let user = try await supabaseManager.getDatabaseUser(userId: event.hostId) {
                hostName = user.name ?? "Unknown Host"
            }
        } catch {
            print("Error loading host name: \(error)")
            hostName = "Unknown Host"
        }
    }
    
    private func loadAttendeeCount() async {
        do {
            let attendees = try await supabaseManager.getEventAttendees(eventId: event.id)
            attendeeCount = attendees.filter { $0.status == .going }.count
        } catch {
            print("Error loading attendee count: \(error)")
            attendeeCount = 0
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
}

// MARK: - Coming Soon Card View

struct ComingSoonCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Placeholder Image
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(width: 280, height: 200)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("New")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                )
            
            // Coming Soon Details
            VStack(alignment: .leading, spacing: 12) {
                Text("Coming Soon...")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.secondary)
                
                Text("Stay tuned for more events!")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("More parties on the way")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(width: 280)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                .foregroundColor(.gray.opacity(0.5))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Custom Segmented Control

struct CustomSegmentedControl: View {
    @Binding var selection: String
    let options: [String]
    
    private func getDisplayText(for option: String) -> String {
        switch option {
        case "Upcoming":
            return "Upcoming 1"
        case "Hosting":
            return "Hosting 0"
        case "Open invites":
            return "Open"
        default:
            return option
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(getDisplayText(for: option))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selection == option ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selection == option ? Color.accentColor : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    PartiesView()
        .environment(AppState())
}
