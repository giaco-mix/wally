# Wally — Business Pitch

> Documento vivo. Versione 0.2 — riposizionamento su **finanza comportamentale**.
> I numeri di mercato sono **stime preliminari** da validare con fonti primarie.

---

## 1. Elevator pitch
La maggior parte degli investitori retail non perde soldi perché sceglie male: li perde perché **si comporta male** — vende nel panico, insegue le mode, esce dal mercato nel momento peggiore. Questo "behavior gap" costa punti di rendimento ogni anno.

**Wally è il coach che ti tiene investito.** Trasforma i tuoi obiettivi in un piano di accumulo automatico, ti dice con calma quando (e *se*) ribilanciare, e nei momenti di paura ti tiene per mano per evitare la mossa che rovina i risultati di anni. Fa il lavoro di un consulente — **senza esserlo** — con un tono umano e amichevole.

> *"Wally non ti fa diventare ricco in fretta. Ti impedisce di rovinarti da solo."*

---

## 2. Il problema: il nemico è dentro di noi
1. **Il panico vende sui minimi.** Alla prima correzione l'investitore esce, "tanto poi rientro" — e quasi mai rientra in tempo.
2. **Nessun piano, nessuna disciplina.** Si compra d'impulso, si smette di versare quando il mercato scende (proprio quando converrebbe).
3. **Sovraccarico di scelte.** "Voglio l'S&P 500" → ma esistono decine di ETF: TER diversi, ad accumulazione o distribuzione, valute, broker con commissioni diverse. L'utente si blocca.
4. **Solitudine emotiva.** Nessuno spiega *cosa fare e perché restare calmi*; i broker eseguono ordini, non danno supporto comportamentale.

**Conseguenza**: portafogli abbandonati, piani interrotti, rendimenti reali molto sotto al potenziale.

---

## 3. La soluzione: un companion di finanza comportamentale
Wally agisce sui **comportamenti**, non solo sui numeri:

- **Onboarding guidato per obiettivi** — "comprare casa", "andare in pensione prima", "rendita a 40 anni": da qui calcola budget, orizzonte e piano.
- **Profilo di rischio in linguaggio umano** — non "rischioso" ma *prudente / equilibrato / aggressivo*, spiegato con esempi concreti di oscillazione.
- **Piani di accumulo (PAC) al centro** — versamenti periodici automatizzabili, la leva n.1 contro il market timing.
- **Lazy portfolio pronti** — strategie semplici e diversificate (es. 3-fund, 60/40, all-world) come punto di partenza.
- **Ribilanciamento intelligente** — schedulato (mensile / trimestrale / annuale) **e** in tempo reale con alert ("il titolo X ha sbilanciato il portafoglio") e mosse concrete.
- **Anti panic-sell** — nei momenti di calo: check-in sullo stato emotivo, contesto storico, e un freno gentile prima di decisioni impulsive.
- **Proiezioni e commitment** — vedere dove ti porta il piano (e quanto ti costa mollare) crea lock-in psicologico positivo.
- **Trasparenza sul netto** — dashboard che mostra quanto hai *davvero*, al netto di commissioni di piattaforma (modificabili a mano) e differenze tra fondi (TER, ACC vs DIST).

**Tesi di fondo**: chiudere il **behavior gap**. Tenere l'investitore *dentro* al mercato, con metodo e serenità, vale più di qualsiasi stock picking.

---

## 4. Perché ora
- Boom di investitori retail post-2020, molti alla **prima** esperienza → massima esposizione agli errori comportamentali.
- Cultura del PAC/ETF in crescita in Italia, ma offerta di **supporto comportamentale in italiano** quasi assente.
- Strumenti digitali e API dati accessibili; una generazione che vuole capire, non delegare.

---

## 5. Mercato (stime da validare)
- **TAM**: investitori retail in Europa — decine di milioni di conti titoli attivi.
- **SAM**: investitori self-directed in Italia che usano (o vogliono usare) PAC/ETF.
- **SOM (3 anni)**: early adopter italiani 25–45 anni, digitalmente attivi, alla ricerca di metodo e supporto.

> Azione: validare con dati Consob/Banca d'Italia, ECB, Assogestioni (numero conti, AuM retail, diffusione PAC). Quantificare il behavior gap con studi tipo Morningstar "Mind the Gap" / Dalbar.

---

