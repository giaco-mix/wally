-- ============================================================================
-- Wally — Cron giornaliero per il Web Push (TEMPLATE)
-- ----------------------------------------------------------------------------
-- NON eseguire così com'è: sostituisci i placeholder <...> e incollalo nel
-- SQL Editor di Supabase. Richiede le estensioni pg_cron e pg_net (abilitabili
-- da Database -> Extensions). Vedi docs/web-push-setup.md per la guida completa.
-- I segreti (URL progetto, CRON_SECRET) NON vanno committati: stanno qui solo
-- come placeholder.
-- ============================================================================

create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Rimuovi un'eventuale schedulazione precedente con lo stesso nome.
select cron.unschedule('wally-daily-push')
where exists (select 1 from cron.job where jobname = 'wally-daily-push');

-- Ogni giorno alle 08:00 UTC chiama l'edge function send-push.
select cron.schedule(
  'wally-daily-push',
  '0 8 * * *',
  $$
  select net.http_post(
    url     := 'https://<PROJECT_REF>.functions.supabase.co/send-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', '<CRON_SECRET>'
    ),
    body    := '{}'::jsonb
  );
  $$
);
