-- Registro (ledger) delle operazioni: acquisti/vendite con data e prezzo.
create table if not exists public.transactions (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  symbol text not null,
  name text,
  side text not null default 'buy',
  kind text not null default 'manual',
  tx_date date not null,
  quantity numeric not null check (quantity > 0),
  price numeric not null check (price >= 0),
  asset_class text not null default 'etf',
  currency text not null default 'EUR',
  ter numeric not null default 0,
  distribution text,
  leverage int not null default 1,
  created_at timestamptz not null default now()
);

create index if not exists tx_user_date_idx on public.transactions (user_id, tx_date desc);

alter table public.transactions enable row level security;

create policy "tx: select propri"
  on public.transactions for select using (auth.uid() = user_id);
create policy "tx: insert propri"
  on public.transactions for insert with check (auth.uid() = user_id);
create policy "tx: delete propri"
  on public.transactions for delete using (auth.uid() = user_id);
