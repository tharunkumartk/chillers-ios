import Foundation
import Supabase
import UIKit

// MARK: - Database User Model

struct DatabaseUser: Codable, Identifiable {
    let id: UUID
    let phoneNumber: String
    let name: String?
    let profileComplete: Bool
    let approvalStatus: ApprovalStatus
    let vouchCount: Int
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber = "phone_number"
        case name
        case profileComplete = "profile_complete"
        case approvalStatus = "approval_status"
        case vouchCount = "vouch_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ApprovalStatus: String, Codable, CaseIterable {
    case pending
    case approved
    case rejected
}

// MARK: - User Profile Model

struct UserProfile: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let firstName: String?
    let lastName: String?
    let height: String? // stored as string like "5'8""
    let age: Int?
    let company: String?
    let school: String?
    let bio: String?
    let location: String?
    let gender: String?
    let sexuality: String?
    let profileImages: [String] // Array of image URLs
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case height
        case age
        case company
        case school
        case bio
        case location
        case gender
        case sexuality
        case profileImages = "profile_images"
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Event Model

struct DatabaseEvent: Codable, Identifiable, Hashable {
    let id: UUID
    let hostId: UUID
    let title: String
    let description: String?
    let location: String?
    let eventDate: Date
    let eventTime: String?
    let imageUrl: String?
    // New fields
    let spotsRemaining: Int?
    let totalSpots: Int?
    let rsvpDeadline: Date?
    let coHosts: [UUID]
    let waitlistEnabled: Bool
    let isOpenInvite: Bool
    let theme: String?
    let status: EventStatus
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case hostId = "host_id"
        case title
        case description
        case location
        case eventDate = "event_date"
        case eventTime = "event_time"
        case imageUrl = "image_url"
        case spotsRemaining = "spots_remaining"
        case totalSpots = "total_spots"
        case rsvpDeadline = "rsvp_deadline"
        case coHosts = "co_hosts"
        case waitlistEnabled = "waitlist_enabled"
        case isOpenInvite = "is_open_invite"
        case theme
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Regular initializer for programmatic creation (previews, etc.)
    init(
        id: UUID,
        hostId: UUID,
        title: String,
        description: String? = nil,
        location: String? = nil,
        eventDate: Date,
        eventTime: String? = nil,
        imageUrl: String? = nil,
        spotsRemaining: Int? = nil,
        totalSpots: Int? = nil,
        rsvpDeadline: Date? = nil,
        coHosts: [UUID] = [],
        waitlistEnabled: Bool = false,
        isOpenInvite: Bool = false,
        theme: String? = nil,
        status: EventStatus,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.hostId = hostId
        self.title = title
        self.description = description
        self.location = location
        self.eventDate = eventDate
        self.eventTime = eventTime
        self.imageUrl = imageUrl
        self.spotsRemaining = spotsRemaining
        self.totalSpots = totalSpots
        self.rsvpDeadline = rsvpDeadline
        self.coHosts = coHosts
        self.waitlistEnabled = waitlistEnabled
        self.isOpenInvite = isOpenInvite
        self.theme = theme
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Custom decoder to handle multiple date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        hostId = try container.decode(UUID.self, forKey: .hostId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        eventTime = try container.decodeIfPresent(String.self, forKey: .eventTime)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        spotsRemaining = try container.decodeIfPresent(Int.self, forKey: .spotsRemaining)
        totalSpots = try container.decodeIfPresent(Int.self, forKey: .totalSpots)
        coHosts = try container.decode([UUID].self, forKey: .coHosts)
        waitlistEnabled = try container.decode(Bool.self, forKey: .waitlistEnabled)
        isOpenInvite = try container.decode(Bool.self, forKey: .isOpenInvite)
        theme = try container.decodeIfPresent(String.self, forKey: .theme)
        status = try container.decode(EventStatus.self, forKey: .status)
        
        // Custom date decoding for eventDate
        let eventDateString = try container.decode(String.self, forKey: .eventDate)
        eventDate = try Self.decodeDate(from: eventDateString)
        
        // Custom date decoding for rsvpDeadline
        if let rsvpDeadlineString = try container.decodeIfPresent(String.self, forKey: .rsvpDeadline) {
            rsvpDeadline = try Self.decodeDate(from: rsvpDeadlineString)
        } else {
            rsvpDeadline = nil
        }
        
        // Custom date decoding for createdAt and updatedAt
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = try Self.decodeDate(from: createdAtString)
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = try Self.decodeDate(from: updatedAtString)
    }
    
    // Helper method to decode dates with multiple possible formats
    private static func decodeDate(from dateString: String) throws -> Date {
        // Date formatters for different possible formats
        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
        dateOnlyFormatter.timeZone = TimeZone.current
        
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let iso8601FormatterNoFractional = ISO8601DateFormatter()
        iso8601FormatterNoFractional.formatOptions = [.withInternetDateTime]
        
        // Try different date formats
        if let date = dateOnlyFormatter.date(from: dateString) {
            return date
        } else if let date = iso8601Formatter.date(from: dateString) {
            return date
        } else if let date = iso8601FormatterNoFractional.date(from: dateString) {
            return date
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid date format: \(dateString)"
                )
            )
        }
    }
}

