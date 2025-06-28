//
//  ExploreView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Models

struct Post: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let content: String
    let timestamp: String
    let upvotes: Int
    let isEvent: Bool
    let comments: [Comment]
    
    var commentCount: Int {
        comments.count
    }
}

struct Comment: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let content: String
    let timestamp: String
    let upvotes: Int
}

// MARK: - User Interactions

struct UserInteraction {
    var isLiked: Bool = false
    var isDisliked: Bool = false
    var isSaved: Bool = false
    var userUpvotes: Int = 0 // Track the user's contribution to upvotes (+1, 0, or -1)
}

// MARK: - User Comments

struct UserComment: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let content: String
    let timestamp: String
    let upvotes: Int
    
    init(content: String) {
        self.author = "Anonymous"
        self.content = content
        self.timestamp = "now"
        self.upvotes = 0
    }
}

// MARK: - Sample Data

extension Post {
    static let samplePosts: [Post] = [
        Post(
            author: "Anonymous",
            content: "Overheard these two construction workers today and one goes \"man being black in America is building everything and getting yo bones crushed in return\" 😭",
            timestamp: "5hrs",
            upvotes: 130,
            isEvent: false,
            comments: [
                Comment(author: "Anonymous", content: "That's deep fr", timestamp: "4hrs", upvotes: 23),
                Comment(author: "Anonymous", content: "Construction workers have the best philosophical takes", timestamp: "3hrs", upvotes: 45),
                Comment(author: "Anonymous", content: "Real talk though", timestamp: "2hrs", upvotes: 12)
            ]
        ),
        Post(
            author: "Anonymous",
            content: "Grief is the body's way of telling you That you are holding onto something that is not yours to protect / find happiness from.",
            timestamp: "8hrs",
            upvotes: 293,
            isEvent: true,
            comments: [
                Comment(author: "Anonymous", content: "I'm really sad and I'm crying 😭😭😭\nDoes anyone have any nice quotes for when you no feel happy", timestamp: "7hrs", upvotes: 156),
                Comment(author: "Anonymous", content: "This helped me today, thank you", timestamp: "6hrs", upvotes: 78),
                Comment(author: "Anonymous", content: "Saving this for later", timestamp: "5hrs", upvotes: 34)
            ]
        ),
        Post(
            author: "Anonymous",
            content: "Anyone else think the dining hall is serving straight up prison food lately? Like what is this gray substance they're calling chicken 💀",
            timestamp: "12hrs",
            upvotes: 85,
            isEvent: false,
            comments: [
                Comment(author: "Anonymous", content: "LMAOOO facts the mac and cheese looked radioactive yesterday", timestamp: "11hrs", upvotes: 67),
                Comment(author: "Anonymous", content: "Y'all are dramatic it's not that bad", timestamp: "10hrs", upvotes: 12),
                Comment(author: "Anonymous", content: "RIP my meal plan money", timestamp: "9hrs", upvotes: 34)
            ]
        )
    ]
}

// MARK: - Main Explore View

