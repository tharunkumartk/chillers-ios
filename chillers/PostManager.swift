import Foundation
import Supabase

// MARK: - Post Manager

@Observable
class PostManager {
    static let shared = PostManager()
    
    private let supabase = SupabaseManager.shared.client
    
    private init() {}
    
    // MARK: - Post Operations
    
    /// Fetch posts with user votes
    func fetchPosts(limit: Int = 50) async throws -> [PostWithVote] {
        // First fetch all posts ordered by creation date
        let posts: [DatabasePost] = try await supabase
            .from("posts")
            .select()
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        
        // Get current user ID
        guard let currentUserId = try await getCurrentUserId() else {
            // If no user, return posts without vote information
            return posts.map { PostWithVote(post: $0, userVote: nil) }
        }
        
        // Fetch user votes for these posts
        let postIds = posts.map { $0.id }
        let userVotes: [PostVote] = try await supabase
            .from("post_votes")
            .select()
            .eq("user_id", value: currentUserId)
            .in("post_id", values: postIds)
            .execute()
            .value
        
        // Combine posts with votes
        return posts.map { post in
            let userVote = userVotes.first { $0.postId == post.id }
            return PostWithVote(post: post, userVote: userVote)
        }
    }
    
    /// Create a new post
    func createPost(content: String, isQuote: Bool = false, parentPostId: UUID? = nil) async throws -> DatabasePost {
        guard let currentUserId = try await getCurrentUserId() else {
            throw PostError.notAuthenticated
        }
        
        // Check if user is approved (required by RLS policy)
        guard try await SupabaseManager.shared.isCurrentUserApproved() else {
            throw PostError.notApproved
        }
        
        // Validate content length (max 250 characters as per schema)
        guard content.count <= 250 else {
            throw PostError.contentTooLong
        }
        
        let createRequest = CreatePostRequest(
            content: content,
            parentPostId: parentPostId,
            isQuote: isQuote
        )
        
        // Create the post data structure
        struct PostInsert: Codable {
            let authorId: String
            let content: String
            let parentPostId: String?
            let isQuote: Bool
            
            enum CodingKeys: String, CodingKey {
                case authorId = "author_id"
                case content
                case parentPostId = "parent_post_id"
                case isQuote = "is_quote"
            }
        }
        
        let postData = PostInsert(
            authorId: currentUserId.uuidString,
            content: createRequest.content,
            parentPostId: createRequest.parentPostId?.uuidString,
            isQuote: createRequest.isQuote
        )
        
        let newPost: DatabasePost = try await supabase
            .from("posts")
            .insert(postData)
            .select()
            .single()
            .execute()
            .value
        
        return newPost
    }
    
    /// Vote on a post
    func voteOnPost(postId: UUID, voteType: VoteType) async throws {
        guard let currentUserId = try await getCurrentUserId() else {
            throw PostError.notAuthenticated
        }
        
        // Check if user already voted on this post
        let existingVotes: [PostVote] = try await supabase
            .from("post_votes")
            .select()
            .eq("post_id", value: postId)
            .eq("user_id", value: currentUserId)
            .execute()
            .value
        
        if let existingVote = existingVotes.first {
            if existingVote.voteType == voteType {
                // Same vote type - remove the vote
                try await supabase
                    .from("post_votes")
                    .delete()
                    .eq("id", value: existingVote.id)
                    .execute()
            } else {
                // Different vote type - update the vote
                try await supabase
                    .from("post_votes")
                    .update([
                        "vote_type": voteType.rawValue
                    ])
                    .eq("id", value: existingVote.id)
                    .execute()
            }
        } else {
            // No existing vote - create new vote
            try await supabase
                .from("post_votes")
                .insert([
                    "post_id": postId.uuidString,
                    "user_id": currentUserId.uuidString,
                    "vote_type": voteType.rawValue
                ])
                .execute()
        }
    }
    
    /// Delete a post (only by author)
    func deletePost(postId: UUID) async throws {
        guard let currentUserId = try await getCurrentUserId() else {
            throw PostError.notAuthenticated
        }
        
        // Verify the current user is the author
        let post: DatabasePost = try await supabase
            .from("posts")
            .select()
            .eq("id", value: postId)
            .single()
            .execute()
            .value
        
        guard post.authorId == currentUserId else {
            throw PostError.notAuthorized
        }
        
        try await supabase
            .from("posts")
            .delete()
            .eq("id", value: postId)
            .execute()
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentUserId() async throws -> UUID? {
        let user = try await supabase.auth.user()
        return UUID(uuidString: user.id.uuidString)
    }
}

// MARK: - Post Errors

enum PostError: LocalizedError {
    case notAuthenticated
    case notAuthorized
    case notApproved
    case contentTooLong
    case invalidPostId
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .notAuthorized:
            return "You are not authorized to perform this action"
        case .notApproved:
            return "Your account must be approved before you can post"
        case .contentTooLong:
            return "Post content must be 250 characters or less"
        case .invalidPostId:
            return "Invalid post ID"
        }
    }
}
