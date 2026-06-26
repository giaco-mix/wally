-- Multi-portafoglio: ogni utente può avere più portafogli/obiettivi.
create table if not exists public.portfolios (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

alter table public.portfolios enable row level security;

create policy "portfolios: select propri"
  on public.portfolios for select using (auth.uid() = user_id);
create policy "portfolios: insert propri"
  on public.portfolios for insert with check (auth.uid() = user_id);
create policy "portfolios: update propri"
  on public.portfolios for update using (auth.uid() = user_id);
create policy "portfolios: delete propri"
  on public.portfolios for delete using (auth.uid() = user_id);

-- Collega posizioni e operazioni a un portafoglio (null = principale).
alter table public.holdings
  add column if not exists portfolio_id bigint references public.portfolios (id) on delete cascade;
alter table public.transactions
  add column if not exists portfolio_id bigint references public.portfolios (id) on delete cascade;
