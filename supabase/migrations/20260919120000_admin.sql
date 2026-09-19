-- Ruolo amministratore: vede l'elenco utenti e può cambiare i ruoli.
-- (I dati finanziari dei singoli utenti NON sono esposti da queste policy.)

-- Helper: l'utente corrente è admin? security definer per evitare ricorsione
-- di RLS (la policy su profiles chiamerebbe una select su profiles).
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

-- L'admin legge tutti i profili (elenco utenti + ruoli).
drop policy if exists "profiles: admin vede tutti" on public.profiles;
create policy "profiles: admin vede tutti"
  on public.profiles for select using (public.is_admin());

-- L'admin può aggiornare i profili (es. assegnare ruoli).
drop policy if exists "profiles: admin aggiorna" on public.profiles;
create policy "profiles: admin aggiorna"
  on public.profiles for update using (public.is_admin());

-- Per rendere admin i primi due account, esegui (una volta):
--   update public.profiles set role = 'admin'
--   where id in (select id from auth.users
--                where email in ('giaco.mix1221@gmail.com','fabiobertaina31300@gmail.com'));
