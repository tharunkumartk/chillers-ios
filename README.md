<h1 align="center">
<a href="https://tharunkumar.xyz/blog/chillers" target="_blank">
  chillers (iOS)
  </a>
</h1>
<p align="center">
  Exclusive iOS app for connecting verified "chillers" through curated parties and community-driven filtering — built with <a href="https://developer.apple.com/xcode/swiftui/" target="_blank">SwiftUI</a> and <a href="https://supabase.com/" target="_blank">Supabase</a>.
</p>

![demo](https://tharunkumar.xyz/_next/image?url=%2Fimages%2Fproject%2Fchillers%2Fchillers-logo.png&w=1920&q=75)


## Development setup

1. Requirements

   - Xcode 15 or later
   - iOS 17+ (simulator or device)
   - A Supabase project (URL + anon key)
   - Optional (recommended): Twilio account for SMS via Supabase Phone Auth

2. Clone and open

   ```sh
   git clone https://github.com/tharunkumartk/chillers-ios.git
   cd chillers-ios
   open chillers/chillers.xcodeproj
   ```

3. Configure Supabase

   - Follow `SUPABASE_SETUP.md` for a step-by-step guide.
   - Update `chillers/SupabaseManager.swift` with your Supabase URL and anon key.
   - Do not embed the service role key in client apps. Use only the anon key with RLS policies enabled.

4. Enable Push Notifications (optional but supported)

   - In Xcode, set your Signing Team and unique Bundle Identifier.
   - Enable the "Push Notifications" capability (and Background Modes → Remote notifications if needed).
   - APNs token registration is handled in `AppDelegate` and `AppState`.

5. Run

   - Select an iOS Simulator (or a signed device) and press Run in Xcode.


## Building and Releasing

1. App configuration

   - Set Bundle Identifier, App Category, icons, and permissions strings as needed.
   - Ensure Supabase Auth redirect URLs are configured if using deep links.

2. Archive and distribute

   - Product → Archive in Xcode
   - Distribute via TestFlight or App Store Connect


## Tech Stack

- **UI**: SwiftUI, NavigationStack
- **Language**: Swift
- **Backend**: Supabase (Postgres, Auth, Row Level Security)
- **Auth**: Phone OTP via Supabase (Twilio provider)
- **Push**: Apple Push Notification service (APNs)
- **Data Models**: Codable models mapped to Supabase tables


## Features

- **Phone OTP sign-in**: SMS-based authentication flow.
- **Onboarding**: Basic info → photos → prompts to complete a profile.
- **Parties/Events**: Browse events, view details, RSVP (going/maybe/not going/waitlist).
- **Community feed (optional)**: Lightweight posts with upvotes/downvotes and comments.
- **Notifications**: Permission flow and APNs token sync to user profiles.


## Project structure

- `chillers/chillersApp.swift`: App entry, lifecycle, APNs hooks
- `chillers/ContentView.swift`: Root navigation and flow switching
- `chillers/AppState.swift`: Global app state (auth, onboarding, notifications)
- `chillers/SupabaseManager.swift`: Supabase clients (auth + database) and helpers
- `chillers/PostManager.swift`: Post CRUD and voting logic
- `chillers/Models/DatabaseModels.swift`: Codable models for users, profiles, events, posts, votes
- Views:
  - `LoginView.swift`, `OTPVerificationView.swift`
  - `Onboarding*View.swift` (basic info, photos, prompts)
  - `NotificationPermissionView.swift`
  - `PartiesView.swift`, `PartyDetailView.swift`, `MainTabView.swift`, `ExploreView.swift`, `ProfileView.swift`
- `SUPABASE_SETUP.md`: Supabase + Twilio configuration
- `chillers.sql`: Database schema reference (not meant to run verbatim)


## Database (Supabase)

Key tables (see `chillers.sql` for full reference):

- **users**: app users (mapped to `auth.users`), approval status, profile completion
- **user_profiles**: extended fields (name parts, height, age, school/company, images, tags, APNs token)
- **events**: party/event metadata and status
- **event_attendees**: per-user RSVP status
- **posts / post_votes**: lightweight community content and voting
- **user_prompts / vouches / user_approvals**: prompts, vouching, and candidate approvals

Notes:

- Enable RLS and write policies to limit reads/writes to the current user where appropriate.
- Configure Phone Auth in Supabase (Twilio recommended) as described in `SUPABASE_SETUP.md`.


## System diagram and demo

![Chillers system diagram](docs/chillers-sys-diagram.png)

[Onboarding demo video](https://ydfksaipdlqazgcsrdlm.supabase.co/storage/v1/object/public/demo-videos/chillers-demo.mp4)


## Security

- Do not ship service role keys in client apps. Use the public anon key only.
- Store secrets securely; rely on RLS for authorization.
- Review authentication redirect URLs and allowed origins in Supabase.