## 6. Prodotto — stato attuale vs visione
**✅ Già funzionante (MVP tecnico, Flutter Web PWA + Supabase):**
- Auth email, portafoglio (CRUD), dashboard con grafici, ribilanciamento target, analisi fondamentale + health score, storico prezzi, performance nel tempo, alert di sbilanciamento.

**🎯 Da costruire (visione comportamentale):**
- Onboarding goal-based + profilo di rischio friendly
- Motore PAC e lazy portfolio
- Coaching anti panic-sell + check-in emotivi
- Modellazione broker/commissioni e selezione fondi (TER, ACC/DIST)
- Proiezioni e meccaniche di commitment
- Notifiche comportamentali

---

## 7. Modello di business — Freemium
| Piano | Prezzo (ipotesi) | Cosa include |
|---|---|---|
| **Free** | 0€ | 1 obiettivo/portafoglio, PAC base, dashboard netto, lazy portfolio, ribilanciamento periodico |
| **Wally Pro** | ~4,99–8,99€/mese | Obiettivi illimitati, ribilanciamento real-time + alert, coaching avanzato, proiezioni, analisi fondamentale completa, modellazione commissioni multi-broker |
| **Futuro** | — | Import automatico da broker, ottimizzazioni fiscali IT, B2B2C con consulenti/educatori |

Niente conflitti d'interesse: **nessuna vendita di prodotti finanziari**, nessun rebate che condizioni i consigli. Monetizziamo il *valore comportamentale*, non il churn.

---

## 8. Concorrenza & differenziazione
| Player | Cosa fa | Gap che Wally colma |
|---|---|---|
| App broker (Directa, Fineco, Scalable, Trade Republic) | Esecuzione + PAC | Supporto comportamentale, multi-broker, coaching |
| Tracker (Snowball, Sharesight, Portfolio Performance) | Monitoraggio, dividendi | Coaching, onboarding goal-based, anti panic-sell |
| Robo-advisor (Moneyfarm, Euclidea) | Gestiscono *al posto tuo* (servizio regolamentato) | Wally **non gestisce**: ti rende capace e disciplinato, mantieni il controllo |
| Content finanza personale (YouTube, newsletter) | Educano | Personalizzazione sul *tuo* piano e azione concreta |

**Wedge**: *l'unico companion italiano che combatte gli errori comportamentali — anti panic-sell + PAC + ribilanciamento — con tono umano, senza gestire i tuoi soldi.*

---

## 9. Roadmap (12 mesi, indicativa)
- **Q1** — Onboarding goal-based + profilo rischio; lazy portfolio; PAC base; dashboard al netto.
- **Q2** — Ribilanciamento schedulato + real-time, notifiche comportamentali; modellazione commissioni/fondi.
- **Q3** — Modulo anti panic-sell + check-in emotivi; proiezioni e commitment; primi test di retention.
- **Q4** — Pro tier + pagamenti; import broker; app mobile; valutazione regolamentare per funzioni avanzate.

---

## 10. Rischi & mitigazioni
| Rischio | Mitigazione |
|---|---|
| **Regolamentazione (MiFID II / consulenza finanziaria)** — "fare il lavoro del consulente" è un'area sensibile | Posizionamento **educational/strumentale**: portafogli-modello generici e regole, **non** raccomandazioni personalizzate su singoli strumenti. Disclaimer pervasivi. **Consulenza legale CONSOB/OAM prima di funzioni che sfiorano la consulenza.** |
| **Dati di mercato** (Yahoo non ufficiale) | Astratto dietro `MarketRepository`: passaggio a provider licenziato senza toccare la UI |
| **Onere emotivo** (gestire stress degli utenti) | Tono calibrato, escalation a risorse esterne dove serve, niente promesse |
| **Adozione/retention** | Loop comportamentali (commitment, progressi), modalità demo, content marketing |
| **Privacy/sicurezza** | RLS su Supabase, dati sensibili minimizzati, mai service_role nel client |

---

## 11. Tech & costi (sintesi)
- **Stack**: Flutter (web/mobile single codebase) + Supabase (Auth, Postgres, Edge Functions) + Vercel.
- **Costi iniziali**: tier gratuiti/low-cost coprono la fase early; il costo scala con utenti e con il passaggio a **dati licenziati**.

---

## 12. Ask / prossimi passi
- Validare il problema comportamentale con 20–30 interviste (focus: panic-sell, interruzione PAC).
- Definire i lazy portfolio iniziali e il modello di profilazione del rischio.
- Parere legale sul confine educational vs consulenza.
- Lanciare onboarding + PAC e misurare la **retention dei versamenti** come metrica nord.
