-- ============================================================================
-- Wally — Script di allineamento DB (idempotente)
-- ----------------------------------------------------------------------------
-- Esegui TUTTO questo file nel SQL Editor di Supabase per portare il database
-- allo stato corrente dell'app. È sicuro rieseguirlo: usa "if not exists" e
-- ricrea le policy (drop + create), quindi non dà errori se già applicato.
-- Riassume tutte le migration in supabase/migrations/.
-- ============================================================================

-- === profiles ===============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  base_currency text not null default 'EUR',
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

drop policy if exists "profili: select propri" on public.profiles;
drop policy if exists "profili: insert propri" on public.profiles;
drop policy if exists "profili: update propri" on public.profiles;
create policy "profili: select propri" on public.profiles for select using (auth.uid() = id);
create policy "profili: insert propri" on public.profiles for insert with check (auth.uid() = id);
create policy "profili: update propri" on public.profiles for update using (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name) values (new.id, new.email);
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- === holdings (incl. ter + distribution della Fase 2) =======================
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
alter table public.holdings add column if not exists ter numeric not null default 0;
alter table public.holdings add column if not exists distribution text;
alter table public.holdings add column if not exists currency text not null default 'EUR';
alter table public.holdings add column if not exists leverage int not null default 1;
create index if not exists holdings_user_idx on public.holdings (user_id);
alter table public.holdings enable row level security;

drop policy if exists "holdings: select propri" on public.holdings;
drop policy if exists "holdings: insert propri" on public.holdings;
drop policy if exists "holdings: update propri" on public.holdings;
drop policy if exists "holdings: delete propri" on public.holdings;
create policy "holdings: select propri" on public.holdings for select using (auth.uid() = user_id);
create policy "holdings: insert propri" on public.holdings for insert with check (auth.uid() = user_id);
create policy "holdings: update propri" on public.holdings for update using (auth.uid() = user_id);
create policy "holdings: delete propri" on public.holdings for delete using (auth.uid() = user_id);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
drop trigger if exists holdings_touch on public.holdings;
create trigger holdings_touch before update on public.holdings
  for each row execute function public.touch_updated_at();

-- === target_allocations =====================================================
create table if not exists public.target_allocations (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  asset_class text not null,
  target_pct numeric not null check (target_pct >= 0 and target_pct <= 100),
  unique (user_id, asset_class)
);
create index if not exists targets_user_idx on public.target_allocations (user_id);
alter table public.target_allocations enable row level security;

drop policy if exists "targets: select propri" on public.target_allocations;
drop policy if exists "targets: insert propri" on public.target_allocations;
drop policy if exists "targets: update propri" on public.target_allocations;
drop policy if exists "targets: delete propri" on public.target_allocations;
create policy "targets: select propri" on public.target_allocations for select using (auth.uid() = user_id);
create policy "targets: insert propri" on public.target_allocations for insert with check (auth.uid() = user_id);
create policy "targets: update propri" on public.target_allocations for update using (auth.uid() = user_id);
create policy "targets: delete propri" on public.target_allocations for delete using (auth.uid() = user_id);

-- === portfolio_snapshots (performance nel tempo) ============================
create table if not exists public.portfolio_snapshots (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  snapshot_date date not null,
  total_value numeric not null,
  created_at timestamptz not null default now(),
  unique (user_id, snapshot_date)
);
create index if not exists snapshots_user_date_idx on public.portfolio_snapshots (user_id, snapshot_date);
alter table public.portfolio_snapshots enable row level security;

drop policy if exists "snapshots: select propri" on public.portfolio_snapshots;
drop policy if exists "snapshots: insert propri" on public.portfolio_snapshots;
drop policy if exists "snapshots: update propri" on public.portfolio_snapshots;
drop policy if exists "snapshots: delete propri" on public.portfolio_snapshots;
create policy "snapshots: select propri" on public.portfolio_snapshots for select using (auth.uid() = user_id);
create policy "snapshots: insert propri" on public.portfolio_snapshots for insert with check (auth.uid() = user_id);
create policy "snapshots: update propri" on public.portfolio_snapshots for update using (auth.uid() = user_id);
create policy "snapshots: delete propri" on public.portfolio_snapshots for delete using (auth.uid() = user_id);

-- === plans (Fase 1: onboarding & piano) =====================================
create table if not exists public.plans (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  goal_type text not null,
  goal_label text,
  mode text not null,
  target_amount numeric,
  horizon_years int not null,
  monthly_contribution numeric not null,
  risk_profile text not null,
  lazy_portfolio_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);
