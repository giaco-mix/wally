-- Comparto (core/satellite) sulle operazioni del PAC.
alter table public.transactions
  add column if not exists sleeve text not null default 'none';
