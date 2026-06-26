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
- App **live** su Vercel collegata al Supabase reale; tabelle create via SQL Editor, edge function `yahoo` deployata dal dashboard. **Why:** la GitHub Integration di Supabase (Branching) non auto-deploya (probabilmente non abilitata) → migration/function applicate manualmente.
- **Auth: solo email/password per ora.** Il codice Google OAuth esiste (`AuthController.signInWithGoogle`, param `onGoogle` di `AuthScaffold`) ma il pulsante è **disattivato di proposito** rimuovendo `onGoogle` dalle schermate. **How to apply:** non re-introdurre il pulsante Google finché l'utente non lo richiede; per riattivarlo basta ripassare `onGoogle`.
- CLI Supabase non installabile via brew (Command Line Tools obsoleti); deploy fatti da dashboard.

Visione prodotto (post-brainstorm, giu 2026): Wally = **companion di finanza comportamentale** anti panic-sell ("not-quitter"), "fa il consulente senza esserlo". Doc aggiornati in `docs/pitch-and-society-docs/` (business-pitch v0.2, business-plan, presentation). **Confine legale critico:** restare educational/portafogli-modello, NON consulenza personalizzata MiFID/CONSOB. Roadmap 4 fasi: 1) Onboarding+PAC ✅, 2) Dashboard al netto+commissioni/fondi (TER, ACC/DIST), 3) Ribilanciamento schedulato+notifiche, 4) Modulo comportamentale (anti panic-sell, proiezioni/commitment).
- **Fase 1 fatta** (commit 6fa8c30): feature `lib/features/plan/` (dominio goal/rischio/lazy portfolio/PAC, PlanRepository, wizard onboarding `/onboarding`, schermata `/plan`, PlanCard in dashboard). Migration `20260531140000_plans.sql` **da eseguire a mano** su Supabase.
- **Fase 2 fatta** (commit 673a544): Holding +TER +distribution(ACC/DIST); modello Broker + tabella brokers (CRUD in `/brokers`, accessibile da Account); PortfolioCosts (TER drag + canoni → costo annuo + valore netto); CostsCard in dashboard. Migration `20260531150000_costs.sql` **da eseguire a mano**.
- **Fase 3 fatta** (commit 9d59a88): cadenza ribilanciamento (RebalanceSettings/RebalanceFrequency, tabella rebalance_settings) con prossima data + isDue; centro notifiche in-app `/notifications` (WallyNotification, notificationsProvider: promemoria schedulato + deviazioni con titolo trainante); campanella+badge in dashboard; card cadenza + "segna come ribilanciato" in /rebalance. Migration `20260531160000_rebalance_settings.sql` **da eseguire a mano**. Web-push in background = follow-up (serve service worker + cron). Resta da fare **Fase 4: modulo comportamentale**.
- **Fase 4 fatta** (commit 2ac3f10): modulo comportamentale `lib/features/coach/` — check-in umore (Mood + risposte coaching, tabella mood_checkins), anti panic-sell (day-change portafoglio o umore a rischio → card calmante + costo del mollare dal piano), metrica not-quitter, tip comportamentali; schermata `/coach`, CoachCard + check-in in dashboard, entry da Account. Migration `20260531170000_mood_checkins.sql`. **Roadmap 4 fasi COMPLETATA.**
- Allineamento DB: usare `supabase/apply_all.sql` (idempotente, include tutte le tabelle incl. mood_checkins). Migration manuali in sospeso da applicare: plans, costs, rebalance_settings, mood_checkins (o lanciare apply_all.sql).
- Handoff nuovo device: `docs/dev-setup.md`; memoria versionata in `docs/claude-memory/` + `scripts/sync-claude-memory.sh`.
- Preview locale statico NON fa SPA fallback (404 sui deep-link tipo /onboarding); è solo locale, in prod `vercel.json` riscrive su index.html.

Backlog post-PAC (`docs/feature-backlog.md`) — programma A→G implementato in autonomia (giu 2026):
- ✅ C valuta/leva su Holding; ✅ B ledger `lib/features/transactions/` (tabella transactions, posizioni = aggregato; schermata /transactions con prezzo-alla-data, buy-the-dip, maxi-canone); ✅ B piano +PacFrequency +initialLump; ✅ F `/compare` + `/income` (`lib/features/analysis/providers/income_providers.dart`); ✅ A quiz profilo + reality-check (`risk_quiz.dart` nello step rischio onboarding); ✅ G1 news `lib/features/news/` (azione `news` nell'edge function → **richiede redeploy**); ✅ E import CSV (fatto dall'altro device).
- ✅ **D multi-portafoglio** (non-breaking): tabella portfolios + `portfolio_id` su holdings/transactions; `portfoliosController`/`currentPortfolioIdProvider`/`selectedPortfolioIdProvider` (Notifier, NON StateProvider che in Riverpod 3 è legacy); selettore in app bar dashboard. **v1: plans/targets/rebalance restano GLOBALI per-utente, snapshot per-utente** (raffinamento futuro). ✅ B3 campo `sleeve` (core/satellite) su transactions. ✅ G2 card adattiva nel Coach per profilo di rischio. **Backlog A→G COMPLETATO.**
- Nuove migration da applicare (tutte in `apply_all.sql`): instrument_currency_leverage, transactions, plan_pac, portfolios, tx_sleeve. Altre già presenti dall'altro device (web push, ecc.).
- Dipendenze aggiunte dall'altro device: google_fonts (tema brand Sora/Inter), url_launcher (diretta). Provider dati licenziato opzionale via `MARKET_PROVIDER`.
