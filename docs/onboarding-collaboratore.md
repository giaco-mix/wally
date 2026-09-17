# Wally — Onboarding collaboratore/trice

> Guida per iniziare a lavorare su Wally **con Claude Code**, anche se è la prima
> volta che usi Claude Code, git, Supabase o Vercel. Segui i passi in ordine.
> Per il contesto del progetto vedi anche [`dev-setup.md`](dev-setup.md) e la
> cartella [`claude-memory/`](claude-memory/).

---

## 0. Cosa ricevi dal referente (Giacomo), in privato
Queste cose **non** stanno nel repo, te le manda lui su un canale privato:
- **Invito come collaboratore su GitHub** (repo `giaco-mix/wally`) — accetta la mail.
- **Le due chiavi pubbliche Supabase**: `SUPABASE_URL` e `SUPABASE_ANON_KEY`.
  Sono *pubbliche* (finiscono comunque nel sito pubblicato), quindi ok usarle nel
  client — **ma non vanno mai committate nel repo**. Salvale in un gestore di
  password / nota privata.
- (Opzionale) `VAPID_PUBLIC_KEY` se lavorerai sulle notifiche push.

> ⚠️ La chiave **`service_role`** di Supabase è un segreto potente: non ti serve
> e non deve **mai** finire nel client o nel repo.

---