struct ExploreView: View {
    @State private var posts: [PostWithVote] = []
    @State private var showingCreatePost = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let postManager = PostManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Header with Logo and Title
                    HStack {
                        HStack(spacing: 8) {
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                            
                            Text("confessions")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Removed non-working message button
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(Color(.systemBackground))
                    
                    // Posts Feed
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if isLoading {
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("Loading confessions...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                            } else if let errorMessage = errorMessage {
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.orange)
                                    Text("Oops!")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(errorMessage)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    Button("Try Again") {
                                        Task {
                                            await loadPosts()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding(.horizontal, 40)
                                .padding(.top, 50)
                            } else if posts.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "bubble.left.and.text.bubble.right")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary)
                                    Text("No confessions yet")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                    Text("Be the first to share something!")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 100)
                            } else {
                                ForEach(posts) { postWithVote in
                                    NavigationLink(destination: DatabasePostDetailView(
                                        postWithVote: postWithVote,
                                        onPostUpdated: {
                                            Task {
                                                await loadPosts()
                                            }
                                        }
                                    )) {
                                        DatabasePostRowView(
                                            postWithVote: postWithVote,
                                            onLike: {
                                                handleVoteOptimistic(postId: postWithVote.id, voteType: .upvote)
                                            },
                                            onDislike: {
                                                handleVoteOptimistic(postId: postWithVote.id, voteType: .downvote)
                                            }
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Prevents NavigationLink styling
                                    
                                    Divider()
                                        .background(Color(.systemGray4))
                                }
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                }
                .background(Color(.systemBackground))
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCreatePost = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadPosts()
            }
        }
        .refreshable {
            await loadPosts()
        }
        .sheet(isPresented: $showingCreatePost) {
            DatabaseCreatePostView {
                await loadPosts() // Reload posts after creating
            }
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func loadPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await postManager.fetchPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // New optimistic voting method - immediate UI update, background sync
    @MainActor
    private func handleVoteOptimistic(postId: UUID, voteType: VoteType) {
        // Find the post index
        guard let postIndex = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        let currentPost = posts[postIndex]
        let currentVoteType = currentPost.userVoteType
        
        // Create optimistically updated post
        let updatedPost = createOptimisticUpdate(for: currentPost, with: voteType)
        
        // Update local state immediately
        posts[postIndex] = updatedPost
        
        // Sync with server in background
        Task {
            do {
                try await postManager.voteOnPost(postId: postId, voteType: voteType)
                // Success - no need to do anything as optimistic update was correct
            } catch {
                // Revert optimistic update on failure (MVP: probably won't happen)
                await MainActor.run {
                    // Revert to original state
                    posts[postIndex] = currentPost
                }
                print("Error voting on post: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper to create optimistic update
    private func createOptimisticUpdate(for postWithVote: PostWithVote, with newVoteType: VoteType) -> PostWithVote {
        let currentVoteType = postWithVote.userVoteType
        
        // Calculate new vote counts
        var newUpvotes = postWithVote.post.upvotes
        var newDownvotes = postWithVote.post.downvotes
        
        // Remove previous vote effect
        if let currentVote = currentVoteType {
            switch currentVote {
            case .upvote:
                newUpvotes -= 1
            case .downvote:
                newDownvotes -= 1
            }
        }
        
        // Apply new vote effect (toggle off if same vote type)
        let finalVoteType: VoteType?
        if currentVoteType == newVoteType {
            // Same vote type - toggle off
            finalVoteType = nil
        } else {
            // Different vote type or no previous vote
            finalVoteType = newVoteType
            switch newVoteType {
            case .upvote:
                newUpvotes += 1
            case .downvote:
                newDownvotes += 1
            }
        }
        
        // Create updated post
        let updatedPost = DatabasePost(
            id: postWithVote.post.id,
            authorId: postWithVote.post.authorId,
            content: postWithVote.post.content,
            upvotes: newUpvotes,
            downvotes: newDownvotes,
            parentPostId: postWithVote.post.parentPostId,
            isQuote: postWithVote.post.isQuote,
            createdAt: postWithVote.post.createdAt
        )
        
        // Create updated vote
        let updatedVote: PostVote? = finalVoteType.map { voteType in
            PostVote(
                id: postWithVote.userVote?.id ?? UUID(),
                postId: postWithVote.post.id,
                userId: postWithVote.userVote?.userId ?? UUID(), // This should be the current user ID
                voteType: voteType,
                createdAt: Date()
            )
        }
        
        return PostWithVote(post: updatedPost, userVote: updatedVote)
    }
}

// MARK: - Database Post Row View

struct DatabasePostRowView: View {
    let postWithVote: PostWithVote
    let onLike: () -> Void
    let onDislike: () -> Void
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: postWithVote.post.createdAt, relativeTo: Date())
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Voting Section
            VStack(spacing: 8) {
                Button(action: onLike) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .foregroundColor(postWithVote.userVoteType == .upvote ? .accent : .secondary)
                        .font(.system(size: 20))
                }
                    
                Text("\(postWithVote.displayUpvotes)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accent)
                    
                Button(action: onDislike) {
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(postWithVote.userVoteType == .downvote ? .red : .secondary)
                        .font(.system(size: 20))
                }
            }
            .padding(.trailing, 8)
                
            // Content Section
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    if postWithVote.post.isQuote {
                        Text("QUOTE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accent)
                            .cornerRadius(12)
                    }
                        
                    Text("Anonymous")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        
                    Text(timeAgo)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        
                    Spacer()
                }
                    
                // Post Content
                Text(postWithVote.post.content)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                // Action Buttons
                HStack(spacing: 20) {
                    // Bookmark placeholder
                    Button(action: {}) {
                        Image(systemName: "bookmark")
                            .foregroundColor(.secondary)
                    }
                        
                    // Comments indicator
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                        Text("Comment")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                        
                    Spacer()
                }
                .font(.system(size: 16))
            }
                
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Database Post Detail View

struct DatabasePostDetailView: View {
    let postWithVote: PostWithVote
    let onPostUpdated: () -> Void
    
    @State private var comments: [PostWithVote] = []
    @State private var isLoadingComments = false
    @State private var showingAddComment = false
    @State private var errorMessage: String?
    @State private var currentPost: PostWithVote
    
    private let postManager = PostManager.shared
    
    init(postWithVote: PostWithVote, onPostUpdated: @escaping () -> Void) {
        self.postWithVote = postWithVote
        self.onPostUpdated = onPostUpdated
        self._currentPost = State(initialValue: postWithVote)
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: currentPost.post.createdAt, relativeTo: Date())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Original Post
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            // Voting Section
                            VStack(spacing: 8) {
                                Button(action: {
                                    handleVoteOptimistic(postId: currentPost.id, voteType: .upvote, isComment: false)
                                }) {
                                    Image(systemName: "arrowtriangle.up.fill")
                                        .foregroundColor(currentPost.userVoteType == .upvote ? .accent : .secondary)
                                        .font(.system(size: 20))
                                }
                                    
                                Text("\(currentPost.displayUpvotes)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.accent)
                                    
                                Button(action: {
                                    handleVoteOptimistic(postId: currentPost.id, voteType: .downvote, isComment: false)
                                }) {
                                    Image(systemName: "arrowtriangle.down.fill")
                                        .foregroundColor(currentPost.userVoteType == .downvote ? .red : .secondary)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.trailing, 8)
                                
                            // Content Section
                            VStack(alignment: .leading, spacing: 8) {
                                // Header
                                HStack {
                                    if currentPost.post.isQuote {
                                        Text("QUOTE")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.accent)
                                            .cornerRadius(12)
                                    }
                                        
                                    Text("Anonymous")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                        
                                    Text(timeAgo)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        
                                    Spacer()
                                }
                                    
                                // Post Content
                                Text(currentPost.post.content)
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                                
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .background(Color(.systemGray4))
                        .padding(.vertical, 8)
                    
                    // Comments Section Header
                    HStack {
                        Text("Comments")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("(\(comments.count))")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: { showingAddComment = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.message")
                                Text("Add")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.accent)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    // Comments List
                    if isLoadingComments {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading comments...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else if comments.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "message")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                            Text("No comments yet")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Text("Be the first to share your thoughts!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        ForEach(comments) { commentWithVote in
                            DatabaseCommentRowView(
                                commentWithVote: commentWithVote,
                                onLike: {
                                    handleVoteOptimistic(postId: commentWithVote.id, voteType: .upvote, isComment: true)
                                },
                                onDislike: {
                                    handleVoteOptimistic(postId: commentWithVote.id, voteType: .downvote, isComment: true)
                                }
                            )
                            
                            if commentWithVote.id != comments.last?.id {
                                Divider()
                                    .background(Color(.systemGray5))
                                    .padding(.leading, 50)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
        }
        .onAppear {
            Task {
                await loadComments()
            }
        }
        .sheet(isPresented: $showingAddComment) {
            DatabaseCreateCommentView(parentPost: currentPost) {
                await loadComments()
                onPostUpdated()
            }
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func loadComments() async {
        isLoadingComments = true
        errorMessage = nil
        
        do {
            // Load comments for this post (posts with parentPostId equal to this post's id)
            comments = try await postManager.fetchComments(for: currentPost.post.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingComments = false
    }
    
    // Optimistic voting for both main post and comments
    @MainActor
    private func handleVoteOptimistic(postId: UUID, voteType: VoteType, isComment: Bool) {
        if isComment {
            // Handle comment voting
            guard let commentIndex = comments.firstIndex(where: { $0.id == postId }) else { return }
            
            let currentComment = comments[commentIndex]
            let updatedComment = createOptimisticUpdate(for: currentComment, with: voteType)
            
            // Update local state immediately
            comments[commentIndex] = updatedComment
            
            // Sync with server in background
            Task {
                do {
                    try await postManager.voteOnPost(postId: postId, voteType: voteType)
                    // Success - optimistic update was correct
                } catch {
                    // Revert optimistic update on failure
                    await MainActor.run {
                        comments[commentIndex] = currentComment
                    }
                    print("Error voting on comment: \(error.localizedDescription)")
                }
            }
        } else {
            // Handle main post voting
            let originalPost = currentPost
            let updatedPost = createOptimisticUpdate(for: currentPost, with: voteType)
            
            // Update local state immediately
            currentPost = updatedPost
            
            // Sync with server in background
            Task {
                do {
                    try await postManager.voteOnPost(postId: postId, voteType: voteType)
                    // Success - optimistic update was correct
                    onPostUpdated() // Notify parent to update its state
                } catch {
                    // Revert optimistic update on failure
                    await MainActor.run {
                        currentPost = originalPost
                    }
                    print("Error voting on post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Helper to create optimistic update (same as in ExploreView)
    private func createOptimisticUpdate(for postWithVote: PostWithVote, with newVoteType: VoteType) -> PostWithVote {
        let currentVoteType = postWithVote.userVoteType
        
        // Calculate new vote counts
        var newUpvotes = postWithVote.post.upvotes
        var newDownvotes = postWithVote.post.downvotes
        
        // Remove previous vote effect
        if let currentVote = currentVoteType {
            switch currentVote {
            case .upvote:
                newUpvotes -= 1
            case .downvote:
                newDownvotes -= 1
            }
        }
        
        // Apply new vote effect (toggle off if same vote type)
        let finalVoteType: VoteType?
        if currentVoteType == newVoteType {
            // Same vote type - toggle off
            finalVoteType = nil
        } else {
            // Different vote type or no previous vote
            finalVoteType = newVoteType
            switch newVoteType {
            case .upvote:
                newUpvotes += 1
            case .downvote:
                newDownvotes += 1
            }
        }
        
        // Create updated post
        let updatedPost = DatabasePost(
            id: postWithVote.post.id,
            authorId: postWithVote.post.authorId,
            content: postWithVote.post.content,
            upvotes: newUpvotes,
            downvotes: newDownvotes,
            parentPostId: postWithVote.post.parentPostId,
            isQuote: postWithVote.post.isQuote,
            createdAt: postWithVote.post.createdAt
        )
        
        // Create updated vote
        let updatedVote: PostVote? = finalVoteType.map { voteType in
            PostVote(
                id: postWithVote.userVote?.id ?? UUID(),
                postId: postWithVote.post.id,
                userId: postWithVote.userVote?.userId ?? UUID(), // This should be the current user ID
                voteType: voteType,
                createdAt: Date()
            )
        }
        
        return PostWithVote(post: updatedPost, userVote: updatedVote)
    }
}

// MARK: - Database Comment Row View

struct DatabaseCommentRowView: View {
    let commentWithVote: PostWithVote
    let onLike: () -> Void
    let onDislike: () -> Void
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: commentWithVote.post.createdAt, relativeTo: Date())
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Smaller voting section for comments
            VStack(spacing: 6) {
                Button(action: onLike) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .foregroundColor(commentWithVote.userVoteType == .upvote ? .accent : .secondary)
                        .font(.system(size: 16))
                }
                    
                Text("\(commentWithVote.displayUpvotes)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.accent)
                    
                Button(action: onDislike) {
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(commentWithVote.userVoteType == .downvote ? .red : .secondary)
                        .font(.system(size: 16))
                }
            }
            .padding(.trailing, 8)
                
            // Content Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Anonymous")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(timeAgo)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Text(commentWithVote.post.content)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Database Create Comment View

struct DatabaseCreateCommentView: View {
    @Environment(\.dismiss) private var dismiss
    let parentPost: PostWithVote
    let onCommentCreated: () async -> Void
    
    @State private var commentContent = ""
    @State private var isCreating = false
    @State private var errorMessage: String?
    
    private let postManager = PostManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Add Comment")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Original Post Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Commenting on:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    Text(parentPost.post.content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .lineLimit(3)
                }
                
                // Comment Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your comment:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(commentContent.count)/250")
                            .font(.caption)
                            .foregroundColor(commentContent.count > 250 ? .red : .secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    TextEditor(text: $commentContent)
                        .foregroundColor(.primary)
                        .background(Color.clear)
                        .frame(minHeight: 120)
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(commentContent.count > 250 ? Color.red : Color(.systemGray4), lineWidth: 1)
                                .padding(.horizontal, 20)
                        )
                }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Comment Button
                Button(action: {
                    Task {
                        await createComment()
                    }
                }) {
                    HStack {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isCreating ? "Posting..." : "Post Comment")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(shouldDisableComment ? Color(.systemGray3) : Color.accentColor)
                    .cornerRadius(12)
                }
                .disabled(shouldDisableComment)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    .disabled(isCreating)
                }
            }
        }
    }
    
    private var shouldDisableComment: Bool {
        commentContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            commentContent.count > 250 ||
            isCreating
    }
    
    @MainActor
    private func createComment() async {
        isCreating = true
        errorMessage = nil
        
        do {
            _ = try await postManager.createComment(
                content: commentContent.trimmingCharacters(in: .whitespacesAndNewlines),
                parentPostId: parentPost.post.id
            )
            
            await onCommentCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isCreating = false
    }
}

// MARK: - Database Create Post View

struct DatabaseCreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postContent = ""
    @State private var isQuote = false
    @State private var isCreating = false
    @State private var errorMessage: String?
    
    let onPostCreated: () async -> Void
    private let postManager = PostManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Create Confession")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Quote Toggle
                HStack {
                    Toggle("Mark as Quote", isOn: $isQuote)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Text Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("What's on your mind?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(postContent.count)/250")
                            .font(.caption)
                            .foregroundColor(postContent.count > 250 ? .red : .secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    TextEditor(text: $postContent)
                        .foregroundColor(.primary)
                        .background(Color.clear)
                        .frame(minHeight: 150)
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(postContent.count > 250 ? Color.red : Color(.systemGray4), lineWidth: 1)
                                .padding(.horizontal, 20)
                        )
                }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Post Button
                Button(action: {
                    Task {
                        await createPost()
                    }
                }) {
                    HStack {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isCreating ? "Posting..." : "Post")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(shouldDisablePost ? Color(.systemGray3) : Color.accentColor)
                    .cornerRadius(12)
                }
                .disabled(shouldDisablePost)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    .disabled(isCreating)
                }
            }
        }
    }
    
    private var shouldDisablePost: Bool {
        postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            postContent.count > 250 ||
            isCreating
    }
    
    @MainActor
    private func createPost() async {
        isCreating = true
        errorMessage = nil
        
        do {
            _ = try await postManager.createPost(
                content: postContent.trimmingCharacters(in: .whitespacesAndNewlines),
                isQuote: isQuote
            )
            
            await onPostCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isCreating = false
    }
}

// MARK: - Legacy Create Post View (keeping for compatibility)

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postContent = ""
    @State private var isEvent = false
    let onPostCreated: (Post) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Create Post")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Event Toggle
                HStack {
                    Toggle("Mark as Event", isOn: $isEvent)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Text Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's on your mind?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    TextEditor(text: $postContent)
                        .foregroundColor(.primary)
                        .background(Color.clear)
                        .frame(minHeight: 150)
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                                .padding(.horizontal, 20)
                        )
                }
                
                Spacer()
                
                // Post Button
                Button(action: createPost) {
                    Text("Post")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray3) : Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func createPost() {
        let newPost = Post(
            author: "Anonymous",
            content: postContent.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: "now",
            upvotes: 0,
            isEvent: isEvent,
            comments: []
        )
        
        onPostCreated(newPost)
        dismiss()
    }
}

// MARK: - Post Row View

struct PostRowView: View {
    let post: Post
    let interaction: UserInteraction
    let userCommentCount: Int
    let onLike: () -> Void
    let onDislike: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Voting Section
            VStack(spacing: 8) {
                Button(action: onLike) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .foregroundColor(interaction.isLiked ? .accent : .secondary)
                        .font(.system(size: 20))
                }
                    
                Text("\(post.upvotes + interaction.userUpvotes)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accent)
                    
                Button(action: onDislike) {
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(interaction.isDisliked ? .red : .secondary)
                        .font(.system(size: 20))
                }
            }
            .padding(.trailing, 8)
                
            // Content Section
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    if post.isEvent {
                        Text("EVENT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accent)
                            .cornerRadius(12)
                    }
                        
                    Text(post.author)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        
                    Text(post.timestamp)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        
                    Spacer()
                        
                    // Removed non-working flag button
                }
                    
                // Post Content
                Text(post.content)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: onSave) {
                        Image(systemName: interaction.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(interaction.isSaved ? .accent : .secondary)
                    }
                        
                    // Removed non-working repost, share, and message buttons
                        
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                        if userCommentCount > 0 {
                            Text("\(post.commentCount + userCommentCount)")
                                .font(.system(size: 14))
                        }
                    }
                    .foregroundColor(.secondary)
                        
                    Spacer()
                }
                .font(.system(size: 16))
            }
                
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Post Detail View

struct PostDetailView: View {
    let post: Post
    let interaction: UserInteraction
    let userComments: [UserComment]
    let onLike: () -> Void
    let onDislike: () -> Void
    let onSave: () -> Void
    let onComment: (UserComment) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddComment = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Original Post
                    PostRowView(
                        post: post,
                        interaction: interaction,
                        userCommentCount: userComments.count,
                        onLike: onLike,
                        onDislike: onDislike,
                        onSave: onSave
                    )
                    
                    Divider()
                        .background(Color(.systemGray4))
                    
                    // Comments Section
                    let allComments = post.comments + userComments.map { userComment in
                        Comment(
                            author: userComment.author,
                            content: userComment.content,
                            timestamp: userComment.timestamp,
                            upvotes: userComment.upvotes
                        )
                    }
                    
                    if !allComments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(allComments) { comment in
                                CommentView(comment: comment)
                                
                                if comment.id != allComments.last?.id {
                                    Divider()
                                        .background(Color(.systemGray5))
                                        .padding(.leading, 40)
                                }
                            }
                        }
                    }
                    
                    // Add Comment Button
                    Button(action: { showingAddComment = true }) {
                        HStack {
                            Image(systemName: "plus.message")
                                .foregroundColor(.accent)
                            Text("Add a comment")
                                .foregroundColor(.accent)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {}
            }
        }
        .sheet(isPresented: $showingAddComment) {
            AddCommentView(post: post) { comment in
                onComment(comment)
            }
        }
    }
}

// MARK: - Add Comment View

struct AddCommentView: View {
    let post: Post
    let onCommentAdded: (UserComment) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var commentText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Add Comment")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Original Post Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Commenting on:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    Text(post.content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .lineLimit(3)
                }
                
                // Comment Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your comment:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    TextEditor(text: $commentText)
                        .foregroundColor(.primary)
                        .background(Color.clear)
                        .frame(minHeight: 120)
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                                .padding(.horizontal, 20)
                        )
                }
                
                Spacer()
                
                // Comment Button
                Button(action: addComment) {
                    Text("Post Comment")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray3) : Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func addComment() {
        let newComment = UserComment(content: commentText.trimmingCharacters(in: .whitespacesAndNewlines))
        onCommentAdded(newComment)
        dismiss()
    }
}

// MARK: - Comment View

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Removed non-working voting section for comments
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(comment.author)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(comment.timestamp)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Text("\(comment.upvotes) upvotes")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                // Removed non-working reply and share buttons
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    ExploreView()
}
