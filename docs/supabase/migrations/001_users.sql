-- 001_users.sql
-- Run this in Supabase SQL Editor before launching the app.

create table if not exists users (
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