## 1. Cosa installare sul tuo computer
- **Flutter** stable recente (≥ 3.44) con Dart incluso. Verifica: `flutter --version` e `flutter doctor`.
- **Git**.
- **Google Chrome** (l'app è una web app).
- **Claude Code** (app desktop o CLI).
- (Facoltativo) la **GitHub CLI** `gh` per aprire le Pull Request da terminale.

## 2. Scaricare il progetto
```bash
git clone https://github.com/giaco-mix/wally.git
cd wally
flutter pub get
```

## 3. Claude Code — le basi (se è la prima volta)
Claude Code è un assistente che lavora **dentro il progetto**: legge il codice,
propone modifiche, esegue comandi e test, tutto con il tuo ok.

Primi passi consigliati:
1. Apri la cartella `wally` con Claude Code.
2. **Allinea la memoria di progetto** su questo computer (una volta):
   ```bash
   bash scripts/sync-claude-memory.sh
   ```
3. Come prima cosa, chiedi a Claude:
   > "Leggi `docs/onboarding-collaboratore.md`, `docs/dev-setup.md` e
   > `docs/claude-memory/`, poi dammi una panoramica del progetto."
4. Modo di lavorare: **descrivi l'obiettivo** (non i singoli comandi), lascia che
   Claude proponga un **piano**, poi confermi. Claude chiede il permesso per le
   azioni (eseguire comandi, modificare file): tu approvi passo passo.
5. **Committa/pusha solo quando glielo chiedi tu.** Non far pushare su `main` (vedi §5).
6. Se qualcosa non è chiaro, chiedi a Claude di spiegartelo: è anche un tutor.

## 4. Avviare l'app
**Con backend reale** (chiavi del referente):
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```
**In modalità demo** (senza chiavi, dati finti, nessun login):
```bash
flutter run -d chrome
```
Prima di ogni PR: `flutter analyze` (atteso *No issues found!*) e `flutter test`.

---

## 5. Come lavoriamo con Git (IMPORTANTE) — branch + Pull Request

**Regola d'oro: non committare MAI direttamente su `main`.**
`main` è la **produzione**: ogni cosa che finisce lì viene pubblicata da Vercel.
Tu lavori su un **branch** e apri una **Pull Request (PR)**; il referente
revisiona e fa il merge.

Ciclo di lavoro, ogni volta che inizi qualcosa:
```bash
# 1. Parti aggiornato
git checkout main
git pull

# 2. Crea un branch con un nome parlante
git checkout -b feat/nome-della-cosa        # o fix/... per una correzione

# 3. Lavora (o fai lavorare Claude), poi salva i cambiamenti
git add -A
git commit -m "feat: descrizione breve e chiara di cosa fa"

# 4. Pubblica il branch su GitHub
git push -u origin feat/nome-della-cosa
```
Poi **apri la PR**:
- Da browser: apri il repo su GitHub, comparirà il pulsante **"Compare & pull
  request"** → scrivi titolo e una breve descrizione (cosa e perché) → **Create pull request**.
- Oppure da terminale con la GitHub CLI: `gh pr create --fill`.

Cosa succede dopo:
- **Vercel crea un "Preview Deployment"** della tua PR: un link temporaneo dove
  vedi le tue modifiche **live**, senza toccare il sito di produzione. Ottimo per
  farle vedere e testarle.
- Il **referente revisiona** la PR, eventualmente chiede modifiche, poi fa **merge**
  su `main` → a quel punto va in produzione.
- Dopo il merge: torna su main e aggiorna.
  ```bash
  git checkout main
  git pull
  ```

Convenzioni utili:
- Messaggi di commit brevi e chiari, prefisso tipo: `feat:` (nuova funzione),
  `fix:` (correzione), `docs:` (documentazione), `refactor:`, `test:`. In italiano va bene.
- Un branch = una cosa sola (più facile da revisionare).
- Se il referente ha mergiato altro nel frattempo e la PR va "in conflitto",
  chiedi a Claude di aiutarti a fare `git pull origin main` nel tuo branch e
  risolvere i conflitti.

> Nota: il referente storicamente lavora **direttamente su `main`** (ha la
> responsabilità della produzione). Tu **no**: per te sempre branch + PR.

---

## 6. Supabase — cosa devi sapere
Supabase è il **backend**: autenticazione (email/password), database Postgres,
edge functions (funzioni server). Per lavorare sull'app di solito **non devi
toccarlo**: bastano le due chiavi del §0.

Cose da sapere:
- **Schema del database**: è tutto in [`supabase/apply_all.sql`](../supabase/apply_all.sql)
  (script unico e *idempotente* = puoi rieseguirlo senza danni). Le singole
  migration stanno in `supabase/migrations/`.
- **RLS (Row Level Security)**: ogni utente vede/scrive solo i **propri** dati.
  Per questo il backend condiviso è relativamente sicuro: non vedi i dati altrui.
- **Auth: solo email/password.** Il pulsante Google è disattivato **di proposito**:
  non reintrodurlo senza chiedere.
- **Dati di mercato**: passano dall'edge function `supabase/functions/yahoo`
  (proxy verso Yahoo). **Non** chiamare Yahoo direttamente dal client.
- Se una tua modifica **richiede una nuova tabella/colonna**: crea una *migration*
  in `supabase/migrations/`, aggiorna anche `apply_all.sql`, e **segnalalo nella
  PR** — il referente la applica dal dashboard Supabase (SQL Editor). Non serve
  che tu abbia accesso a Supabase per proporla.

## 7. Vercel — cosa devi sapere
Vercel ospita il frontend (il sito).
- **Deploy automatico**: ogni merge su `main` fa partire un build
  (clona Flutter + `flutter build web`) e pubblica in produzione.
- **Preview delle PR**: ogni PR ottiene un suo URL di anteprima (vedi §5) — è lì
  che mostri e verifichi il tuo lavoro prima del merge.
- Le variabili d'ambiente (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `VAPID_PUBLIC_KEY`)
  sono già configurate su Vercel dal referente: non devi fare nulla.
- Non ti serve un account Vercel per lavorare. Se ti serve leggere i log di un
  build fallito, chiedi al referente l'accesso in lettura.

---

## 8. Regole di prodotto da rispettare SEMPRE
- **Confine legale**: Wally è *educational / portafogli-modello*, **NON** consulenza
  personalizzata (MiFID II / CONSOB). Niente "compra/vendi" su misura per il singolo
  utente. Mantieni i disclaimer dove si mostrano dati/azioni.
- **Lingua**: italiano, sia nell'interfaccia sia nella comunicazione.
- **Tono di Wally**: coach empatico e incoraggiante (mai allarmista o
  colpevolizzante). Vedi [`brand-identity-and-design-system.md`](pitch-and-society-docs/brand-identity-and-design-system.md).
- **Auth**: solo email/password (Google resta disattivato).

## 9. Checklist prima di aprire una PR
- [ ] `flutter analyze` → *No issues found!*
- [ ] `flutter test` → tutti verdi
- [ ] Se hai toccato la UI: provata su Chrome (o nel Preview di Vercel)
- [ ] Il branch fa **una cosa sola**
- [ ] Titolo/descrizione PR chiari (cosa e perché)
- [ ] Se serve una migration DB, l'hai segnalata nella PR

## 10. Dove trovare il contesto del progetto
- [`docs/dev-setup.md`](dev-setup.md) — setup e handoff tra device.
- [`docs/claude-memory/`](claude-memory/) — memoria di progetto (leggila con Claude).
- [`docs/feature-backlog.md`](feature-backlog.md) — idee/backlog.
- [`docs/pitch-and-society-docs/`](pitch-and-society-docs/) — business, pitch, brand.
- [`docs/validation/`](validation/) — interviste utenti (Mom Test).

Benvenuta/o nel progetto! In caso di dubbi, la prima persona a cui chiedere è
Claude stesso: fatti spiegare qualsiasi passo prima di eseguirlo.
