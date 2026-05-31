# Wally — Business Pitch

> Documento vivo. Versione 0.1 — bozza. I numeri di mercato sono **stime preliminari** da validare con fonti primarie.

---

## 1. Elevator pitch
**Wally** trasforma un portafoglio disordinato in una strategia. Aggrega le tue posizioni, ti mostra com'è allocato il tuo denaro e ti dice **cosa ribilanciare e perché** — con analisi fondamentale spiegata in modo semplice. È il "personal trainer" del tuo portafoglio: non scegliamo per te, ti diamo metodo e chiarezza.

---

## 2. Il problema
Gli investitori retail "fai-da-te" sono in forte crescita, ma restano soli:

1. **Accumulano senza metodo** — comprano titoli/ETF nel tempo e perdono di vista l'allocazione complessiva.
2. **Ribilanciare è difficile** — capire quando e quanto comprare/vendere per tornare alla strategia richiede calcoli noiosi e disciplina.
3. **L'analisi fondamentale è frammentata** — i dati (P/E, ROE, debito…) sono sparsi, in inglese, e poco spiegati.
4. **Gli strumenti pro sono inaccessibili** — Bloomberg/terminali costano migliaia di euro; i broker offrono esecuzione, non guida.

**Conseguenza**: portafogli sbilanciati, decisioni emotive, sotto-diversificazione.

---

## 3. La soluzione
Una web app (PWA, presto mobile) che in pochi minuti:

- **Aggrega** il portafoglio (inserimento manuale; in roadmap import da broker).
- **Visualizza** allocazione per asset class e settore, valore e P/L in tempo quasi reale.
- **Guida il ribilanciamento**: definisci un'allocazione target, Wally calcola gli scostamenti e le mosse concrete ("vendi 500€ di azioni, compra 500€ di ETF").
- **Spiega i fondamentali**: scheda titolo con le metriche chiave, contestualizzate e in italiano.

**Perché ora**: boom di investitori retail post-2020, fiducia negli strumenti digitali, API dati accessibili, e una generazione che vuole capire — non delegare.

---

## 4. Mercato (stime da validare)
- **TAM**: investitori retail in Europa — decine di milioni di conti titoli attivi.
- **SAM**: investitori "self-directed" in Italia/EU che gestiscono attivamente un portafoglio multi-asset.
- **SOM (3 anni)**: early adopter italiani digitalmente attivi interessati a diversificazione e disciplina.

> Azione: sostituire con dati Consob/Banca d'Italia, ECB, e report di settore (es. numero conti deposito titoli, AuM retail).

---

## 5. Prodotto — stato attuale (MVP)
✅ Già funzionante (Flutter Web PWA + Supabase):
- Autenticazione (email/password + Google in arrivo)
- Portafoglio: CRUD posizioni con ricerca ticker
- Dashboard: valore totale, P/L, grafici allocazione (asset class + settore)
- Ribilanciamento: editor target + piano compra/vendi
- Analisi fondamentale: ricerca titoli + scheda metriche
- Modalità demo con dati sintetici

---

## 6. Modello di business — Freemium
| Piano | Prezzo (ipotesi) | Cosa include |
|---|---|---|
| **Free** | 0€ | 1 portafoglio, inserimento manuale, dashboard, ribilanciamento base, fondamentali essenziali |
| **Wally Pro** | ~4,99–7,99€/mese | Portafogli illimitati, alert di sblilanciamento, analisi fondamentale avanzata + storico, export, watchlist |
| **Futuro** | — | Import automatico da broker, ottimizzazione fiscale (es. zainetto fiscale IT), B2B2C con consulenti |

Leve di monetizzazione aggiuntive (da valutare con attenzione regolamentare): contenuti premium, NON rebate da broker se generano conflitto d'interesse.

---

## 7. Go-to-market
1. **Content & SEO**: guide su ribilanciamento, diversificazione, lettura dei fondamentali (in italiano, dove c'è poca offerta di qualità).
2. **Community**: presenza dove sono gli investitori retail IT (forum, Reddit, YouTube finanza personale, newsletter).
3. **Loop di prodotto**: la modalità demo permette di provare il valore prima della registrazione.
4. **Partnership**: creator di finanza personale, eventualmente broker (lato esecuzione).

---

## 8. Concorrenza & differenziazione
| Player | Cosa fa | Gap che Wally colma |
|---|---|---|
| Snowball Analytics, Sharesight | Tracking portafoglio, dividendi | Ribilanciamento guidato + fondamentali spiegati, focus IT |
| Portfolio Performance (desktop) | Potente ma tecnico | Semplicità, web/mobile, onboarding |
| App dei broker | Esecuzione ordini | Guida indipendente cross-broker |
| Screener (es. siti finanziari) | Dati fondamentali | Integrazione col *tuo* portafoglio e azioni concrete |

**Wedge**: *ribilanciamento guidato + analisi fondamentale comprensibile, in italiano, multi-broker.*

---

## 9. Roadmap (12 mesi, indicativa)
- **Q1** — Hardening MVP, Google auth, brand, deploy pubblico, primi utenti.
- **Q2** — Storico prezzi e performance nel tempo; alert di sbilanciamento; watchlist.
- **Q3** — "Health score" fondamentale sintetico; import CSV da broker; app mobile (stesso codice Flutter).
- **Q4** — Pro tier + pagamenti; import automatico broker; ottimizzazioni fiscali IT.

---

## 10. Rischi & mitigazioni
| Rischio | Mitigazione |
|---|---|
| **Dati di mercato** da Yahoo non ufficiale (ToS, affidabilità) | Astratto dietro un'interfaccia (`MarketRepository`): si può passare a un provider licenziato (es. Financial Modeling Prep, EOD) senza toccare la UI |
| **Regolamentazione** (rischio di configurarsi come consulenza/MiFID) | Posizionamento rigoroso "informational", nessun consiglio personalizzato, disclaimer pervasivi, consulenza legale prima del lancio Pro |
| **Qualità/copertura dati** | Validazione simboli, gestione errori per-simbolo già presente; provider professionale in roadmap |
| **Adozione** | Modalità demo + content marketing per ridurre attrito |
| **Privacy/sicurezza** | RLS su Supabase (ogni utente vede solo i propri dati), chiave anon pubblica, mai service_role nel client |

---

## 11. Tech & costi (sintesi)
- **Stack**: Flutter (web/mobile da un'unica codebase) + Supabase (Auth, Postgres, Edge Functions) + Vercel (hosting frontend).
- **Costi iniziali**: tier gratuiti/low-cost di Supabase e Vercel coprono la fase early. Il costo scala con utenti e, soprattutto, col passaggio a un **provider dati licenziato**.

---

## 12. Ask / prossimi passi
- Validare mercato e willingness-to-pay con 20–30 interviste a investitori retail.
- Deploy pubblico + raccolta dei primi 100 utenti dalla modalità demo.
- Decidere il provider dati definitivo prima di scalare.
- Verifica legale del posizionamento "non-advice" prima del Pro tier.
