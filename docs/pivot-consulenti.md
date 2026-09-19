# Wally — Pivot B2B2C: uno strumento per consulenti finanziari

> Idea del socio (set 2026): oltre al retail "fai-da-te", offrire Wally ai
> **consulenti finanziari** come strumento da dare ai **propri clienti**. Il
> consulente cura la strategia; il cliente vede il proprio portafoglio in modo
> **strutturato e dinamico** (con i messaggi comportamentali di Wally) invece che
> in un PDF inviato ogni tanto. Documento di strategia — non ancora implementato.

---

## 1. La tesi
Oggi il cliente del consulente riceve **report periodici** (fogli/PDF) e per capire
com'è messo deve **chiedere**. Con Wally il cliente **apre l'app** e vede:
- il proprio portafoglio aggiornato, per asset class / settore / mercato;
- il rendimento (anche per singolo accumulo, grazie al ledger già costruito);
- i **messaggi comportamentali** di Wally ("giornata rossa, è normale…", anti panic-sell).

Vantaggi per il **consulente**: meno lavoro ripetitivo di reportistica, comunicazione
**diretta e continua** col cliente, immagine più moderna. Per il **cliente**:
trasparenza, serenità, meno ansia da "quando mi arriva il report".

> È lo stesso motore che stiamo costruendo, con un **cambio di destinatario**.

## 2. Perché è interessante anche dal lato regole
Il confine delicato del retail (§ MiFID/CONSOB: non fare "consulenza") qui **si
sposta a favore**: la consulenza la dà il **consulente**, che è già il soggetto
**autorizzato e responsabile** (iscritto OCF, vigilato CONSOB). Wally diventa uno
**strumento software B2B** che il professionista usa con i suoi clienti — non è lui
a dare raccomandazioni. Questo *semplifica* il posizionamento di Wally.

⚠️ In compenso emergono altri temi:
- **GDPR / trattamento dati**: il consulente vede i dati dei clienti → servono base
  giuridica, ruoli di titolare/responsabile del trattamento, accordi (DPA).
- **Separazione netta dei dati** tra clienti e tra consulenti (multi-tenancy + RLS).
- Nessuna esecuzione ordini: restiamo **visualizzazione + comportamento**, non trading.

*(Parere legale prima di andare in produzione con clienti reali.)*

## 3. Cosa cambia nel prodotto (ruoli)
| Ruolo | Cosa fa |
|---|---|
| **Retail** (oggi) | Gestisce da sé i propri portafogli. Invariato. |
| **Consulente** (nuovo) | Vede/gestisce i portafogli di **più clienti**; imposta strategie e target; scrive/абilita i messaggi. |
| **Cliente di un consulente** (nuovo) | Vede il **proprio** portafoglio (tipicamente in **sola lettura** o con permessi limitati) + i messaggi di Wally. |

## 4. Impatto architetturale (perché va progettato, non improvvisato)
1. **Ruoli utente**: un campo `role` (retail / advisor / client) sul profilo.
2. **Relazione consulente↔cliente**: nuova tabella `advisor_clients`
   (`advisor_id`, `client_id`, stato invito). Un consulente ha molti clienti.
3. **Multi-tenancy sui dati**: i portafogli/holdings/transactions di un cliente
   devono essere **visibili al suo consulente** → nuove **policy RLS** (oltre a
   "vedi i tuoi", "il consulente vede quelli dei suoi clienti").
4. **Vista cliente**: possibilmente **read-only** (o con azioni limitate), con in
   evidenza i messaggi comportamentali.
5. **Flusso di invito/collegamento**: il consulente invita il cliente (email) o
   crea/collega l'account; il cliente accetta.
6. **(Futuro) White-label**: logo/colori del consulente, dominio dedicato.

Riuso: **il grosso del motore esiste già** (multi-portafoglio, ledger, rendimento
per-accumulo S2, allocazioni, notifiche, coach). Il pivot aggiunge **ruoli +
condivisione**, non riscrive il cuore.

## 5. Piano a fasi (proposta)
- **F0 — Validazione** (no codice): parlare con 2–3 consulenti reali; capire cosa
  darebbero al cliente, cosa no; prezzo; vincoli. *(La cosa più importante prima di
  costruire.)*
- **F1 — Ruoli & collegamento**: campo `role`, tabella `advisor_clients`, invito
  cliente, RLS "il consulente vede i suoi clienti".
- **F2 — Vista consulente**: elenco clienti + apertura del portafoglio di un cliente
  (in sola lettura) riusando le schermate esistenti.
- **F3 — Vista cliente curata**: dashboard cliente semplificata + messaggi Wally;
  permessi (read-only o azioni limitate).
- **F4 — Messaggi del consulente**: il consulente può inviare/abilitare note al
  cliente ("ho ribilanciato", "stai tranquillo").
