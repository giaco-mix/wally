# Wally — One-pager (per il professore / parere esperto)

> Sintesi di una pagina da mostrare/mandare a un esperto (es. il professore) per
> raccoglierne il parere. Tono sobrio, niente hype. Versione 0.1.

---

## Cosa è Wally
**Wally** (da *Wallet* + *Ally*) è un **companion di finanza comportamentale**
per investitori retail. Web app (Flutter Web PWA) + Supabase, già funzionante
come MVP tecnico.

Non gestisce i soldi al posto dell'utente e non vende prodotti: lo aiuta a
**definire un piano, restare disciplinato e non mollare** nei momenti di paura —
quando si commettono gli errori più costosi.

> *"Wally non ti fa diventare ricco in fretta. Ti impedisce di rovinarti da solo."*

## Il problema
Il nemico dell'investitore retail non è scegliere il titolo giusto, ma il
**behavior gap**: panic-sell, market timing, PAC interrotti. Studi tipo
Morningstar *"Mind the Gap"* / Dalbar stimano un gap comportamentale dell'ordine
dell'**1–3%+ annuo** — su 20–30 anni, la differenza tra obiettivo raggiunto e
mancato.

## La soluzione (in 3 mosse)
1. **Obiettivo → piano**: onboarding goal-based, profilo di rischio in
   linguaggio umano, **piani di accumulo (PAC)** e lazy portfolio.
2. **Dashboard al netto**: quanto hai *davvero*, al netto di commissioni broker
   e differenze tra fondi (TER, accumulazione vs distribuzione).
3. **Resta nel piano**: ribilanciamento schedulato + **anti panic-sell**
   (check-in emotivo, contesto storico, freno gentile, "costo del mollare").

## Stato attuale (tecnico)
Roadmap a 4 fasi **completata e live**: 1) Onboarding+PAC · 2) Dashboard
netto+costi · 3) Ribilanciamento+notifiche · 4) Modulo comportamentale (Wally
Coach). Stack Flutter Web + Supabase + Vercel.

## Modello & differenziazione
- **Freemium SaaS B2C**. Ricavi dall'abbonamento, **non** da commissioni sui
  prodotti → zero conflitti d'interesse.
- Vs **broker** (eseguono, non sostengono), **robo-advisor** (gestiscono al
  posto tuo, regolamentati), **tracker** (monitorano, non coachano): Wally ti
  rende **capace e disciplinato**, mantieni il controllo.

## Confine regolamentare (punto su cui vogliamo il parere)
Wally è posizionato come **strumento educativo e di organizzazione**:
portafogli-modello generici e regole, **non** raccomandazioni personalizzate su
singoli strumenti. Vogliamo restare **fuori** dal perimetro della consulenza in
materia di investimenti (MiFID II; in Italia Albo OCF / CONSOB).

---

## Le 4 domande per il professore
1. Il **problema comportamentale** ti sembra reale e abbastanza grande da
   giustificare un prodotto dedicato?
2. Il **posizionamento educational/non-consulenza** regge, o ci sono funzioni
   che rischiano di sconfinare nella consulenza regolamentata?
3. Quali **fonti/dati** useresti per quantificare il behavior gap e il mercato
   italiano (Consob, Banca d'Italia, Assogestioni)?
4. Vedi un **percorso accademico o di rete** utile (mentor, advisor, contatti)
   per portarlo avanti?

*Documenti di approfondimento disponibili: business pitch, business plan,
brand & design system, presentazione (in `docs/pitch-and-society-docs/`).*
