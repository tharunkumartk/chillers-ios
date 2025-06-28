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
    let bio: String?
    let school: String?
    let company: String?
    let location: String?
    let height: Int? // in inches
    let gender: String?
    let sexuality: String?
    let age: Int?
    let profileImages: [String] // Array of image URLs
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case bio
        case school
        case company
        case location
        case height
        case gender
        case sexuality
        case age
        case profileImages = "profile_images"
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Database Event Model

struct DatabaseEvent: Codable, Identifiable {
    let id: UUID
    let hostId: UUID
    let title: String
    let description: String?
    let location: String?
    let eventDate: Date
    let eventTime: String?
    let imageUrl: String?
    let maxAttendees: Int?
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
        case maxAttendees = "max_attendees"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
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
        isBasicInfoComplete && profileImages.count >= 6 && prompts.count >= 3
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
