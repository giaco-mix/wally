-- Attributi strumento: valuta (EUR/USD) e leva (ETF a leva).
alter table public.holdings
  add column if not exists currency text not null default 'EUR',
  add column if not exists leverage int not null default 1;
