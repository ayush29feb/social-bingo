# Social Bingo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a prototype iOS app where users maintain a 5x5 bingo card of things they want to do, friends can plus-one items, using Expo + AsyncStorage + static mock social data.

**Architecture:** Expo Router handles file-based navigation with a three-tab shell (My Card, Friends, Notifications). All user data persists to AsyncStorage; the social layer (friends, plus-ones, notifications) is simulated with static mock data imported at build time. Data types are modeled to map 1:1 to future Supabase tables.

**Tech Stack:** Expo SDK 52+ with expo-router, @react-native-async-storage/async-storage, TypeScript, Jest

---

## File Map

```
app/
  _layout.tsx                  # Root Stack layout, runs seed on first launch
  (tabs)/
    _layout.tsx                # Tab bar config (My Card, Friends, Notifications)
    index.tsx                  # My Card screen
    friends.tsx                # Friends list screen
    notifications.tsx          # Notifications screen
  friend/
    [id].tsx                   # Friend's Card screen (read-only + plus-one)
  profile.tsx                  # Profile / settings screen
components/
  BingoCell.tsx                # Single cell: emoji + title + plus-one badge
  BingoGrid.tsx                # 5x5 grid composed of BingoCells
  ItemModal.tsx                # Bottom sheet: add/edit item (own card) or view+plus-one (friend's card)
constants/
  colors.ts                    # App color palette
data/
  mockData.ts                  # Static mock friends, their bingo items, plus-ones, notifications
  storage.ts                   # AsyncStorage CRUD + first-launch seed
types/
  index.ts                     # User, BingoItem, PlusOne, Friendship, NotificationItem
__tests__/
  storage.test.ts              # Unit tests for storage layer
```

---

### Task 1: Initialize Expo Project

**Files:**
- Create: entire project scaffold via `create-expo-app`
- Delete: default example files we don't need
- Modify: `package.json` (add AsyncStorage)

- [ ] **Step 1: Scaffold project**

```bash
cd /Users/ayush29feb/Developement/social-bingo
npx create-expo-app@latest . --template tabs
```

When prompted about existing files, allow overwrite. The tabs template includes expo-router, TypeScript, and Jest already configured.

- [ ] **Step 2: Install AsyncStorage**

```bash
npx expo install @react-native-async-storage/async-storage
```

- [ ] **Step 3: Remove template boilerplate**

Delete these template files — we'll create our own:
```bash
rm -rf app/\(tabs\)/explore.tsx
rm -rf components/
rm -rf constants/Colors.ts
rm -rf hooks/
```

Keep: `app/_layout.tsx`, `app/(tabs)/_layout.tsx`, `app/(tabs)/index.tsx`

- [ ] **Step 4: Verify the project runs**

```bash
npx expo start
```

Press `i` to open in iOS Simulator. You should see a tab bar with a broken screen (we deleted explore). That's fine — close the server with Ctrl+C.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: initialize Expo project with tabs template"
```

---

### Task 2: Define TypeScript Types

**Files:**
- Create: `types/index.ts`

- [ ] **Step 1: Create types file**

```typescript
// types/index.ts
export interface User {
  id: string;
  username: string;
  avatar_emoji: string;
  bio: string;
}

export interface BingoItem {
  id: string;
  user_id: string;
  position: number; // 0–24, maps to a 5x5 grid cell
  emoji: string;
  title: string;
  description: string;
  url: string;
  created_at: string; // ISO timestamp
}

export interface PlusOne {
  id: string;
  item_id: string;
  from_user_id: string;
  created_at: string;
}

export interface Friendship {
  id: string;
  user_a_id: string;
  user_b_id: string;
}

export interface NotificationItem {
  id: string;
  item_id: string;
  item_title: string;
  from_user_id: string;
  from_username: string;
  from_avatar_emoji: string;
  created_at: string;
  read: boolean;
}
```

- [ ] **Step 2: Commit**

```bash
git add types/index.ts
git commit -m "feat: add shared TypeScript types"
```

---

### Task 3: Create Mock Data

**Files:**
- Create: `data/mockData.ts`

The mock data has static IDs so that plus-one counts can reference the current user's seeded bingo items.

- [ ] **Step 1: Create mockData.ts**

```typescript
// data/mockData.ts
import { User, BingoItem, PlusOne, Friendship, NotificationItem } from '../types';

export const CURRENT_USER_ID = 'current-user';

// ─── Current user's seeded bingo card ────────────────────────────────────────
// 20 items pre-filled, positions 4 and 9 intentionally empty to show empty state
export const SEED_BINGO_ITEMS: BingoItem[] = [
  { id: 'mi-0',  user_id: CURRENT_USER_ID, position: 0,  emoji: '🏄', title: 'Try surfing',        description: 'Take a beginner lesson', url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-1',  user_id: CURRENT_USER_ID, position: 1,  emoji: '🍜', title: 'Ramen crawl',        description: 'Hit 5 ramen spots in one day', url: '',                  created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-2',  user_id: CURRENT_USER_ID, position: 2,  emoji: '🎸', title: 'Learn a song',       description: 'Learn Blackbird on guitar', url: '',                      created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-3',  user_id: CURRENT_USER_ID, position: 3,  emoji: '🏕️', title: 'Go camping',         description: 'Overnight trip, no phones', url: '',                      created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-5',  user_id: CURRENT_USER_ID, position: 5,  emoji: '🎨', title: 'Pottery class',      description: '',                       url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-6',  user_id: CURRENT_USER_ID, position: 6,  emoji: '🌄', title: 'Sunrise hike',       description: 'Wake up at 4am, worth it', url: '',                      created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-7',  user_id: CURRENT_USER_ID, position: 7,  emoji: '🎭', title: 'See a play',         description: '',                       url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-8',  user_id: CURRENT_USER_ID, position: 8,  emoji: '🚴', title: 'Bike a century',     description: '100 miles in a day',     url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-10', user_id: CURRENT_USER_ID, position: 10, emoji: '🌮', title: 'Taco road trip',     description: 'Drive down the coast hitting taco stands', url: '',       created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-11', user_id: CURRENT_USER_ID, position: 11, emoji: '📚', title: 'Read 12 books',      description: 'One per month this year', url: '',                        created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-12', user_id: CURRENT_USER_ID, position: 12, emoji: '🧘', title: 'Meditation retreat', description: '3-day silent retreat',   url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-13', user_id: CURRENT_USER_ID, position: 13, emoji: '🌊', title: 'Open water swim',    description: '1 mile in the ocean',    url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-14', user_id: CURRENT_USER_ID, position: 14, emoji: '🎤', title: 'Karaoke night',      description: '',                       url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-15', user_id: CURRENT_USER_ID, position: 15, emoji: '🍷', title: 'Wine tasting',       description: 'Sonoma day trip',        url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-16', user_id: CURRENT_USER_ID, position: 16, emoji: '🏔️', title: 'Summit a peak',      description: 'Whitney or Shasta',      url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-17', user_id: CURRENT_USER_ID, position: 17, emoji: '🎲', title: 'Board game marathon', description: 'Full day, 5+ games',    url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-18', user_id: CURRENT_USER_ID, position: 18, emoji: '🛶', title: 'Kayak trip',         description: '',                       url: '',                         created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-19', user_id: CURRENT_USER_ID, position: 19, emoji: '🍕', title: 'Make pizza from scratch', description: 'Real dough, wood-fired if possible', url: '',       created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-20', user_id: CURRENT_USER_ID, position: 20, emoji: '🎬', title: 'Short film',         description: 'Write, shoot, and edit one', url: '',                    created_at: '2025-01-10T10:00:00Z' },
  { id: 'mi-21', user_id: CURRENT_USER_ID, position: 21, emoji: '🌍', title: 'Solo trip abroad',   description: 'At least 2 weeks',       url: '',                         created_at: '2025-01-10T10:00:00Z' },
];

