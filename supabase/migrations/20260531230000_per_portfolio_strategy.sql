-- Completamento multi-portafoglio: piano, target, ribilanciamento e snapshot
-- diventano per-portafoglio. Cambiano i vincoli di unicità.

-- plans: una per portafoglio
alter table public.plans
  add column if not exists portfolio_id bigint references public.portfolios (id) on delete cascade;
alter table public.plans drop constraint if exists plans_user_id_key;
alter table public.plans drop constraint if exists plans_user_portfolio_key;
alter table public.plans add constraint plans_user_portfolio_key unique (user_id, portfolio_id);

-- target_allocations: per portafoglio + asset class
alter table public.target_allocations
  add column if not exists portfolio_id bigint references public.portfolios (id) on delete cascade;
alter table public.target_allocations drop constraint if exists target_allocations_user_id_asset_class_key;
alter table public.target_allocations drop constraint if exists targets_user_portfolio_class_key;
alter table public.target_allocations add constraint targets_user_portfolio_class_key unique (user_id, portfolio_id, asset_class);

-- rebalance_settings: una per portafoglio (PK passa da user_id a unique composito)
alter table public.rebalance_settings
  add column if not exists portfolio_id bigint references public.portfolios (id) on delete cascade;
alter table public.rebalance_settings drop constraint if exists rebalance_settings_pkey;
alter table public.rebalance_settings drop constraint if exists rebalance_settings_user_portfolio_key;
alter table public.rebalance_settings add constraint rebalance_settings_user_portfolio_key unique (user_id, portfolio_id);

-- portfolio_snapshots: per portafoglio + data
alter table public.portfolio_snapshots
  add column if not exists portfolio_id bigint references public.portfolios (id) on delete cascade;
alter table public.portfolio_snapshots drop constraint if exists portfolio_snapshots_user_id_snapshot_date_key;
alter table public.portfolio_snapshots drop constraint if exists snapshots_user_portfolio_date_key;
alter table public.portfolio_snapshots add constraint snapshots_user_portfolio_date_key unique (user_id, portfolio_id, snapshot_date);
