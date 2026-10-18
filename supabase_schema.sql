-- ANCHOR IOTA — Supabase schema + row-level security
-- Run this once in your Supabase project: SQL Editor → paste → Run.

-- 1) Per-user app state (profile, values, goal, journal, feedback log, learned weights)
create table if not exists public.anchor_state (
  user_id    uuid primary key references auth.users on delete cascade,
  data       jsonb not null default '{}',
  updated_at timestamptz not null default now()
);
alter table public.anchor_state enable row level security;
drop policy if exists "own state" on public.anchor_state;
create policy "own state" on public.anchor_state
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 2) Append-only feedback log — the data the recommender learns from (for tuning / the pilot)
create table if not exists public.anchor_events (
  id           bigint generated always as identity primary key,
  user_id      uuid references auth.users on delete cascade,
  created_at   timestamptz not null default now(),
  anchor_id    text,
  pillar       text,
  mins         int,
  did          text,     -- Yes / Partly / No
  helpful      int,      -- 1..5
  align        int,      -- 1..5 (adrift..anchored)
  off_reason   text,     -- wrong-time / too-much / not-for-me / already
  profile_more text
);
alter table public.anchor_events enable row level security;
drop policy if exists "own events insert" on public.anchor_events;
drop policy if exists "own events read" on public.anchor_events;
create policy "own events insert" on public.anchor_events
  for insert with check (auth.uid() = user_id);
create policy "own events read" on public.anchor_events
  for select using (auth.uid() = user_id);

-- Notes:
-- * The anon public key is safe to ship in the page. RLS above is the security boundary:
--   every row is readable/writable only by the user who owns it.
-- * The service_role key must NEVER appear in the web app.
-- * "Delete all my data" in the app wipes the device copy; add a server delete (an RPC or a
--   Supabase function) before real users so account deletion is one tap (Apple/PHI expectation).