alter table public.plans enable row level security;

drop policy if exists "plans: select propri" on public.plans;
drop policy if exists "plans: insert propri" on public.plans;
drop policy if exists "plans: update propri" on public.plans;
drop policy if exists "plans: delete propri" on public.plans;
create policy "plans: select propri" on public.plans for select using (auth.uid() = user_id);
create policy "plans: insert propri" on public.plans for insert with check (auth.uid() = user_id);
create policy "plans: update propri" on public.plans for update using (auth.uid() = user_id);
create policy "plans: delete propri" on public.plans for delete using (auth.uid() = user_id);

-- === brokers (Fase 2: costi/commissioni) ====================================
create table if not exists public.brokers (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  account_fee_annual numeric not null default 0,
  order_fee_fixed numeric not null default 0,
  order_fee_percent numeric not null default 0,
  created_at timestamptz not null default now()
);
alter table public.brokers enable row level security;

drop policy if exists "brokers: select propri" on public.brokers;
drop policy if exists "brokers: insert propri" on public.brokers;
drop policy if exists "brokers: update propri" on public.brokers;
drop policy if exists "brokers: delete propri" on public.brokers;
create policy "brokers: select propri" on public.brokers for select using (auth.uid() = user_id);
create policy "brokers: insert propri" on public.brokers for insert with check (auth.uid() = user_id);
create policy "brokers: update propri" on public.brokers for update using (auth.uid() = user_id);
create policy "brokers: delete propri" on public.brokers for delete using (auth.uid() = user_id);

-- === rebalance_settings (Fase 3: cadenza) ===================================
create table if not exists public.rebalance_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  frequency text not null default 'none',
  last_rebalanced_at date,
  updated_at timestamptz not null default now()
);
alter table public.rebalance_settings enable row level security;

drop policy if exists "rebalance_settings: select propri" on public.rebalance_settings;
drop policy if exists "rebalance_settings: insert propri" on public.rebalance_settings;
drop policy if exists "rebalance_settings: update propri" on public.rebalance_settings;
create policy "rebalance_settings: select propri" on public.rebalance_settings for select using (auth.uid() = user_id);
create policy "rebalance_settings: insert propri" on public.rebalance_settings for insert with check (auth.uid() = user_id);
create policy "rebalance_settings: update propri" on public.rebalance_settings for update using (auth.uid() = user_id);

-- === mood_checkins (Fase 4: modulo comportamentale) =========================
create table if not exists public.mood_checkins (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  mood text not null,
  created_at timestamptz not null default now()
);
create index if not exists mood_user_idx on public.mood_checkins (user_id, created_at desc);
alter table public.mood_checkins enable row level security;

drop policy if exists "mood: select propri" on public.mood_checkins;
drop policy if exists "mood: insert propri" on public.mood_checkins;
drop policy if exists "mood: delete propri" on public.mood_checkins;
create policy "mood: select propri" on public.mood_checkins for select using (auth.uid() = user_id);
create policy "mood: insert propri" on public.mood_checkins for insert with check (auth.uid() = user_id);
create policy "mood: delete propri" on public.mood_checkins for delete using (auth.uid() = user_id);

-- === web push (sottoscrizioni + log invii) ==================================
create table if not exists public.push_subscriptions (
  endpoint   text primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  p256dh     text not null,
  auth       text not null,
  user_agent text,
  created_at timestamptz not null default now()
);
create index if not exists push_subs_user_idx on public.push_subscriptions (user_id);
alter table public.push_subscriptions enable row level security;

drop policy if exists "push_subs: select propri" on public.push_subscriptions;
drop policy if exists "push_subs: insert propri" on public.push_subscriptions;
drop policy if exists "push_subs: delete propri" on public.push_subscriptions;
create policy "push_subs: select propri" on public.push_subscriptions for select using (auth.uid() = user_id);
create policy "push_subs: insert propri" on public.push_subscriptions for insert with check (auth.uid() = user_id);
create policy "push_subs: delete propri" on public.push_subscriptions for delete using (auth.uid() = user_id);

create table if not exists public.push_notification_log (
  user_id uuid not null references auth.users (id) on delete cascade,
  kind    text not null,
  sent_on date not null default current_date,
  primary key (user_id, kind, sent_on)
);
alter table public.push_notification_log enable row level security;
drop policy if exists "push_log: select propri" on public.push_notification_log;
create policy "push_log: select propri" on public.push_notification_log for select using (auth.uid() = user_id);
