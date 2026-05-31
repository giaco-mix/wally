-- Finance Companion — schema iniziale
-- Tabelle: profiles, holdings, target_allocations. RLS attiva: ogni utente
-- vede e modifica solo i propri dati.

-- Profilo utente (1:1 con auth.users) ---------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  base_currency text not null default 'EUR',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profili: select propri"
  on public.profiles for select using (auth.uid() = id);
create policy "profili: insert propri"
  on public.profiles for insert with check (auth.uid() = id);
create policy "profili: update propri"
  on public.profiles for update using (auth.uid() = id);

-- Crea automaticamente il profilo alla registrazione --------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.email);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Posizioni del portafoglio ---------------------------------------------------
create table if not exists public.holdings (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  symbol text not null,
  name text,
  quantity numeric not null check (quantity > 0),
  avg_price numeric not null check (avg_price >= 0),
  asset_class text not null default 'stock',
  sector text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists holdings_user_idx on public.holdings (user_id);

alter table public.holdings enable row level security;

create policy "holdings: select propri"
  on public.holdings for select using (auth.uid() = user_id);
create policy "holdings: insert propri"
  on public.holdings for insert with check (auth.uid() = user_id);
create policy "holdings: update propri"
  on public.holdings for update using (auth.uid() = user_id);
create policy "holdings: delete propri"
  on public.holdings for delete using (auth.uid() = user_id);

-- Allocazione target per asset class ------------------------------------------
create table if not exists public.target_allocations (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  asset_class text not null,
  target_pct numeric not null check (target_pct >= 0 and target_pct <= 100),
  unique (user_id, asset_class)
);

create index if not exists targets_user_idx on public.target_allocations (user_id);

alter table public.target_allocations enable row level security;

create policy "targets: select propri"
  on public.target_allocations for select using (auth.uid() = user_id);
create policy "targets: insert propri"
  on public.target_allocations for insert with check (auth.uid() = user_id);
create policy "targets: update propri"
  on public.target_allocations for update using (auth.uid() = user_id);
create policy "targets: delete propri"
  on public.target_allocations for delete using (auth.uid() = user_id);

-- Mantiene updated_at aggiornato ----------------------------------------------
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists holdings_touch on public.holdings;
create trigger holdings_touch
  before update on public.holdings
  for each row execute function public.touch_updated_at();
