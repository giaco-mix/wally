---
name: project-overview
description: "Finance Companion — obiettivo, stack e vincoli architetturali chiave (Yahoo via edge function, modalità demo)"
metadata: 
  node_type: memory
  type: project
  originSessionId: f6ff0eb2-eeb7-47e5-9d2e-b8f09ff564de
---

Finance Companion: app companion finanziario per monitorare, analizzare e **ribilanciare** un portafoglio, con **analisi fondamentale** dei titoli. Target attuale: **solo Web PWA**. Stack: Flutter + Riverpod + go_router + fl_chart, backend Supabase (Auth, Postgres, Edge Functions).

Decisioni non ovvie:
- **Dati di mercato da Yahoo Finance non ufficiale**, instradati tramite **Supabase Edge Function** (`supabase/functions/yahoo`, azioni `chart|summary|search`). **Why:** Yahoo non espone CORS e i fondamentali richiedono cookie+crumb → impossibile chiamarlo dal browser; il rischio ToS dell'API non ufficiale è stato accettato consapevolmente dall'utente. **How to apply:** ogni nuova chiamata a Yahoo passa dall'edge function, non da chiamate dirette nel client.
- **Modalità demo**: se `SUPABASE_URL`/`SUPABASE_ANON_KEY` (via `--dart-define`) sono assenti, l'app usa repository in-memory + dati mock e bypassa il login. **Why:** rende l'app eseguibile/testabile senza backend. **How to apply:** mantieni le implementazioni mock/in-memory allineate alle interfacce reali quando aggiungi feature.

Lingua di lavoro preferita: **italiano** (UI e comunicazione).

Repo & deploy:
- **Monorepo** su GitHub: `https://github.com/giaco-mix/wally.git` (branch `main`). **Why:** strategia agent-first — Vercel builda il frontend dalla root, la GitHub Integration di Supabase osserva la cartella `supabase/` e auto-deploya migration + edge functions. Un solo repo, due integrazioni su cartelle diverse. **How to apply:** non separare backend/frontend in repo distinti; lavora su questo repo e i deploy partono in automatico.
- Frontend su **Vercel** (`vercel.json`: clona Flutter stable + `flutter build web`, env `SUPABASE_URL`/`SUPABASE_ANON_KEY`, rewrite SPA).
- App **live** su Vercel collegata al Supabase reale; tabelle create via SQL Editor, edge function `yahoo` deployata dal dashboard. **Why:** la GitHub Integration di Supabase (Branching) non auto-deploya (probabilmente non abilitata) → migration/function applicate manualmente. Esiste `supabase/apply_all.sql` (script idempotente con tutto lo schema) per allineare il DB in un colpo solo.
- **Auth: solo email/password per ora.** Il codice Google OAuth esiste (`AuthController.signInWithGoogle`, param `onGoogle` di `AuthScaffold`) ma il pulsante è **disattivato di proposito** rimuovendo `onGoogle` dalle schermate. **How to apply:** non re-introdurre il pulsante Google finché l'utente non lo richiede; per riattivarlo basta ripassare `onGoogle`.
- CLI Supabase non installabile via brew (Command Line Tools obsoleti); deploy fatti da dashboard.
- Handoff/onboarding nuovo device: `docs/dev-setup.md`. Memoria Claude versionata in `docs/claude-memory/` + script `scripts/sync-claude-memory.sh` per reinstallarla.