// ─── Mock friends ─────────────────────────────────────────────────────────────
export const MOCK_USERS: User[] = [
  { id: 'friend-1', username: 'alex',   avatar_emoji: '😄', bio: 'Always down for an adventure' },
  { id: 'friend-2', username: 'maya',   avatar_emoji: '🌊', bio: 'Ocean girl, coffee addict' },
  { id: 'friend-3', username: 'sam',    avatar_emoji: '🎸', bio: 'Music, food, repeat' },
  { id: 'friend-4', username: 'jordan', avatar_emoji: '🌿', bio: 'Hiker, reader, overthinker' },
];

export const MOCK_FRIENDSHIPS: Friendship[] = [
  { id: 'fs-1', user_a_id: CURRENT_USER_ID, user_b_id: 'friend-1' },
  { id: 'fs-2', user_a_id: CURRENT_USER_ID, user_b_id: 'friend-2' },
  { id: 'fs-3', user_a_id: CURRENT_USER_ID, user_b_id: 'friend-3' },
  { id: 'fs-4', user_a_id: CURRENT_USER_ID, user_b_id: 'friend-4' },
];

// ─── Friends' bingo items ─────────────────────────────────────────────────────
export const MOCK_FRIEND_ITEMS: Record<string, BingoItem[]> = {
  'friend-1': [
    { id: 'f1-0',  user_id: 'friend-1', position: 0,  emoji: '🏄', title: 'Try surfing',     description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-1',  user_id: 'friend-1', position: 1,  emoji: '🎨', title: 'Pottery class',   description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-2',  user_id: 'friend-1', position: 2,  emoji: '🏕️', title: 'Go camping',      description: 'Big Sur', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-3',  user_id: 'friend-1', position: 3,  emoji: '🌮', title: 'Taco road trip',  description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-4',  user_id: 'friend-1', position: 4,  emoji: '🎤', title: 'Karaoke night',   description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-5',  user_id: 'friend-1', position: 5,  emoji: '🍜', title: 'Ramen crawl',     description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-6',  user_id: 'friend-1', position: 6,  emoji: '🚀', title: 'Visit NASA',      description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-7',  user_id: 'friend-1', position: 7,  emoji: '🎲', title: 'Board game marathon', description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-8',  user_id: 'friend-1', position: 8,  emoji: '🌄', title: 'Sunrise hike',    description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-9',  user_id: 'friend-1', position: 9,  emoji: '🎭', title: 'See a play',      description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-10', user_id: 'friend-1', position: 10, emoji: '🍷', title: 'Wine tasting',    description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-11', user_id: 'friend-1', position: 11, emoji: '🛶', title: 'Kayak trip',      description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-12', user_id: 'friend-1', position: 12, emoji: '🎸', title: 'Open mic night',  description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-13', user_id: 'friend-1', position: 13, emoji: '🏔️', title: 'Summit a peak',   description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-14', user_id: 'friend-1', position: 14, emoji: '🌍', title: 'Solo trip abroad', description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-15', user_id: 'friend-1', position: 15, emoji: '📸', title: 'Photo walk',      description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-16', user_id: 'friend-1', position: 16, emoji: '🎬', title: 'Film festival',   description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-17', user_id: 'friend-1', position: 17, emoji: '🍕', title: 'Pizza from scratch', description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-18', user_id: 'friend-1', position: 18, emoji: '🚴', title: 'Bike a century',  description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
    { id: 'f1-19', user_id: 'friend-1', position: 19, emoji: '🧘', title: 'Meditation retreat', description: '', url: '', created_at: '2025-02-01T10:00:00Z' },
  ],
  'friend-2': [
    { id: 'f2-0',  user_id: 'friend-2', position: 0,  emoji: '🌊', title: 'Open water swim',  description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-1',  user_id: 'friend-2', position: 1,  emoji: '🏄', title: 'Try surfing',      description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-2',  user_id: 'friend-2', position: 2,  emoji: '🎨', title: 'Pottery class',    description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-3',  user_id: 'friend-2', position: 3,  emoji: '📚', title: 'Read 12 books',    description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-4',  user_id: 'friend-2', position: 4,  emoji: '🌮', title: 'Taco road trip',   description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-5',  user_id: 'friend-2', position: 5,  emoji: '🍜', title: 'Ramen crawl',      description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-6',  user_id: 'friend-2', position: 6,  emoji: '🌍', title: 'Solo trip abroad', description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-7',  user_id: 'friend-2', position: 7,  emoji: '🛶', title: 'Kayak trip',       description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-8',  user_id: 'friend-2', position: 8,  emoji: '🏕️', title: 'Go camping',       description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-9',  user_id: 'friend-2', position: 9,  emoji: '🎤', title: 'Karaoke night',    description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-10', user_id: 'friend-2', position: 10, emoji: '🍷', title: 'Wine tasting',     description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-11', user_id: 'friend-2', position: 11, emoji: '🎭', title: 'See a play',       description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-12', user_id: 'friend-2', position: 12, emoji: '🎸', title: 'Open mic night',   description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-13', user_id: 'friend-2', position: 13, emoji: '🧘', title: 'Yoga retreat',     description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-14', user_id: 'friend-2', position: 14, emoji: '🌄', title: 'Sunrise hike',     description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-15', user_id: 'friend-2', position: 15, emoji: '🎬', title: 'Short film',       description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-16', user_id: 'friend-2', position: 16, emoji: '🚴', title: 'Bike a century',   description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-17', user_id: 'friend-2', position: 17, emoji: '🍕', title: 'Pizza from scratch', description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-18', user_id: 'friend-2', position: 18, emoji: '🏔️', title: 'Summit a peak',    description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
    { id: 'f2-19', user_id: 'friend-2', position: 19, emoji: '📸', title: 'Photo walk',       description: '', url: '', created_at: '2025-02-05T10:00:00Z' },
  ],
  'friend-3': [
    { id: 'f3-0',  user_id: 'friend-3', position: 0,  emoji: '🎸', title: 'Learn a song',        description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-1',  user_id: 'friend-3', position: 1,  emoji: '🎤', title: 'Karaoke night',        description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-2',  user_id: 'friend-3', position: 2,  emoji: '🍜', title: 'Ramen crawl',          description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-3',  user_id: 'friend-3', position: 3,  emoji: '🏄', title: 'Try surfing',          description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-4',  user_id: 'friend-3', position: 4,  emoji: '🎲', title: 'Board game marathon',  description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-5',  user_id: 'friend-3', position: 5,  emoji: '🎭', title: 'See a play',           description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-6',  user_id: 'friend-3', position: 6,  emoji: '🍷', title: 'Wine tasting',         description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-7',  user_id: 'friend-3', position: 7,  emoji: '🌮', title: 'Taco road trip',       description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-8',  user_id: 'friend-3', position: 8,  emoji: '🏕️', title: 'Go camping',           description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-9',  user_id: 'friend-3', position: 9,  emoji: '📸', title: 'Photo walk',           description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-10', user_id: 'friend-3', position: 10, emoji: '🚴', title: 'Bike a century',       description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-11', user_id: 'friend-3', position: 11, emoji: '🌍', title: 'Solo trip abroad',     description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-12', user_id: 'friend-3', position: 12, emoji: '🌄', title: 'Sunrise hike',         description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-13', user_id: 'friend-3', position: 13, emoji: '🎬', title: 'Short film',           description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-14', user_id: 'friend-3', position: 14, emoji: '🛶', title: 'Kayak trip',           description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-15', user_id: 'friend-3', position: 15, emoji: '📚', title: 'Read 12 books',        description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-16', user_id: 'friend-3', position: 16, emoji: '🍕', title: 'Pizza from scratch',   description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-17', user_id: 'friend-3', position: 17, emoji: '🏔️', title: 'Summit a peak',        description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-18', user_id: 'friend-3', position: 18, emoji: '🧘', title: 'Meditation retreat',   description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
    { id: 'f3-19', user_id: 'friend-3', position: 19, emoji: '🌊', title: 'Open water swim',      description: '', url: '', created_at: '2025-02-10T10:00:00Z' },
  ],
  'friend-4': [
    { id: 'f4-0',  user_id: 'friend-4', position: 0,  emoji: '🏔️', title: 'Summit a peak',        description: 'Mt. Whitney', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-1',  user_id: 'friend-4', position: 1,  emoji: '📚', title: 'Read 12 books',         description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-2',  user_id: 'friend-4', position: 2,  emoji: '🌄', title: 'Sunrise hike',          description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-3',  user_id: 'friend-4', position: 3,  emoji: '🧘', title: 'Meditation retreat',    description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-4',  user_id: 'friend-4', position: 4,  emoji: '🏕️', title: 'Go camping',            description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-5',  user_id: 'friend-4', position: 5,  emoji: '🌍', title: 'Solo trip abroad',      description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-6',  user_id: 'friend-4', position: 6,  emoji: '🛶', title: 'Kayak trip',            description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-7',  user_id: 'friend-4', position: 7,  emoji: '🌊', title: 'Open water swim',       description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-8',  user_id: 'friend-4', position: 8,  emoji: '🚴', title: 'Bike a century',        description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-9',  user_id: 'friend-4', position: 9,  emoji: '🎨', title: 'Pottery class',         description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-10', user_id: 'friend-4', position: 10, emoji: '🍜', title: 'Ramen crawl',           description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-11', user_id: 'friend-4', position: 11, emoji: '📸', title: 'Photo walk',            description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-12', user_id: 'friend-4', position: 12, emoji: '🎭', title: 'See a play',            description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-13', user_id: 'friend-4', position: 13, emoji: '🏄', title: 'Try surfing',           description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-14', user_id: 'friend-4', position: 14, emoji: '🍷', title: 'Wine tasting',          description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-15', user_id: 'friend-4', position: 15, emoji: '🎸', title: 'Learn a song',          description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-16', user_id: 'friend-4', position: 16, emoji: '🍕', title: 'Pizza from scratch',    description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-17', user_id: 'friend-4', position: 17, emoji: '🎬', title: 'Short film',            description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-18', user_id: 'friend-4', position: 18, emoji: '🎤', title: 'Karaoke night',         description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
    { id: 'f4-19', user_id: 'friend-4', position: 19, emoji: '🌮', title: 'Taco road trip',        description: '', url: '', created_at: '2025-02-15T10:00:00Z' },
  ],
};

// ─── Plus-ones on current user's items (from mock friends) ───────────────────
export const MOCK_PLUS_ONES: PlusOne[] = [
  { id: 'po-1', item_id: 'mi-0',  from_user_id: 'friend-1', created_at: '2025-03-01T09:00:00Z' },
  { id: 'po-2', item_id: 'mi-0',  from_user_id: 'friend-2', created_at: '2025-03-02T11:00:00Z' },
  { id: 'po-3', item_id: 'mi-0',  from_user_id: 'friend-3', created_at: '2025-03-03T14:00:00Z' },
  { id: 'po-4', item_id: 'mi-1',  from_user_id: 'friend-2', created_at: '2025-03-04T10:00:00Z' },
  { id: 'po-5', item_id: 'mi-1',  from_user_id: 'friend-3', created_at: '2025-03-05T12:00:00Z' },
  { id: 'po-6', item_id: 'mi-3',  from_user_id: 'friend-1', created_at: '2025-03-06T08:00:00Z' },
  { id: 'po-7', item_id: 'mi-3',  from_user_id: 'friend-4', created_at: '2025-03-07T16:00:00Z' },
  { id: 'po-8', item_id: 'mi-6',  from_user_id: 'friend-4', created_at: '2025-03-08T07:00:00Z' },
  { id: 'po-9', item_id: 'mi-10', from_user_id: 'friend-1', created_at: '2025-03-09T13:00:00Z' },
  { id: 'po-10', item_id: 'mi-10', from_user_id: 'friend-2', created_at: '2025-03-10T15:00:00Z' },
  { id: 'po-11', item_id: 'mi-12', from_user_id: 'friend-4', created_at: '2025-03-11T09:00:00Z' },
  { id: 'po-12', item_id: 'mi-16', from_user_id: 'friend-4', created_at: '2025-03-12T10:00:00Z' },
  { id: 'po-13', item_id: 'mi-21', from_user_id: 'friend-2', created_at: '2025-03-13T11:00:00Z' },
  { id: 'po-14', item_id: 'mi-21', from_user_id: 'friend-3', created_at: '2025-03-14T12:00:00Z' },
];

// ─── Notifications ────────────────────────────────────────────────────────────
export const MOCK_NOTIFICATIONS: NotificationItem[] = [
  { id: 'n-1',  item_id: 'mi-0',  item_title: 'Try surfing',       from_user_id: 'friend-3', from_username: 'sam',    from_avatar_emoji: '🎸', created_at: '2025-03-03T14:00:00Z', read: false },
  { id: 'n-2',  item_id: 'mi-21', item_title: 'Solo trip abroad',  from_user_id: 'friend-3', from_username: 'sam',    from_avatar_emoji: '🎸', created_at: '2025-03-14T12:00:00Z', read: false },
  { id: 'n-3',  item_id: 'mi-21', item_title: 'Solo trip abroad',  from_user_id: 'friend-2', from_username: 'maya',   from_avatar_emoji: '🌊', created_at: '2025-03-13T11:00:00Z', read: false },
  { id: 'n-4',  item_id: 'mi-16', item_title: 'Summit a peak',     from_user_id: 'friend-4', from_username: 'jordan', from_avatar_emoji: '🌿', created_at: '2025-03-12T10:00:00Z', read: true  },
  { id: 'n-5',  item_id: 'mi-12', item_title: 'Meditation retreat',from_user_id: 'friend-4', from_username: 'jordan', from_avatar_emoji: '🌿', created_at: '2025-03-11T09:00:00Z', read: true  },
  { id: 'n-6',  item_id: 'mi-10', item_title: 'Taco road trip',    from_user_id: 'friend-2', from_username: 'maya',   from_avatar_emoji: '🌊', created_at: '2025-03-10T15:00:00Z', read: true  },
  { id: 'n-7',  item_id: 'mi-10', item_title: 'Taco road trip',    from_user_id: 'friend-1', from_username: 'alex',   from_avatar_emoji: '😄', created_at: '2025-03-09T13:00:00Z', read: true  },
  { id: 'n-8',  item_id: 'mi-0',  item_title: 'Try surfing',       from_user_id: 'friend-2', from_username: 'maya',   from_avatar_emoji: '🌊', created_at: '2025-03-02T11:00:00Z', read: true  },
  { id: 'n-9',  item_id: 'mi-0',  item_title: 'Try surfing',       from_user_id: 'friend-1', from_username: 'alex',   from_avatar_emoji: '😄', created_at: '2025-03-01T09:00:00Z', read: true  },
  { id: 'n-10', item_id: 'mi-3',  item_title: 'Go camping',        from_user_id: 'friend-4', from_username: 'jordan', from_avatar_emoji: '🌿', created_at: '2025-03-07T16:00:00Z', read: true  },
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Returns the User object for a given friend id */
export function getMockUser(userId: string): User | undefined {
  return MOCK_USERS.find(u => u.id === userId);
}

/** Returns bingo items for a given friend id */
export function getMockFriendItems(userId: string): BingoItem[] {
  return MOCK_FRIEND_ITEMS[userId] ?? [];
}

/** Returns plus-one counts keyed by item_id for the current user's items */
export function getPlusOneCounts(myItemIds: string[]): Record<string, number> {
  const counts: Record<string, number> = {};
  for (const po of MOCK_PLUS_ONES) {
    if (myItemIds.includes(po.item_id)) {
      counts[po.item_id] = (counts[po.item_id] ?? 0) + 1;
    }
  }
  return counts;
}

/** Returns the number of unread notifications */
export function getUnreadCount(): number {
  return MOCK_NOTIFICATIONS.filter(n => !n.read).length;
}
```

- [ ] **Step 2: Commit**

```bash
git add data/mockData.ts
git commit -m "feat: add static mock social data"
```

---

### Task 4: Storage Layer

**Files:**
- Create: `data/storage.ts`
- Create: `__tests__/storage.test.ts`

- [ ] **Step 1: Write the failing tests**

```typescript
// __tests__/storage.test.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  getUser,
  saveUser,
  getBingoItems,
  saveBingoItem,
  deleteBingoItem,
  createBingoItem,
  initializeIfNeeded,
} from '../data/storage';
import { CURRENT_USER_ID } from '../data/mockData';

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

beforeEach(async () => {
  await AsyncStorage.clear();
});

describe('getUser / saveUser', () => {
  it('returns null when no user is stored', async () => {
    const user = await getUser();
    expect(user).toBeNull();
  });

  it('saves and retrieves a user', async () => {
    const user = { id: 'u1', username: 'testuser', avatar_emoji: '😄', bio: 'hello' };
    await saveUser(user);
    const retrieved = await getUser();
    expect(retrieved).toEqual(user);
  });
});

describe('getBingoItems / saveBingoItem', () => {
  it('returns empty array when no items stored', async () => {
    const items = await getBingoItems();
    expect(items).toEqual([]);
  });

  it('saves and retrieves a bingo item', async () => {
    const item = createBingoItem('u1', 0, { emoji: '🏄', title: 'Surf', description: '', url: '' });
    await saveBingoItem(item);
    const items = await getBingoItems();
    expect(items).toHaveLength(1);
    expect(items[0].title).toBe('Surf');
    expect(items[0].position).toBe(0);
  });

  it('updates an existing item when saved with same id', async () => {
    const item = createBingoItem('u1', 0, { emoji: '🏄', title: 'Surf', description: '', url: '' });
    await saveBingoItem(item);
    await saveBingoItem({ ...item, title: 'Updated' });
    const items = await getBingoItems();
    expect(items).toHaveLength(1);
    expect(items[0].title).toBe('Updated');
  });
});

describe('deleteBingoItem', () => {
  it('removes the item with the given id', async () => {
    const item = createBingoItem('u1', 0, { emoji: '🏄', title: 'Surf', description: '', url: '' });
    await saveBingoItem(item);
    await deleteBingoItem(item.id);
    const items = await getBingoItems();
    expect(items).toHaveLength(0);
  });

  it('does nothing when id does not exist', async () => {
    await deleteBingoItem('nonexistent');
    const items = await getBingoItems();
    expect(items).toHaveLength(0);
  });
});

describe('createBingoItem', () => {
  it('generates a unique id each time', () => {
    const a = createBingoItem('u1', 0, { emoji: '🏄', title: 'A', description: '', url: '' });
    const b = createBingoItem('u1', 1, { emoji: '🎸', title: 'B', description: '', url: '' });
    expect(a.id).not.toBe(b.id);
  });

  it('sets the correct user_id and position', () => {
    const item = createBingoItem('u1', 5, { emoji: '🏄', title: 'A', description: '', url: '' });
    expect(item.user_id).toBe('u1');
    expect(item.position).toBe(5);
  });
});

describe('initializeIfNeeded', () => {
  it('creates a default user and seeds bingo items on first run', async () => {
    await initializeIfNeeded();
    const user = await getUser();
    expect(user).not.toBeNull();
    expect(user?.id).toBe(CURRENT_USER_ID);
    const items = await getBingoItems();
    expect(items.length).toBeGreaterThan(0);
  });

  it('does not overwrite an existing user on second run', async () => {
    await initializeIfNeeded();
    const user1 = await getUser();
    await saveUser({ ...user1!, username: 'changed' });
    await initializeIfNeeded();
    const user2 = await getUser();
    expect(user2?.username).toBe('changed');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
npx jest __tests__/storage.test.ts --no-coverage
```

Expected: FAIL — "Cannot find module '../data/storage'"

- [ ] **Step 3: Implement storage.ts**

```typescript
// data/storage.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import { User, BingoItem } from '../types';
import { CURRENT_USER_ID, SEED_BINGO_ITEMS } from './mockData';

const KEYS = {
  USER: '@social_bingo/user',
  BINGO_ITEMS: '@social_bingo/bingo_items',
} as const;

export async function getUser(): Promise<User | null> {
  const raw = await AsyncStorage.getItem(KEYS.USER);
  return raw ? (JSON.parse(raw) as User) : null;
}

export async function saveUser(user: User): Promise<void> {
  await AsyncStorage.setItem(KEYS.USER, JSON.stringify(user));
}

export async function getBingoItems(): Promise<BingoItem[]> {
  const raw = await AsyncStorage.getItem(KEYS.BINGO_ITEMS);
  return raw ? (JSON.parse(raw) as BingoItem[]) : [];
}

export async function saveBingoItem(item: BingoItem): Promise<void> {
  const items = await getBingoItems();
  const idx = items.findIndex(i => i.id === item.id);
  if (idx >= 0) {
    items[idx] = item;
  } else {
    items.push(item);
  }
  await AsyncStorage.setItem(KEYS.BINGO_ITEMS, JSON.stringify(items));
}

export async function deleteBingoItem(id: string): Promise<void> {
  const items = await getBingoItems();
  const filtered = items.filter(i => i.id !== id);
  await AsyncStorage.setItem(KEYS.BINGO_ITEMS, JSON.stringify(filtered));
}

export function createBingoItem(
  userId: string,
  position: number,
  partial: Pick<BingoItem, 'emoji' | 'title' | 'description' | 'url'>
): BingoItem {
  return {
    id: `item-${Date.now()}-${Math.random().toString(36).slice(2)}`,
    user_id: userId,
    position,
    created_at: new Date().toISOString(),
    ...partial,
  };
}

export async function initializeIfNeeded(): Promise<void> {
  const existing = await getUser();
  if (existing) return;
  await saveUser({
    id: CURRENT_USER_ID,
    username: 'you',
    avatar_emoji: '😎',
    bio: '',
  });
  for (const item of SEED_BINGO_ITEMS) {
    await saveBingoItem(item);
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
npx jest __tests__/storage.test.ts --no-coverage
```

Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add data/storage.ts __tests__/storage.test.ts
git commit -m "feat: add AsyncStorage layer with seed and tests"
```

---

### Task 5: Colors Constant

**Files:**
- Create: `constants/colors.ts`

- [ ] **Step 1: Create colors.ts**

```typescript
// constants/colors.ts
export const Colors = {
  primary: '#6C63FF',
  primaryLight: '#EEF0FF',
  background: '#F5F5F5',
  card: '#FFFFFF',
  text: '#1A1A1A',
  muted: '#888888',
  border: '#E0E0E0',
  plusOne: '#FF6B6B',
  plusOneBg: '#FFF0F0',
  white: '#FFFFFF',
} as const;
```

- [ ] **Step 2: Commit**

```bash
git add constants/colors.ts
git commit -m "feat: add color palette constants"
```

---

### Task 6: BingoCell Component

**Files:**
- Create: `components/BingoCell.tsx`

- [ ] **Step 1: Create BingoCell.tsx**

```typescript
// components/BingoCell.tsx
import React from 'react';
import { TouchableOpacity, Text, View, StyleSheet } from 'react-native';
import { BingoItem } from '../types';
import { Colors } from '../constants/colors';

interface BingoCellProps {
  item?: BingoItem;
  plusOneCount?: number;
  onPress: () => void;
}

export function BingoCell({ item, plusOneCount = 0, onPress }: BingoCellProps) {
  const isEmpty = !item;

  return (
    <TouchableOpacity
      style={[styles.cell, isEmpty && styles.emptyCell]}
      onPress={onPress}
      activeOpacity={0.7}
    >
      {isEmpty ? (
        <Text style={styles.plus}>+</Text>
      ) : (
        <>
          <Text style={styles.emoji}>{item.emoji}</Text>
          <Text style={styles.title} numberOfLines={2}>{item.title}</Text>
          {plusOneCount > 0 && (
            <View style={styles.badge}>
              <Text style={styles.badgeText}>+{plusOneCount}</Text>
            </View>
          )}
        </>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  cell: {
    flex: 1,
    aspectRatio: 1,
    margin: 3,
    backgroundColor: Colors.card,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 6,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 3,
    elevation: 2,
  },
  emptyCell: {
    backgroundColor: Colors.background,
    borderWidth: 1.5,
    borderColor: Colors.border,
    borderStyle: 'dashed',
  },
  emoji: {
    fontSize: 22,
    marginBottom: 2,
  },
  title: {
    fontSize: 9,
    color: Colors.text,
    textAlign: 'center',
    fontWeight: '500',
    lineHeight: 12,
  },
  plus: {
    fontSize: 22,
    color: Colors.muted,
    fontWeight: '300',
  },
  badge: {
    position: 'absolute',
    top: 4,
    right: 4,
    backgroundColor: Colors.plusOne,
    borderRadius: 8,
    paddingHorizontal: 4,
    paddingVertical: 1,
    minWidth: 16,
    alignItems: 'center',
  },
  badgeText: {
    fontSize: 8,
    color: Colors.white,
    fontWeight: '700',
  },
});
```

- [ ] **Step 2: Commit**

```bash
git add components/BingoCell.tsx
git commit -m "feat: add BingoCell component"
```

---

### Task 7: BingoGrid Component

**Files:**
- Create: `components/BingoGrid.tsx`

- [ ] **Step 1: Create BingoGrid.tsx**

```typescript
// components/BingoGrid.tsx
import React from 'react';
import { View, StyleSheet, useWindowDimensions } from 'react-native';
import { BingoCell } from './BingoCell';
import { BingoItem } from '../types';

interface BingoGridProps {
  items: BingoItem[];
  plusOneCounts?: Record<string, number>;
  onCellPress: (position: number, item?: BingoItem) => void;
}

export function BingoGrid({ items, plusOneCounts = {}, onCellPress }: BingoGridProps) {
  const { width } = useWindowDimensions();
  const gridSize = width - 32; // 16px padding each side

  // Build a map from position -> item for O(1) lookup
  const itemByPosition = React.useMemo(() => {
    const map: Record<number, BingoItem> = {};
    for (const item of items) {
      map[item.position] = item;
    }
    return map;
  }, [items]);

  const rows = Array.from({ length: 5 }, (_, rowIndex) =>
    Array.from({ length: 5 }, (_, colIndex) => rowIndex * 5 + colIndex)
  );

  return (
    <View style={[styles.grid, { width: gridSize }]}>
      {rows.map((row, rowIndex) => (
        <View key={rowIndex} style={styles.row}>
          {row.map(position => {
            const item = itemByPosition[position];
            return (
              <BingoCell
                key={position}
                item={item}
                plusOneCount={item ? plusOneCounts[item.id] : 0}
                onPress={() => onCellPress(position, item)}
              />
            );
          })}
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  grid: {
    alignSelf: 'center',
  },
  row: {
    flexDirection: 'row',
  },
});
```

- [ ] **Step 2: Commit**

```bash
git add components/BingoGrid.tsx
git commit -m "feat: add BingoGrid component"
```

---

### Task 8: ItemModal Component

**Files:**
- Create: `components/ItemModal.tsx`

This modal handles three modes:
- **create** — new item, shows emoji + title (required), description + url (optional), Save button
- **edit** — existing item, same fields, Save + Delete buttons  
- **view** — friend's item, shows all fields read-only, plus-one button

- [ ] **Step 1: Create ItemModal.tsx**

```typescript
// components/ItemModal.tsx
import React, { useState, useEffect } from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  TouchableWithoutFeedback,
} from 'react-native';
import { BingoItem } from '../types';
import { Colors } from '../constants/colors';

type ModalMode = 'create' | 'edit' | 'view';

interface ItemModalProps {
  visible: boolean;
  mode: ModalMode;
  item?: BingoItem;
  position?: number; // required for create mode
  plusOneCount?: number; // view mode
  hasUserPlusOned?: boolean; // view mode
  onSave?: (data: Pick<BingoItem, 'emoji' | 'title' | 'description' | 'url'>) => void;
  onDelete?: () => void;
  onPlusOne?: () => void;
  onClose: () => void;
}

export function ItemModal({
  visible,
  mode,
  item,
  plusOneCount = 0,
  hasUserPlusOned = false,
  onSave,
  onDelete,
  onPlusOne,
  onClose,
}: ItemModalProps) {
  const [emoji, setEmoji] = useState('');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [url, setUrl] = useState('');

  useEffect(() => {
    if (visible) {
      setEmoji(item?.emoji ?? '');
      setTitle(item?.title ?? '');
      setDescription(item?.description ?? '');
      setUrl(item?.url ?? '');
    }
  }, [visible, item]);

  const handleSave = () => {
    if (!title.trim()) return;
    onSave?.({ emoji: emoji || '✨', title: title.trim(), description, url });
    onClose();
  };

  const handleDelete = () => {
    onDelete?.();
    onClose();
  };

  const isEditable = mode === 'create' || mode === 'edit';
  const titleText = mode === 'create' ? 'Add Item' : mode === 'edit' ? 'Edit Item' : item?.title ?? '';

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={onClose}>
      <TouchableWithoutFeedback onPress={onClose}>
        <View style={styles.backdrop} />
      </TouchableWithoutFeedback>

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={styles.sheetWrapper}
      >
        <View style={styles.sheet}>
          {/* Drag handle */}
          <View style={styles.handle} />

          <ScrollView showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">
            <Text style={styles.modalTitle}>{titleText}</Text>

            {isEditable ? (
              <>
                {/* Emoji input */}
                <Text style={styles.label}>Emoji</Text>
                <TextInput
                  style={styles.emojiInput}
                  value={emoji}
                  onChangeText={text => setEmoji(text.slice(-2))} // keep last emoji
                  placeholder="✨"
                  maxLength={2}
                />

                {/* Title input */}
                <Text style={styles.label}>Title *</Text>
                <TextInput
                  style={styles.input}
                  value={title}
                  onChangeText={setTitle}
                  placeholder="What do you want to do?"
                  maxLength={60}
                />

                {/* Description input */}
                <Text style={styles.label}>Details (optional)</Text>
                <TextInput
                  style={[styles.input, styles.multiline]}
                  value={description}
                  onChangeText={setDescription}
                  placeholder="Any notes or context…"
                  multiline
                  numberOfLines={3}
                />

                {/* URL input */}
                <Text style={styles.label}>Link (optional)</Text>
                <TextInput
                  style={styles.input}
                  value={url}
                  onChangeText={setUrl}
                  placeholder="https://…"
                  keyboardType="url"
                  autoCapitalize="none"
                />

                {/* Buttons */}
                <TouchableOpacity
                  style={[styles.button, styles.primaryButton, !title.trim() && styles.disabledButton]}
                  onPress={handleSave}
                  disabled={!title.trim()}
                >
                  <Text style={styles.primaryButtonText}>Save</Text>
                </TouchableOpacity>

                {mode === 'edit' && (
                  <TouchableOpacity style={[styles.button, styles.deleteButton]} onPress={handleDelete}>
                    <Text style={styles.deleteButtonText}>Delete Item</Text>
                  </TouchableOpacity>
                )}
              </>
            ) : (
              // View mode
              <>
                <Text style={styles.viewEmoji}>{item?.emoji}</Text>

                {item?.description ? (
                  <>
                    <Text style={styles.label}>Details</Text>
                    <Text style={styles.viewText}>{item.description}</Text>
                  </>
                ) : null}

                {item?.url ? (
                  <>
                    <Text style={styles.label}>Link</Text>
                    <Text style={[styles.viewText, styles.urlText]}>{item.url}</Text>
                  </>
                ) : null}

                <TouchableOpacity
                  style={[styles.button, hasUserPlusOned ? styles.plusOnedButton : styles.primaryButton]}
                  onPress={() => { onPlusOne?.(); onClose(); }}
                >
                  <Text style={styles.primaryButtonText}>
                    {hasUserPlusOned ? '✓ You're in!' : `+1  ·  ${plusOneCount} interested`}
                  </Text>
                </TouchableOpacity>
              </>
            )}

            <View style={{ height: 32 }} />
          </ScrollView>
        </View>
      </KeyboardAvoidingView>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
  },
  sheetWrapper: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
  },
  sheet: {
    backgroundColor: Colors.white,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingHorizontal: 20,
    paddingTop: 12,
    maxHeight: '85%',
  },
  handle: {
    width: 36,
    height: 4,
    backgroundColor: Colors.border,
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 16,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: Colors.text,
    marginBottom: 20,
  },
  label: {
    fontSize: 12,
    fontWeight: '600',
    color: Colors.muted,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
    marginTop: 14,
  },
  emojiInput: {
    fontSize: 32,
    textAlign: 'center',
    paddingVertical: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: 10,
    padding: 12,
    fontSize: 15,
    color: Colors.text,
    backgroundColor: Colors.background,
  },
  multiline: {
    height: 80,
    textAlignVertical: 'top',
  },
  button: {
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 20,
  },
  primaryButton: {
    backgroundColor: Colors.primary,
  },
  plusOnedButton: {
    backgroundColor: Colors.plusOne,
  },
  disabledButton: {
    backgroundColor: Colors.border,
  },
  deleteButton: {
    backgroundColor: Colors.background,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  primaryButtonText: {
    color: Colors.white,
    fontWeight: '700',
    fontSize: 16,
  },
  deleteButtonText: {
    color: Colors.plusOne,
    fontWeight: '600',
    fontSize: 15,
  },
  viewEmoji: {
    fontSize: 48,
    textAlign: 'center',
    marginVertical: 12,
  },
  viewText: {
    fontSize: 15,
    color: Colors.text,
    lineHeight: 22,
  },
  urlText: {
    color: Colors.primary,
    textDecorationLine: 'underline',
  },
});
```

- [ ] **Step 2: Commit**

```bash
git add components/ItemModal.tsx
git commit -m "feat: add ItemModal bottom sheet component"
```

---

### Task 9: App Navigation Layout

**Files:**
- Modify: `app/_layout.tsx`
- Modify: `app/(tabs)/_layout.tsx`

- [ ] **Step 1: Update root layout**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { initializeIfNeeded } from '../data/storage';

export default function RootLayout() {
  useEffect(() => {
    initializeIfNeeded();
  }, []);

  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="profile" options={{ title: 'Profile', presentation: 'modal' }} />
      <Stack.Screen name="friend/[id]" options={{ headerBackTitle: 'Friends' }} />
    </Stack>
  );
}
```

- [ ] **Step 2: Update tabs layout**

```typescript
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Text } from 'react-native';
import { MOCK_NOTIFICATIONS } from '../../data/mockData';
import { Colors } from '../../constants/colors';

const unreadCount = MOCK_NOTIFICATIONS.filter(n => !n.read).length;

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: Colors.primary,
        tabBarInactiveTintColor: Colors.muted,
        tabBarStyle: { borderTopColor: Colors.border },
        headerStyle: { backgroundColor: Colors.white },
        headerTitleStyle: { fontWeight: '700' },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'My Card',
          tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>◻️</Text>,
        }}
      />
      <Tabs.Screen
        name="friends"
        options={{
          title: 'Friends',
          tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>👥</Text>,
        }}
      />
      <Tabs.Screen
        name="notifications"
        options={{
          title: 'Notifications',
          tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>🔔</Text>,
          tabBarBadge: unreadCount > 0 ? unreadCount : undefined,
        }}
      />
    </Tabs>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add app/_layout.tsx app/(tabs)/_layout.tsx
git commit -m "feat: configure app navigation and tab bar"
```

---

### Task 10: My Card Screen

**Files:**
- Modify: `app/(tabs)/index.tsx`

- [ ] **Step 1: Implement My Card screen**

```typescript
// app/(tabs)/index.tsx
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { useRouter, useFocusEffect } from 'expo-router';
import { BingoGrid } from '../../components/BingoGrid';
import { ItemModal } from '../../components/ItemModal';
import { getUser, getBingoItems, saveBingoItem, deleteBingoItem, createBingoItem } from '../../data/storage';
import { CURRENT_USER_ID, getPlusOneCounts } from '../../data/mockData';
import { Colors } from '../../constants/colors';
import { User, BingoItem } from '../../types';

export default function MyCardScreen() {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [items, setItems] = useState<BingoItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalVisible, setModalVisible] = useState(false);
  const [selectedPosition, setSelectedPosition] = useState<number>(0);
  const [selectedItem, setSelectedItem] = useState<BingoItem | undefined>();

  const load = useCallback(async () => {
    const [u, i] = await Promise.all([getUser(), getBingoItems()]);
    setUser(u);
    setItems(i);
    setLoading(false);
  }, []);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  const plusOneCounts = React.useMemo(
    () => getPlusOneCounts(items.map(i => i.id)),
    [items]
  );

  const handleCellPress = (position: number, item?: BingoItem) => {
    setSelectedPosition(position);
    setSelectedItem(item);
    setModalVisible(true);
  };

  const handleSave = async (data: Pick<BingoItem, 'emoji' | 'title' | 'description' | 'url'>) => {
    if (selectedItem) {
      await saveBingoItem({ ...selectedItem, ...data });
    } else {
      const newItem = createBingoItem(CURRENT_USER_ID, selectedPosition, data);
      await saveBingoItem(newItem);
    }
    await load();
  };

  const handleDelete = async () => {
    if (selectedItem) {
      await deleteBingoItem(selectedItem.id);
      await load();
    }
  };

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator color={Colors.primary} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.greeting}>
            {user?.avatar_emoji} {user?.username ?? 'Your Card'}
          </Text>
          <Text style={styles.subtitle}>
            {items.length}/25 items
          </Text>
        </View>
        <TouchableOpacity
          style={styles.profileButton}
          onPress={() => router.push('/profile')}
        >
          <Text style={styles.profileButtonText}>Edit Profile</Text>
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <BingoGrid
          items={items}
          plusOneCounts={plusOneCounts}
          onCellPress={handleCellPress}
        />
      </ScrollView>

      <ItemModal
        visible={modalVisible}
        mode={selectedItem ? 'edit' : 'create'}
        item={selectedItem}
        position={selectedPosition}
        onSave={handleSave}
        onDelete={handleDelete}
        onClose={() => setModalVisible(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: Colors.white,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  greeting: {
    fontSize: 18,
    fontWeight: '700',
    color: Colors.text,
  },
  subtitle: {
    fontSize: 13,
    color: Colors.muted,
    marginTop: 2,
  },
  profileButton: {
    backgroundColor: Colors.primaryLight,
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 7,
  },
  profileButtonText: {
    color: Colors.primary,
    fontWeight: '600',
    fontSize: 13,
  },
  scrollContent: {
    paddingVertical: 16,
    paddingHorizontal: 16,
  },
});
```

- [ ] **Step 2: Verify manually**

Run `npx expo start`, open in iOS Simulator. You should see:
- Your seeded bingo card (20 filled cells, 5 empty)
- Plus-one count badges on items like "Try surfing" (3 people), "Taco road trip" (2 people)
- Tapping a filled cell opens the edit modal
- Tapping an empty cell opens the create modal
- Saving an item updates the grid

- [ ] **Step 3: Commit**

```bash
git add app/(tabs)/index.tsx
git commit -m "feat: implement My Card screen"
```

---

### Task 11: Profile Screen

**Files:**
- Create: `app/profile.tsx`

- [ ] **Step 1: Create profile.tsx**

```typescript
// app/profile.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { getUser, saveUser } from '../data/storage';
import { Colors } from '../constants/colors';
import { User } from '../types';

export default function ProfileScreen() {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [emoji, setEmoji] = useState('');
  const [username, setUsername] = useState('');
  const [bio, setBio] = useState('');

  useEffect(() => {
    getUser().then(u => {
      if (u) {
        setUser(u);
        setEmoji(u.avatar_emoji);
        setUsername(u.username);
        setBio(u.bio);
      }
    });
  }, []);

  const handleSave = async () => {
    if (!user) return;
    if (!username.trim()) {
      Alert.alert('Username required', 'Please enter a username.');
      return;
    }
    await saveUser({ ...user, avatar_emoji: emoji || '😎', username: username.trim(), bio });
    router.back();
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        <Text style={styles.avatarLabel}>Avatar Emoji</Text>
        <TextInput
          style={styles.emojiInput}
          value={emoji}
          onChangeText={text => setEmoji(text.slice(-2))}
          placeholder="😎"
          maxLength={2}
        />

        <Text style={styles.label}>Username</Text>
        <TextInput
          style={styles.input}
          value={username}
          onChangeText={setUsername}
          placeholder="your handle"
          autoCapitalize="none"
          maxLength={30}
        />

        <Text style={styles.label}>Bio (optional)</Text>
        <TextInput
          style={[styles.input, styles.multiline]}
          value={bio}
          onChangeText={setBio}
          placeholder="Tell your friends a little about yourself…"
          multiline
          numberOfLines={3}
          maxLength={120}
        />

        <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
          <Text style={styles.saveButtonText}>Save</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  content: {
    padding: 20,
  },
  avatarLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: Colors.muted,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
  },
  emojiInput: {
    fontSize: 48,
    textAlign: 'center',
    paddingVertical: 12,
    marginBottom: 16,
  },
  label: {
    fontSize: 12,
    fontWeight: '600',
    color: Colors.muted,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
    marginTop: 16,
  },
  input: {
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: 10,
    padding: 12,
    fontSize: 15,
    color: Colors.text,
    backgroundColor: Colors.white,
  },
  multiline: {
    height: 80,
    textAlignVertical: 'top',
  },
  saveButton: {
    backgroundColor: Colors.primary,
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 28,
  },
  saveButtonText: {
    color: Colors.white,
    fontWeight: '700',
    fontSize: 16,
  },
});
```

- [ ] **Step 2: Commit**

```bash
git add app/profile.tsx
git commit -m "feat: implement Profile screen"
```

---

### Task 12: Friends Screen

**Files:**
- Create: `app/(tabs)/friends.tsx`

- [ ] **Step 1: Create friends.tsx**

```typescript
// app/(tabs)/friends.tsx
import React from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { MOCK_USERS, MOCK_FRIEND_ITEMS } from '../../data/mockData';
import { Colors } from '../../constants/colors';
import { User } from '../../types';

export default function FriendsScreen() {
  const router = useRouter();

  const renderFriend = ({ item }: { item: User }) => {
    const itemCount = MOCK_FRIEND_ITEMS[item.id]?.length ?? 0;
    return (
      <TouchableOpacity
        style={styles.row}
        onPress={() => router.push(`/friend/${item.id}`)}
        activeOpacity={0.7}
      >
        <View style={styles.avatar}>
          <Text style={styles.avatarEmoji}>{item.avatar_emoji}</Text>
        </View>
        <View style={styles.info}>
          <Text style={styles.username}>@{item.username}</Text>
          {item.bio ? <Text style={styles.bio} numberOfLines={1}>{item.bio}</Text> : null}
        </View>
        <View style={styles.meta}>
          <Text style={styles.metaText}>{itemCount} items</Text>
          <Text style={styles.chevron}>›</Text>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <FlatList
        data={MOCK_USERS}
        keyExtractor={u => u.id}
        renderItem={renderFriend}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        contentContainerStyle={styles.list}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  list: {
    padding: 16,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: 12,
    padding: 14,
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: Colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  avatarEmoji: {
    fontSize: 24,
  },
  info: {
    flex: 1,
  },
  username: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.text,
  },
  bio: {
    fontSize: 13,
    color: Colors.muted,
    marginTop: 2,
  },
  meta: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  metaText: {
    fontSize: 13,
    color: Colors.muted,
  },
  chevron: {
    fontSize: 20,
    color: Colors.muted,
  },
  separator: {
    height: 8,
  },
});
```

- [ ] **Step 2: Commit**

```bash
git add app/(tabs)/friends.tsx
git commit -m "feat: implement Friends list screen"
```

---

### Task 13: Friend's Card Screen

**Files:**
- Create: `app/friend/[id].tsx`

- [ ] **Step 1: Create app/friend/[id].tsx**

```typescript
// app/friend/[id].tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useLocalSearchParams, useNavigation, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { BingoGrid } from '../../components/BingoGrid';
import { ItemModal } from '../../components/ItemModal';
import { getMockUser, getMockFriendItems } from '../../data/mockData';
import { Colors } from '../../constants/colors';
import { BingoItem } from '../../types';

export default function FriendCardScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const navigation = useNavigation();

  const friend = getMockUser(id);
  const items = getMockFriendItems(id);

  // Track plus-ones by item_id for this session
  const [myPlusOnes, setMyPlusOnes] = useState<Set<string>>(new Set());
  const [plusOneCounts, setPlusOneCounts] = useState<Record<string, number>>({});

  // Modal state
  const [modalVisible, setModalVisible] = useState(false);
  const [selectedItem, setSelectedItem] = useState<BingoItem | undefined>();

  useEffect(() => {
    if (friend) {
      navigation.setOptions({ title: `@${friend.username}` });
    }
  }, [friend, navigation]);

  const handleCellPress = (_position: number, item?: BingoItem) => {
    if (!item) return; // no-op on empty cells for read-only card
    setSelectedItem(item);
    setModalVisible(true);
  };

  const handlePlusOne = () => {
    if (!selectedItem) return;
    const wasAlreadyPlusOned = myPlusOnes.has(selectedItem.id);
    setMyPlusOnes(prev => {
      const next = new Set(prev);
      if (wasAlreadyPlusOned) {
        next.delete(selectedItem.id);
      } else {
        next.add(selectedItem.id);
      }
      return next;
    });
    setPlusOneCounts(prev => ({
      ...prev,
      [selectedItem.id]: Math.max(0, (prev[selectedItem.id] ?? 0) + (wasAlreadyPlusOned ? -1 : 1)),
    }));
  };

  if (!friend) {
    return (
      <View style={styles.centered}>
        <Text style={styles.notFound}>Friend not found</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Profile header */}
      <View style={styles.profileHeader}>
        <Text style={styles.avatarEmoji}>{friend.avatar_emoji}</Text>
        <Text style={styles.username}>@{friend.username}</Text>
        {friend.bio ? <Text style={styles.bio}>{friend.bio}</Text> : null}
        <Text style={styles.itemCount}>{items.length} items on their card</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <BingoGrid
          items={items}
          plusOneCounts={plusOneCounts}
          onCellPress={handleCellPress}
        />
      </ScrollView>

      <ItemModal
        visible={modalVisible}
        mode="view"
        item={selectedItem}
        plusOneCount={selectedItem ? (plusOneCounts[selectedItem.id] ?? 0) : 0}
        hasUserPlusOned={selectedItem ? myPlusOnes.has(selectedItem.id) : false}
        onPlusOne={handlePlusOne}
        onClose={() => setModalVisible(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  notFound: {
    color: Colors.muted,
    fontSize: 16,
  },
  profileHeader: {
    alignItems: 'center',
    paddingVertical: 20,
    backgroundColor: Colors.white,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  avatarEmoji: {
    fontSize: 48,
    marginBottom: 6,
  },
  username: {
    fontSize: 18,
    fontWeight: '700',
    color: Colors.text,
  },
  bio: {
    fontSize: 14,
    color: Colors.muted,
    marginTop: 4,
    textAlign: 'center',
    paddingHorizontal: 24,
  },
  itemCount: {
    fontSize: 12,
    color: Colors.muted,
    marginTop: 6,
  },
  scrollContent: {
    paddingVertical: 16,
    paddingHorizontal: 16,
  },
});
```

- [ ] **Step 2: Commit**

```bash
git add app/friend/[id].tsx
git commit -m "feat: implement Friend's Card screen with plus-one"
```

---

### Task 14: Notifications Screen

**Files:**
- Create: `app/(tabs)/notifications.tsx`

- [ ] **Step 1: Create notifications.tsx**

```typescript
// app/(tabs)/notifications.tsx
import React from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { MOCK_NOTIFICATIONS } from '../../data/mockData';
import { Colors } from '../../constants/colors';
import { NotificationItem } from '../../types';

function timeAgo(isoString: string): string {
  const diff = Date.now() - new Date(isoString).getTime();
  const days = Math.floor(diff / 86400000);
  if (days > 0) return `${days}d ago`;
  const hours = Math.floor(diff / 3600000);
  if (hours > 0) return `${hours}h ago`;
  return 'just now';
}

export default function NotificationsScreen() {
  const renderItem = ({ item }: { item: NotificationItem }) => (
    <View style={[styles.row, !item.read && styles.unreadRow]}>
      <View style={styles.avatar}>
        <Text style={styles.avatarEmoji}>{item.from_avatar_emoji}</Text>
      </View>
      <View style={styles.content}>
        <Text style={styles.message}>
          <Text style={styles.bold}>@{item.from_username}</Text>
          {' wants to '}
          <Text style={styles.itemTitle}>"{item.item_title}"</Text>
        </Text>
        <Text style={styles.timestamp}>{timeAgo(item.created_at)}</Text>
      </View>
      {!item.read && <View style={styles.unreadDot} />}
    </View>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={MOCK_NOTIFICATIONS}
        keyExtractor={n => n.id}
        renderItem={renderItem}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <Text style={styles.empty}>No notifications yet</Text>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  list: {
    padding: 16,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: 12,
    padding: 14,
  },
  unreadRow: {
    backgroundColor: Colors.primaryLight,
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Colors.background,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  avatarEmoji: {
    fontSize: 22,
  },
  content: {
    flex: 1,
  },
  message: {
    fontSize: 14,
    color: Colors.text,
    lineHeight: 20,
  },
  bold: {
    fontWeight: '700',
  },
  itemTitle: {
    fontStyle: 'italic',
  },
  timestamp: {
    fontSize: 12,
    color: Colors.muted,
    marginTop: 3,
  },
  unreadDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: Colors.primary,
    marginLeft: 8,
  },
  separator: {
    height: 8,
  },
  empty: {
    textAlign: 'center',
    color: Colors.muted,
    marginTop: 60,
    fontSize: 15,
  },
});
```

- [ ] **Step 2: Verify final app**

Run `npx expo start`, press `i` for iOS Simulator and walk through:
1. My Card tab — seeded bingo card with plus-one counts visible
2. Tap a filled cell — modal shows with edit fields, Save and Delete work
3. Tap an empty cell — modal lets you add a new item
4. Edit Profile button — opens profile modal, save updates the header
5. Friends tab — list of 4 mock friends
6. Tap a friend — their 5x5 card, tap a cell to see details and plus-one it
7. Notifications tab — list of who plus-oned your items, 3 unread badge visible

- [ ] **Step 3: Commit**

```bash
git add app/(tabs)/notifications.tsx
git commit -m "feat: implement Notifications screen"
```

---

## Done

All 5 screens are implemented. The app is a fully navigable prototype with:
- Your editable 5x5 bingo card with plus-one counts from mock friends
- 4 mock friends with full cards you can browse and plus-one
- Notification feed of friend activity
- Profile editing

**Next step when ready:** Swap mock social data for real Supabase tables (auth, BingoItem, PlusOne, Friendship, Notification). The data types in `types/index.ts` map directly to Supabase table schemas.
