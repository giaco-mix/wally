# Wally — Attivazione del Web Push (runbook)

> Il **codice** del web-push è già nel repo. Mancano i passi che richiedono il
> tuo accesso a Supabase e i segreti VAPID: questa guida li elenca in ordine.
> Finché non completi i punti 2–5, il toggle "Notifiche push" non compare
> nell'app (manca la chiave VAPID pubblica).

## Cosa è già pronto nel repo
| Pezzo | File |
|---|---|
| Tabelle DB (`push_subscriptions`, `push_notification_log`) | `supabase/migrations/20260606120000_push.sql` + `supabase/apply_all.sql` |
| Service worker push | `web/push/wally_push_sw.js` |
| Ponte JS (subscribe/unsubscribe) | `web/push/wally_push.js` (incluso in `web/index.html`) |
| Client + repository + provider Dart | `lib/features/notifications/` |
| Toggle UI | schermata **Avvisi** (`/notifications`) |
| Edge function di invio | `supabase/functions/send-push/index.ts` |
| Template cron | `supabase/cron/push_cron.template.sql` |

L'architettura: il SW push gira su scope **`/push/`** per non interferire con il
service worker di Flutter (scope `/`).

---

## 1. Genera le chiavi VAPID
Una sola volta. Con Node installato:
```bash
npx web-push generate-vapid-keys
```
Ottieni una **Public Key** e una **Private Key** (base64url). La pubblica è
sicura nel client; la privata è un **segreto**.

## 2. Applica lo schema DB
Nel **SQL Editor** di Supabase esegui `supabase/apply_all.sql` (idempotente),
oppure solo la migration `20260606120000_push.sql`.

## 3. Deploya l'edge function
Dal dashboard (Edge Functions → New function → `send-push`) incolla
`supabase/functions/send-push/index.ts`, **Verify JWT off**, Deploy.
Da CLI: `supabase functions deploy send-push --no-verify-jwt`.

Imposta i **secrets** della function (Project Settings → Edge Functions →
Secrets, oppure `supabase secrets set`):
- `VAPID_PUBLIC_KEY` = public key del punto 1
- `VAPID_PRIVATE_KEY` = private key del punto 1
- `VAPID_SUBJECT` = `mailto:tua@email` (o un URL del sito)
- `CRON_SECRET` = una stringa casuale lunga (la riusi al punto 5)

> `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` sono iniettati da Supabase: non
> serve impostarli.

## 4. Passa la chiave pubblica al client
La web app legge la VAPID **pubblica** via `--dart-define`:
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=VAPID_PUBLIC_KEY=<public key>
```
Su **Vercel**: aggiungi `VAPID_PUBLIC_KEY` alle Environment Variables e assicurati
che il build la passi come dart-define (vedi `vercel.json`).

## 5. Schedula il cron
Nel SQL Editor: abilita `pg_cron` e `pg_net` (Database → Extensions), poi esegui
`supabase/cron/push_cron.template.sql` dopo aver sostituito:
- `<PROJECT_REF>` → il ref del progetto (es. `abcd1234`)
- `<CRON_SECRET>` → lo stesso secret del punto 3

Il job gira ogni giorno alle 08:00 UTC e chiama `send-push`.

## 6. Prova
- Apri l'app (con `VAPID_PUBLIC_KEY` impostata), vai in **Avvisi**, attiva
  **Notifiche push**, concedi il permesso del browser → compare una riga in
  `push_subscriptions`.
- Forza un invio chiamando la function a mano:
  ```bash
  curl -X POST 'https://<PROJECT_REF>.functions.supabase.co/send-push' \
    -H 'x-cron-secret: <CRON_SECRET>'
  ```
  Risposta tipo `{"ok":true,"sent":N,"removed":M,"day":"YYYY-MM-DD"}`.
  Per vedere subito un push di ribilanciamento, imposta una cadenza e una
  `last_rebalanced_at` passata su `rebalance_settings`.

---

## Trigger attivi (v1)
- **`rebalance`** — ribilanciamento schedulato "due" (stessa logica del client).
- **`checkin`** — nudge comportamentale: chi ha già usato il coach ma non fa un
  check-in da 7+ giorni. **Non** dipende dai prezzi di mercato.

## Estensione futura: anti panic-sell guidato dal mercato
Mandare un push "giornata rossa / occhio a non vendere" richiede di **conoscere
i prezzi lato server** (oggi i prezzi arrivano via edge function Yahoo solo
quando il client li chiede). Va affrontato insieme al passaggio a un **provider
dati licenziato** (snapshot prezzi server-side), e con attenzione a restare
**educational, non consulenza personalizzata** (MiFID/CONSOB): nessun "vendi/
compra", solo supporto comportamentale.

## Note / limiti
- Il `pushsubscriptionchange` (rotazione endpoint del browser) non è ancora
  gestito: in caso, l'utente ri-attiva il toggle. Le sottoscrizioni scadute
  vengono comunque ripulite dall'edge function (errori 404/410).
- iOS Safari richiede che la PWA sia **installata** (Aggiungi a Home) per il push.
