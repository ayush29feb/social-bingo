# Supabase Auth — Design Spec
Date: 2026-04-05

## Overview

Add Apple Sign-In backed by Supabase Auth to Social Bingo. On first sign-in, local prototype data is cleared and the user starts fresh with a real Supabase-managed identity. Profile (username + avatar emoji) is auto-generated from Apple-provided name and stored in a Supabase `users` table.

---

## Platform & Stack

- **Framework:** SwiftUI / iOS 17
- **Auth provider:** Apple Sign-In (`AuthenticationServices`)
- **Backend:** Supabase Auth (JWT sessions, persisted by the SDK's built-in Keychain storage)
- **Package:** `supabase-swift` v2 via Swift Package Manager
- **Database:** Supabase Postgres — `users` table (scoped to auth subsystem)

---

## Architecture

### New files

| File | Responsibility |
|------|---------------|
| `SwiftApp/SocialBingo/Config/SupabaseConfig.swift` | Supabase project URL + anon key constants; singleton `SupabaseClient` |
| `SwiftApp/SocialBingo/Auth/AuthManager.swift` | `@MainActor ObservableObject`; owns session state; drives Apple Sign-In credential exchange; creates user profile on first sign-in |
| `SwiftApp/SocialBingo/Auth/SignInView.swift` | Full-screen sign-in UI: app wordmark + `SignInWithAppleButton` |
| `docs/supabase/migrations/001_users.sql` | SQL to run in Supabase dashboard: `users` table + RLS policies |

### Modified files

| File | Change |
|------|--------|
| `SwiftApp/project.yml` | Add `supabase-swift` SPM package + product dependency on `SocialBingo` target |
| `SwiftApp/SocialBingo/SocialBingoApp.swift` | Add `@StateObject private var authManager = AuthManager.shared`; inject as `.environmentObject` |
| `SwiftApp/SocialBingo/ContentView.swift` | Route on `authManager.session`: nil → `SignInView`, non-nil → existing `TabView` |
| `SwiftApp/SocialBingo/Data/AppStorage.swift` | Add `resetForNewUser(user:)` — clears UserDefaults keys and sets `currentUser` from the Supabase profile |

---

## Sign-In Flow

1. App launches → `AuthManager.init()` calls `supabase.auth.session` to restore any persisted Keychain session
2. `isLoading = false` — ContentView routes based on `session`
3. **No session:** `SignInView` shown
4. User taps "Sign in with Apple":
   - Generate random nonce; store raw, hash for Apple request
   - `ASAuthorizationController` presents the system sheet
5. Apple returns `ASAuthorizationAppleIDCredential`
6. Exchange: `supabase.auth.signInWithIdToken(provider: .apple, idToken:, nonce:)`
7. **New user** (no row in `users` for this UUID): auto-create profile
8. **Returning user:** load profile from `users` table
9. Call `AppStorage.shared.resetForNewUser(user:)` if `AppStorage.currentUser.id == "current-user"` (prototype sentinel)
10. Set `self.session` → ContentView routes to tab bar

---

## Data Model

### Supabase `users` table

```sql
create table users (
  id            uuid primary key references auth.users(id) on delete cascade,
  username      text not null unique,
  avatar_emoji  text not null default '😊',
  bio           text not null default '',
  created_at    timestamptz not null default now()
);

alter table users enable row level security;

create policy "Anyone can read profiles"
  on users for select using (true);

create policy "Own profile insert"
  on users for insert with check (auth.uid() = id);

create policy "Own profile update"
  on users for update using (auth.uid() = id);
```

---

## Profile Auto-Generation

```
Apple fullName (PersonNameComponents?) →
  "\(givenName)\(familyName)".lowercased()
  .filter { $0.isLetter || $0.isNumber }
  .prefix(20)
  → if empty: "user\(Int.random(in: 1000...9999))"
```

`avatar_emoji` picked randomly from:
`["😊","🌊","🎸","🌿","🚀","🎯","🦊","🌙","⚡️","🎨"]`

---

## AppStorage Integration

`AppStorage.resetForNewUser(user: User)`:
- Clears `social_bingo_user` and `social_bingo_items` keys from UserDefaults
- Sets `currentUser = user`
- Sets `bingoItems = []` (no seed items — user starts with a blank card)

Called by `AuthManager` only when `AppStorage.currentUser.id == "current-user"` (detects prototype-era local data).

---

## Nonce Handling

Apple Sign-In requires a nonce to prevent replay attacks. Flow:
1. `randomNonceString()` — 32-char hex string using `SecRandomCopyBytes`
2. `sha256(nonce)` — passed to Apple as `request.nonce` (hashed)
3. Raw nonce stored as `private var currentNonce: String?` on `AuthManager`
4. Raw nonce passed to Supabase `signInWithIdToken` for server-side verification

---

## Out of Scope

- Sign-out (not needed per design decision)
- Email/password or Google auth
- Local data migration to Supabase (next spec: Database layer)
- Push notification entitlements
- Real-time session refresh UI (Supabase SDK handles token refresh automatically)
