-- Costi: attributi fondo sulle posizioni + broker/piattaforme con commissioni.

-- Attributi fondo sulle posizioni
alter table public.holdings
  add column if not exists ter numeric not null default 0,
  add column if not exists distribution text;

-- Broker / piattaforme dell'utente
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

create policy "brokers: select propri"
  on public.brokers for select using (auth.uid() = user_id);
create policy "brokers: insert propri"
  on public.brokers for insert with check (auth.uid() = user_id);
create policy "brokers: update propri"
  on public.brokers for update using (auth.uid() = user_id);
create policy "brokers: delete propri"
  on public.brokers for delete using (auth.uid() = user_id);
