-- Impostazioni di ribilanciamento schedulato (una riga per utente).
create table if not exists public.rebalance_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  frequency text not null default 'none',
  last_rebalanced_at date,
  updated_at timestamptz not null default now()
);

alter table public.rebalance_settings enable row level security;

create policy "rebalance_settings: select propri"
  on public.rebalance_settings for select using (auth.uid() = user_id);
create policy "rebalance_settings: insert propri"
  on public.rebalance_settings for insert with check (auth.uid() = user_id);
create policy "rebalance_settings: update propri"
  on public.rebalance_settings for update using (auth.uid() = user_id);
