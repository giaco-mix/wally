-- Web Push: sottoscrizioni dei browser + log invii (anti-duplicato giornaliero).

-- Una riga per ogni sottoscrizione push di un browser/dispositivo dell'utente.
create table if not exists public.push_subscriptions (
  endpoint   text primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  p256dh     text not null,
  auth       text not null,
  user_agent text,
  created_at timestamptz not null default now()
);

create index if not exists push_subs_user_idx
  on public.push_subscriptions (user_id);

alter table public.push_subscriptions enable row level security;

-- L'utente gestisce solo le proprie sottoscrizioni dal client (anon key).
-- L'edge function usa la service_role e bypassa la RLS per leggerle tutte.
drop policy if exists "push_subs: select propri" on public.push_subscriptions;
drop policy if exists "push_subs: insert propri" on public.push_subscriptions;
drop policy if exists "push_subs: delete propri" on public.push_subscriptions;
create policy "push_subs: select propri"
  on public.push_subscriptions for select using (auth.uid() = user_id);
create policy "push_subs: insert propri"
  on public.push_subscriptions for insert with check (auth.uid() = user_id);
create policy "push_subs: delete propri"
  on public.push_subscriptions for delete using (auth.uid() = user_id);

-- Log degli invii: una riga per (utente, tipo, giorno) così il cron non manda
-- la stessa notifica più volte nello stesso giorno. Scritto dalla service_role.
create table if not exists public.push_notification_log (
  user_id uuid not null references auth.users (id) on delete cascade,
  kind    text not null,
  sent_on date not null default current_date,
  primary key (user_id, kind, sent_on)
);

alter table public.push_notification_log enable row level security;

drop policy if exists "push_log: select propri" on public.push_notification_log;
create policy "push_log: select propri"
  on public.push_notification_log for select using (auth.uid() = user_id);
