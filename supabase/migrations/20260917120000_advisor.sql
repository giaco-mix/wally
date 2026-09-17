-- Modalità consulente (pivot B2B2C). Non-breaking: il retail resta invariato.

-- Ruolo sul profilo (default retail).
alter table public.profiles
  add column if not exists role text not null default 'retail';

-- Collegamento consulente ↔ cliente, con invito per email.
create table if not exists public.advisor_clients (
  id           bigint generated always as identity primary key,
  advisor_id   uuid not null references auth.users (id) on delete cascade,
  client_email text not null,
  client_label text,
  client_id    uuid references auth.users (id) on delete cascade,
  status       text not null default 'pending', -- pending | active | revoked
  created_at   timestamptz not null default now(),
  unique (advisor_id, client_email)
);
create index if not exists advisor_clients_advisor_idx
  on public.advisor_clients (advisor_id);
create index if not exists advisor_clients_email_idx
  on public.advisor_clients (client_email);

alter table public.advisor_clients enable row level security;

-- Il consulente gestisce i propri collegamenti.
drop policy if exists "advisor_clients: consulente gestisce" on public.advisor_clients;
create policy "advisor_clients: consulente gestisce"
  on public.advisor_clients for all
  using (advisor_id = auth.uid())
  with check (advisor_id = auth.uid());

-- Il cliente vede gli inviti indirizzati alla propria email…
drop policy if exists "advisor_clients: cliente vede invito" on public.advisor_clients;
create policy "advisor_clients: cliente vede invito"
  on public.advisor_clients for select
  using (client_email = (auth.jwt() ->> 'email'));

-- …e può accettarli (collega il proprio id e mette 'active').
drop policy if exists "advisor_clients: cliente accetta" on public.advisor_clients;
create policy "advisor_clients: cliente accetta"
  on public.advisor_clients for update
  using (client_email = (auth.jwt() ->> 'email'))
  with check (client_email = (auth.jwt() ->> 'email'));

-- Il consulente legge (SOLO SELECT) i dati dei clienti collegati e ATTIVI.
-- Additiva: non tocca le policy "vedi i tuoi" già esistenti.
create or replace function public.is_active_client(target uuid)
returns boolean language sql stable security invoker as $$
  select exists (
    select 1 from public.advisor_clients ac
    where ac.advisor_id = auth.uid()
      and ac.client_id = target
      and ac.status = 'active'
  );
$$;

drop policy if exists "holdings: lettura consulente" on public.holdings;
create policy "holdings: lettura consulente"
  on public.holdings for select using (public.is_active_client(user_id));

drop policy if exists "transactions: lettura consulente" on public.transactions;
create policy "transactions: lettura consulente"
  on public.transactions for select using (public.is_active_client(user_id));
