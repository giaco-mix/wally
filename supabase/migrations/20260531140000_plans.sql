-- Piano d'investimento dell'utente (uno attivo per utente).
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

create policy "plans: select propri"
  on public.plans for select using (auth.uid() = user_id);
create policy "plans: insert propri"
  on public.plans for insert with check (auth.uid() = user_id);
create policy "plans: update propri"
  on public.plans for update using (auth.uid() = user_id);
create policy "plans: delete propri"
  on public.plans for delete using (auth.uid() = user_id);
