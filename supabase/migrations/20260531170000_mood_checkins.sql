-- Check-in dello stato d'animo dell'investitore (modulo comportamentale).
create table if not exists public.mood_checkins (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  mood text not null,
  created_at timestamptz not null default now()
);

create index if not exists mood_user_idx on public.mood_checkins (user_id, created_at desc);

alter table public.mood_checkins enable row level security;

create policy "mood: select propri"
  on public.mood_checkins for select using (auth.uid() = user_id);
create policy "mood: insert propri"
  on public.mood_checkins for insert with check (auth.uid() = user_id);
create policy "mood: delete propri"
  on public.mood_checkins for delete using (auth.uid() = user_id);