Visione prodotto (post-brainstorm, giu 2026): Wally = **companion di finanza comportamentale** anti panic-sell ("not-quitter"), "fa il consulente senza esserlo". Doc aggiornati in `docs/pitch-and-society-docs/` (business-pitch v0.2, business-plan, presentation). **Confine legale critico:** restare educational/portafogli-modello, NON consulenza personalizzata MiFID/CONSOB. Roadmap 4 fasi: 1) Onboarding+PAC ✅, 2) Dashboard al netto+commissioni/fondi (TER, ACC/DIST) ✅, 3) Ribilanciamento schedulato+notifiche ✅, 4) Modulo comportamentale (anti panic-sell, proiezioni/commitment).
- **Fase 1 fatta** (commit 6fa8c30): feature `lib/features/plan/` (dominio goal/rischio/lazy portfolio/PAC, PlanRepository, wizard onboarding `/onboarding`, schermata `/plan`, PlanCard in dashboard). Migration `20260531140000_plans.sql`.
- **Fase 2 fatta** (commit 673a544): Holding +TER +distribution(ACC/DIST); modello Broker + tabella brokers (CRUD in `/brokers`, accessibile da Account); PortfolioCosts (TER drag + canoni → costo annuo + valore netto); CostsCard in dashboard. Migration `20260531150000_costs.sql`.
- **Fase 3 fatta** (commit 9d59a88): cadenza ribilanciamento (RebalanceSettings/RebalanceFrequency, tabella rebalance_settings) con prossima data + isDue; centro notifiche in-app `/notifications` (WallyNotification, notificationsProvider: promemoria schedulato + deviazioni con titolo trainante); campanella+badge in dashboard; card cadenza + "segna come ribilanciato" in /rebalance. Migration `20260531160000_rebalance_settings.sql`. Web-push in background = follow-up (serve service worker + cron).
- **Fase 4 fatta** (commit 2ac3f10): modulo comportamentale `lib/features/coach/` — check-in umore (Mood + risposte coaching, tabella mood_checkins), anti panic-sell (day-change portafoglio o umore a rischio → card calmante + costo del mollare dal piano), metrica not-quitter, tip comportamentali; schermata `/coach`, CoachCard + check-in in dashboard, entry da Account. Migration `20260531170000_mood_checkins.sql`. **Roadmap 4 fasi COMPLETATA.**
- Allineamento DB: usare `supabase/apply_all.sql` (idempotente, include tutte le tabelle incl. mood_checkins + push_subscriptions/push_notification_log).
- Preview locale statico NON fa SPA fallback (404 sui deep-link tipo /onboarding); è solo locale, in prod `vercel.json` riscrive su index.html.

## Sessione giu 2026 — UX, dinamicità, feedback soci (post roadmap 4 fasi)
Toolchain: Flutter aggiornato a **3.44.1** (pubspec richiedeva Dart ≥3.11.3). Deploy: `vercel.json` ora chiama `bash vercel-build.sh` (il buildCommand inline sforava i 256 char di Vercel); passa anche `--dart-define=VAPID_PUBLIC_KEY`.

**Rifiniture UX (A):** disclaimer pervasivo (`DisclaimerBanner`), tabular figures nel tema, accessibilità (Semantics su card/grafici/slider), font brand **Sora+Inter** via `google_fonts` (fetch a runtime; per offline puro bundlare i .ttf — roadmap brand §10). Onboarding con spiegazioni anti-gergo (orizzonte, azioni/bond, PAC).

**Feature (B):** Web-push reale (B2) — codice completo: SW su scope `/push/`, `lib/features/notifications/` (PushClient con **import condizionali** web/stub), edge function `send-push` (VAPID, trigger rebalance+checkin), migration + cron template; runbook `docs/web-push-setup.md`. **Attivazione fatta a metà**: function deployata, chiavi VAPID generate, MA manca che l'utente metta il **sito su "Consenti"** in Chrome + tolga adblock su supabase.co (la subscribe funziona, fallisce solo il salvataggio per blocco rete lato browser). Import CSV broker (B3, `CsvImporter` testato). Provider licenziato (B4): scaffold `LicensedMarketRepository` + selezione via `MARKET_PROVIDER` (default yahoo). Vedi [[market-data-decision]].

**Feedback soci (Fabio):** F2 scheda **ETF/fondi** corretta (rileva quoteType, mostra TER/categoria/yield/top holdings; edge function `yahoo` ora include moduli `fundProfile`+`topHoldings` — **già ridepoyata**). F1 **obbligazioni per durata** (AssetClass bondShort/Mid/Long + generica). F5 sezione **Strategie** `/strategie` (guida "come strutturare un piano" + lazy portfolio). F3 (costituenti S&P500 via FMP) **rimandato** (F2 già copre le holdings ETF).
Audio Mom Test (Giacomo) → doc in `docs/validation/`.

**Dinamicità (D):** variazione di **oggi** per posizione + card "Oggi"; **drill-down** dai grafici (per asset class E settore) → `HoldingsFilterScreen`; "Aggiornato alle HH:mm" + pull-to-refresh; **sparkline** (ultimo mese) nelle righe del drill-down (solo lì, per non sovraccaricare Yahoo).

**Da riprendere (prossima sessione):**
1. **Chiudere web-push**: sito su "Consenti" + adblock off → testare toggle, `curl` a `send-push`, push reale. (Cron/secret già pronti, vedi runbook.)
2. Eventuale F3 (FMP) se servono i costituenti completi di un indice (serve API key FMP).
3. Eventuale sparkline altrove con cache, o bundling font per offline.
Stato: tutto su `main`, analyze pulito, 19 test verdi, build web ok.