- **F5 — White-label / pricing B2B**.

## 6. Rischi / cose da decidere
- **Chi possiede il dato del cliente** (cliente o consulente)? Impatta GDPR e UX.
- Il cliente può **agire** o solo **guardare**? (v1 consigliata: sola lettura).
- Modello di **prezzo** (per-consulente, per-cliente, flat?).
- **Onboarding** dei consulenti (pochi, curati) vs self-service.

## 7. Prossimo passo consigliato
Non partire dal codice: **F0 validazione** con qualche consulente + parere legale sul
modello. In parallelo, il motore retail (S2/S3/S4…) che stiamo finendo è **la stessa
base** che servirà: ogni miglioria lì vale anche per il B2B2C.

---

# Appendice — Design tecnico (bozza dettagliata)

> Dettaglio per implementare. **F0 (validazione) resta il primo passo reale**;
> questo design serve a partire col codice quando decidiamo. Iniziamo con un
> **prototipo in demo** (dati finti, nessun backend nuovo) per validare la UX.

## D1. Modello dati (Supabase) — IMPLEMENTATO
> Fonte di verità: `supabase/migrations/20260917120000_advisor.sql` (in
> `apply_all.sql`). Rispetto alla prima bozza, l'invito avviene **per email**
> (il consulente non deve conoscere l'id del cliente).
```sql
alter table public.profiles
  add column if not exists role text not null default 'retail'; -- retail|advisor|client

create table if not exists public.advisor_clients (
  id bigint generated always as identity primary key,
  advisor_id   uuid not null references auth.users(id) on delete cascade,
  client_email text not null,           -- invito indirizzato a un'email
  client_label text,                    -- nome che il consulente dà al cliente
  client_id    uuid references auth.users(id) on delete cascade, -- valorizzato all'accettazione
  status       text not null default 'pending', -- pending|active|revoked
  created_at   timestamptz not null default now(),
  unique (advisor_id, client_email)
);
```

## D2. RLS — il consulente vede i dati dei suoi clienti ATTIVI
Funzione helper `is_active_client(uuid)` + policy **SELECT** additive. **v1
implementata su `holdings` + `transactions`** (bastano per posizioni e
rendimento); le altre tabelle si aggiungono con lo stesso pattern quando serve.
```sql
create or replace function public.is_active_client(target uuid)
returns boolean language sql stable security invoker as $$
  select exists (
    select 1 from public.advisor_clients ac
    where ac.advisor_id = auth.uid() and ac.client_id = target and ac.status = 'active'
  );
$$;
create policy "holdings: lettura consulente" on public.holdings
  for select using (public.is_active_client(user_id));
```
> Solo **SELECT**: nella v1 il consulente **guarda**, non scrive i dati del cliente.
> Il cliente vede/accetta gli inviti via `auth.jwt() ->> 'email'` (vedi migration).

## D3. Flusso di invito (collegamento)
1. Il consulente inserisce l'email del cliente → riga `advisor_clients (advisor, client, 'pending')`.
   *(Se il cliente non ha ancora un account, l'invito resta pending finché non si registra.)*
2. Il cliente vede l'invito e **accetta** → `status='active'`.
3. Da quel momento il consulente vede (in lettura) i portafogli del cliente.
4. Il cliente può **revocare** in ogni momento (`status='revoked'`) → RLS lo taglia fuori.
   *(Consenso esplicito e revocabile = requisito GDPR.)*

## D4. UX (schermate)
- **Consulente — Home**: elenco clienti (nome, valore totale, oggi, scostamento dal
  target). Ricerca. Azione "Invita cliente".
- **Consulente — Dettaglio cliente**: il portafoglio del cliente in **sola lettura**
  (riusa dashboard/allocazioni/rendimento accumuli). In cima: eventuali avvisi
  ("sta sforando il target", "umore a rischio").
- **Cliente**: la sua app normale + indicazione "seguito da <consulente>" e (fase 2)
  eventuali messaggi del consulente.
- Ingresso: voce in Account visibile solo se `role == 'advisor'`.

## D5. Strategia di rilascio (non-breaking)
- **Fase demo (ora)**: prototipo con `AdvisorRepository` in-memory + dati finti;
  schermate consulente reali; nessuna modifica a Supabase. Serve a **validare**.
- **Fase reale**: migration D1 + policy D2 + invito D3; `role` sul profilo;
  `AdvisorRepository` Supabase; gating delle schermate su `role`.
- Il retail resta **invariato** in entrambe le fasi (default `role='retail'`).

## D6. Da decidere (blocca la fase reale, non la demo)
- Proprietà del dato (cliente vs consulente) → conferma GDPR.
- Il cliente può agire o solo guardare (v1: sola lettura).
- Pricing B2B e onboarding dei consulenti.
- Parere legale prima di clienti reali.
