-- PAC realistico: cadenza dei versamenti e versamento iniziale (maxi-canone).
alter table public.plans
  add column if not exists frequency text not null default 'monthly',
  add column if not exists initial_lump numeric not null default 0;
