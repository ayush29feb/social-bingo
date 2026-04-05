# Social Bingo — Design Spec
Date: 2026-04-05

## Overview

Social Bingo is an iOS app where each user maintains a 5x5 bingo card of things they want to do. Friends can "plus-one" items they're also interested in, creating a natural map of shared experiences. The prototype uses local storage with mocked social data, designed to migrate cleanly to Supabase later.

---

## Platform & Stack

- **Framework:** Expo (React Native) — iOS target
- **Local storage:** AsyncStorage for current user's profile and bingo items
- **Social data:** Static mock JSON (friends, plus-ones) imported into the app
- **Future backend:** Supabase (Postgres + Auth + Realtime) — data model designed to translate directly

---

## Screens

### 1. My Card (Tab)
- 5x5 bingo grid of the current user's items
- Filled cells show: emoji + title + plus-one count badge
- Empty cells show a "+" placeholder, tap to add
- Tap any filled cell → Item Detail Modal (edit mode)

### 2. Friends (Tab)
- List of mutual friends (avatar emoji + username)
- Tap a friend → Friend's Card screen (pushed onto stack)

### 3. Friend's Card
- Header: friend's avatar emoji + username
- Read-only 5x5 grid of their items
- Tap filled cell → Item Detail Modal (view mode with plus-one button)
- Plus-one button toggles active state; count updates locally for the session

### 4. Notifications (Tab)
- List of plus-one events on the current user's card
- Format: "[Friend] plus-oned '[item title]'" + timestamp
- Unread badge on tab icon (from mock data)

### 5. Profile / Settings
- Accessible from My Card screen (top-right icon)
- Fields: avatar emoji, username, short bio
- Persisted to AsyncStorage

---

## Data Model

Designed to map 1:1 to future Supabase tables.

### User
| Field | Type | Notes |
|-------|------|-------|
| id | string (uuid) | |
| username | string | unique handle |
| avatar_emoji | string | single emoji |
| bio | string | optional |

### BingoItem
| Field | Type | Notes |
|-------|------|-------|
| id | string (uuid) | |
| user_id | string | owner |
| position | number | 0–24 (grid index) |
| emoji | string | cell icon |
| title | string | required, short label |
| description | string | optional |
| url | string | optional |
| created_at | ISO timestamp | |

### PlusOne (mocked locally)
| Field | Type | Notes |
|-------|------|-------|
| id | string (uuid) | |
| item_id | string | references BingoItem |
| from_user_id | string | references User |
| created_at | ISO timestamp | |

### Friendship (mocked locally)
| Field | Type | Notes |
|-------|------|-------|
| id | string (uuid) | |
| user_a_id | string | mutual by definition |
| user_b_id | string | |

---

## Key Interactions

### Adding / Editing a Bingo Item
- Tap empty cell → bottom sheet modal
- Fields: emoji picker, title (required), description (optional), URL (optional)
- Save → AsyncStorage updated, cell renders immediately

### Plus-oneing a Friend's Item
- Friend's card cells show plus-one count badge
- Tap cell → modal with item details + "＋1" button
- Button toggles filled/active state; local session state only (not persisted in prototype)

### Notifications
- Rendered from mock data (static JSON)
- Unread count shown as tab bar badge

### Friend Discovery
- Primary: username/handle search (mocked in prototype)
- Bonus (future): contacts integration to suggest friends

---

## Mock Data

A single `mockData.ts` file exports:
- 3–5 fake friends with fully populated 5x5 cards
- Plus-one events referencing the current user's items
- Notification events for the Notifications screen

---

## Out of Scope (v1)

- Backend / Supabase integration
- Real auth (no login screen)
- Push notifications (mocked in Notifications tab)
- Contacts integration
- Bingo win state / celebration
- Feed / activity stream
