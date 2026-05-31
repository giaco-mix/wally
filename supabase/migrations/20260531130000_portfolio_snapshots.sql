-- Snapshot giornalieri del valore del portafoglio, per la curva di performance.
create table if not exists public.portfolio_snapshots (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  snapshot_date date not null,
  total_value numeric not null,
  created_at timestamptz not null default now(),
  unique (user_id, snapshot_date)
);

create index if not exists snapshots_user_date_idx
  on public.portfolio_snapshots (user_id, snapshot_date);

alter table public.portfolio_snapshots enable row level security;

create policy "snapshots: select propri"
  on public.portfolio_snapshots for select using (auth.uid() = user_id);
create policy "snapshots: insert propri"
  on public.portfolio_snapshots for insert with check (auth.uid() = user_id);
create policy "snapshots: update propri"
  on public.portfolio_snapshots for update using (auth.uid() = user_id);
create policy "snapshots: delete propri"
  on public.portfolio_snapshots for delete using (auth.uid() = user_id);