enum EventStatus: String, Codable, Hashable {
    case upcoming
    case past
    case cancelled
}

// MARK: - Event Attendee Model

struct EventAttendee: Codable, Identifiable {
    let id: UUID
    let eventId: UUID
    let userId: UUID
    let status: AttendeeStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case status
        case createdAt = "created_at"
    }
}

enum AttendeeStatus: String, Codable, Hashable {
    case going
    case maybe
    case notGoing = "not_going"
    case waitlist
}

// MARK: - Database Post Model

struct DatabasePost: Codable, Identifiable {
    let id: UUID
    let authorId: UUID
    let content: String
    let upvotes: Int
    let downvotes: Int
    let parentPostId: UUID?
    let isQuote: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case content
        case upvotes
        case downvotes
        case parentPostId = "parent_post_id"
        case isQuote = "is_quote"
        case createdAt = "created_at"
    }
}

// MARK: - Post Vote Model

struct PostVote: Codable, Identifiable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let voteType: VoteType
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case voteType = "vote_type"
        case createdAt = "created_at"
    }
}

enum VoteType: String, Codable, CaseIterable {
    case upvote
    case downvote
}

// MARK: - Post with User Vote Model (for UI)

struct PostWithVote: Identifiable {
    let post: DatabasePost
    let userVote: PostVote?

    var id: UUID { post.id }

    var displayUpvotes: Int {
        post.upvotes
    }

    var displayDownvotes: Int {
        post.downvotes
    }

    var userVoteType: VoteType? {
        userVote?.voteType
    }
}

// MARK: - Create Post Request Model

struct CreatePostRequest: Codable {
    let content: String
    let parentPostId: UUID?
    let isQuote: Bool

    enum CodingKeys: String, CodingKey {
        case content
        case parentPostId = "parent_post_id"
        case isQuote = "is_quote"
    }
}

// MARK: - Onboarding Data Model

struct OnboardingData {
    var firstName: String = ""
    var lastName: String = ""
    var height: String = ""
    var age: String = ""
    var company: String = ""
    var school: String = ""
    var profileImages: [UIImage] = []
    var prompts: [PromptResponse] = []

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var isBasicInfoComplete: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !height.isEmpty && !age.isEmpty && 
        !company.isEmpty && !school.isEmpty
    }

    var isComplete: Bool {
        isBasicInfoComplete && profileImages.filter { !$0.size.equalTo(.zero) }.count >= 4 && prompts.count >= 3
    }
}

// MARK: - Prompt Response Model

struct PromptResponse: Identifiable {
    let id = UUID()
    var question: String = ""
    var answer: String = ""

    var isComplete: Bool {
        !question.isEmpty && !answer.isEmpty
    }
}

// MARK: - Prompt Options

struct PromptOption {
    let text: String
    let category: String
}

extension PromptOption {
    static let defaultPrompts: [PromptOption] = [
        PromptOption(text: "My simple pleasures", category: "Lifestyle"),
        PromptOption(text: "I'm looking for", category: "Dating"),
        PromptOption(text: "My love language is", category: "Personality"),
        PromptOption(text: "You should leave a comment if", category: "Dating"),
        PromptOption(text: "Two truths and a lie", category: "Fun"),
        PromptOption(text: "My greatest strength", category: "Personality"),
        PromptOption(text: "I go crazy for", category: "Interests"),
        PromptOption(text: "The key to my heart is", category: "Dating"),
        PromptOption(text: "I'm known for", category: "Personality"),
        PromptOption(text: "My ideal Sunday", category: "Lifestyle"),
        PromptOption(text: "I value", category: "Values"),
        PromptOption(text: "Let's debate this topic", category: "Fun"),
        PromptOption(text: "My biggest goal right now", category: "Ambition"),
        PromptOption(text: "I'm weirdly attracted to", category: "Fun"),
        PromptOption(text: "My most controversial opinion", category: "Personality")
    ]
}
