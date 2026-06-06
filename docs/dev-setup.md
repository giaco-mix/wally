# Wally — Setup su nuovo device & handoff

> Guida per clonare il progetto su un altro computer e riprendere il lavoro
> (anche in una nuova sessione di Claude Code). Tieni questo file aggiornato:
> è la "fonte di verità" portabile, perché viaggia dentro il repo.

---

## 0. Riassunto in 30 secondi
- **Codice**: tutto su GitHub → `https://github.com/giaco-mix/wally.git` (branch `main`).
- **Backend**: progetto **Supabase** esistente (Auth + Postgres + Edge Function `yahoo`).
- **Hosting**: **Vercel**, deploy automatico ad ogni push su `main`.
- **Segreti** (NON nel repo): `SUPABASE_URL` e `SUPABASE_ANON_KEY`. Si passano
  via `--dart-define` in locale e come Environment Variables su Vercel.
- Senza segreti l'app parte comunque in **modalità demo** (dati finti in memoria).

---

## 1. Prerequisiti sul nuovo device
- **Flutter** stable ≥ 3.41 (sviluppato con 3.41.5 / Dart 3.11.3). Verifica: `flutter --version` e `flutter doctor`.
- **Git**.
- Un browser (Chrome consigliato per il web).
- (Opzionale) **Claude Code** per continuare con l'assistente.
- (Opzionale) Supabase CLI — non indispensabile: migration e function si gestiscono dal dashboard.

## 2. Clonare il repo
```bash
git clone https://github.com/giaco-mix/wally.git
cd wally
flutter pub get
```

## 3. Recuperare i segreti
Dal **dashboard Supabase** del progetto → *Project Settings → API*:
- **Project URL** → `SUPABASE_URL` (es. `https://xxxx.supabase.co`)
- chiave **anon public** → `SUPABASE_ANON_KEY` (è una chiave pubblica: ok nel client; **mai** la `service_role`)

In alternativa, le stesse due variabili sono già su **Vercel** → *Settings → Environment Variables*.

> Suggerimento: salvale in un gestore di password / nota privata. Non committarle.

## 4. Avvio in locale
**Con backend reale:**
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```
**In modalità demo (senza backend):**
```bash
flutter run -d chrome
```
Build di produzione: `flutter build web` (output in `build/web`).

## 5. Backend Supabase
Stai usando un progetto Supabase **già configurato**: dal nuovo device **non devi rifare nulla**, basta puntarci con le env var del punto 3.

Se invece dovessi ricreare il backend da zero (nuovo progetto Supabase):
1. SQL Editor → esegui [`supabase/apply_all.sql`](../supabase/apply_all.sql) (script unico idempotente con tutte le tabelle + RLS).
2. Edge Functions → crea `yahoo`, incolla [`supabase/functions/yahoo/index.ts`](../supabase/functions/yahoo/index.ts), **Verify JWT off**, Deploy.
3. Authentication → Providers → **Email** abilitato; *URL Configuration* → Site URL = dominio Vercel.
4. Copia URL + anon key nelle env (locale e Vercel).

## 6. Deploy (Vercel)
- Già collegato al repo: ogni push su `main` triggera un build (clona Flutter + `flutter build web`, vedi [`vercel.json`](../vercel.json)).
- Env richieste su Vercel (Production + Preview): `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- Per i deep-link (es. `/plan`) il `vercel.json` riscrive su `index.html`.

## 7. Continuare con Claude Code in una nuova sessione
La **memoria automatica** di Claude Code è **locale** alla macchina (vive in
`~/.claude/projects/<hash-del-path-progetto>/memory/`, fuori dal repo). Quindi:

- **Modo consigliato (portabile)**: apri il progetto clonato con Claude Code e
  digli *"leggi `docs/dev-setup.md` e i documenti in `docs/pitch-and-society-docs/`"*.
  Questo file + i doc di business contengono già lo stato e le decisioni: la nuova
  sessione riparte con il contesto giusto, su qualsiasi device.
- **Modo "memoria identica" (versionata nel repo)**: la memoria è copiata in
  [`docs/claude-memory/`](claude-memory/) e c'è uno script che la reinstalla nella
  cartella Claude di questo device (calcola da solo il path-hash, quindi funziona
  con qualsiasi percorso di clone):
  ```bash
  bash scripts/sync-claude-memory.sh
  ```
  Poi apri il progetto con Claude Code dalla radice del repo. Per ri-sincronizzare
  dopo aggiornamenti, aggiorna i file in `docs/claude-memory/` e rilancia lo script.

---

## 8. Stato del progetto (aggiornare ad ogni milestone)
**Wally** = companion di **finanza comportamentale** (anti panic-sell, "not-quitter",
"fa il consulente senza esserlo"). Vedi `docs/pitch-and-society-docs/` per pitch,
business plan, presentazione, brand & design system.

**Stack**: Flutter Web (PWA) + Riverpod + go_router + fl_chart · Supabase (Auth/Postgres/Edge Functions) · Vercel. Architettura **feature-based** in `lib/features/*` con repository pattern; dati di mercato astratti dietro `MarketRepository` (oggi Yahoo via edge function, sostituibile con provider licenziato).

**Roadmap a 4 fasi** (tutte le prime 3 fatte):
1. ✅ Onboarding goal-based + Piano di accumulo (PAC) + lazy portfolio — `lib/features/plan/`
2. ✅ Dashboard al netto & costi (TER, ACC/DIST, broker/commissioni) — `lib/features/portfolio/` (broker, costs)
3. ✅ Ribilanciamento schedulato + centro notifiche in-app — `lib/features/rebalance/`
4. ⏳ **Modulo comportamentale** (anti panic-sell, check-in emotivi, proiezioni/commitment) — da costruire

**Auth**: solo **email/password** per ora. Codice Google OAuth presente ma pulsante disattivato (riattivabile ripassando `onGoogle` in login/signup).

**Modalità demo**: senza env Supabase, repository in-memory con dati sintetici (utile per sviluppo UI e screenshot).

## 9. Limiti / scelte note
- **Dati di mercato**: Yahoo non ufficiale via edge function (proxy CORS). Da valutare provider licenziato prima di scalare.
- **Notifiche**: in-app (calcolate all'apertura). **Web-push in background**: il codice è pronto nel repo (service worker, edge function `send-push`, cron template); manca solo l'**attivazione** lato Supabase (chiavi VAPID + deploy + cron) — vedi [`docs/web-push-setup.md`](web-push-setup.md).
- **Regolamentazione**: restare **educational / portafogli-modello**, NON consulenza personalizzata (MiFID II / CONSOB). Parere legale prima di funzioni che sfiorano la consulenza.
- Il **preview statico locale** non fa SPA fallback (404 sui deep-link): in produzione ci pensa `vercel.json`.

## 10. Comandi utili
```bash
flutter pub get          # dipendenze
flutter analyze          # lint/analisi statica
flutter build web        # build di produzione
flutter run -d chrome    # dev (aggiungi i --dart-define per il backend)
git pull --rebase        # allinea il repo
```
