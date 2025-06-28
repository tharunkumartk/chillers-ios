# Supabase Setup Guide

## 1. Get Your Supabase Credentials

1. Go to [supabase.com](https://supabase.com) and sign in to your account
2. Create a new project or select an existing one
3. Go to **Settings** → **API** in your project dashboard
4. Copy your **Project URL** and **Project API Key (anon, public)**

## 2. Configure Your App

1. Open `chillers/SupabaseManager.swift`
2. Replace the placeholder values with your actual credentials:

```swift
guard let supabaseURL = URL(string: "YOUR_SUPABASE_URL") else {
    fatalError("Invalid Supabase URL")
}

self.client = SupabaseClient(
    supabaseURL: supabaseURL,
    supabaseKey: "YOUR_SUPABASE_ANON_KEY"
)
```

Replace:
- `YOUR_SUPABASE_URL` with your Project URL (e.g., `https://xyzcompany.supabase.co`)
- `YOUR_SUPABASE_ANON_KEY` with your anon/public API key

## 3. Configure Phone Authentication

### Enable Phone Authentication in Supabase:

1. Go to **Authentication** → **Settings** in your Supabase dashboard
2. Scroll down to **Phone Auth**
3. Enable **Enable phone confirmations**
4. Configure your phone provider (Twilio is recommended)

### Twilio Setup (if using Twilio):

1. Create a Twilio account at [twilio.com](https://twilio.com)
2. Get your Account SID and Auth Token
3. In Supabase, go to **Authentication** → **Settings**
4. Under **SMS Provider**, select **Twilio**
5. Enter your Twilio credentials:
   - Account SID
   - Auth Token  
   - Phone Number (your Twilio phone number)

## 4. Test Your Setup

1. Build and run your app
2. Enter a valid phone number on the login screen
3. You should receive an SMS with a 6-digit verification code
4. Enter the code to complete authentication

## 5. Security Notes

- Never commit your Supabase credentials to version control
- Consider using environment variables or a secure configuration file for production apps
- The anon key is safe to use in client applications
- Make sure to configure Row Level Security (RLS) in your Supabase database for data protection

## 6. Troubleshooting

### Common Issues:

**"Invalid Supabase URL" error:**
- Check that your URL is correct and includes `https://`
- Make sure there are no trailing slashes

**Phone OTP not working:**
- Verify phone authentication is enabled in Supabase
- Check your Twilio configuration and phone number format
- Ensure you're using international format (+1xxxxxxxxxx)

**Session not persisting:**
- Check that your Supabase client is properly configured
- Verify the auth state listener is set up correctly in AppState

For more help, check the [Supabase documentation](https://supabase.com/docs/guides/auth/phone-login/twilio) for phone authentication. 