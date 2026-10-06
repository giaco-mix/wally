# Analisi competitor — FinFast

> App analizzata il 7 ott 2026 (fonti: App Store + finfast.it). FinFast è
> un'**accademia gamificata + simulatore di trading virtuale** ("impara a
> investire giocando"), rivolta ai **principianti**. **Non** gestisce denaro
> reale. Sviluppatore: Massimo Onofri. Freemium: gratis + Premium €4,99/mese
> (€44,99/anno). iOS/iPad/Mac/visionOS.

## Posizionamento (vs Wally)
- **FinFast** = *pre-investitore*: imparare e **simulare** con soldi finti,
  gamification spinta, community/competizioni.
- **Wally** = *investitore attivo*: gestire il **portafoglio reale**, PAC,
  ribilanciamento, comportamento (anti panic-sell), consulenti.
- **Overlap** = la parte **educativa/engagement**. È lì che stanno le idee da
  rubare, senza trasformare Wally in un gioco.

## Listona funzionalità FinFast
**Apprendimento**
- 200+ lezioni in 19 percorsi tematici (azioni, ETF, obbligazioni, crypto,
  psicologia, pensione, mercati globali, crowdfunding, fiscalità).
- Lezioni testo **o audiolibro**, **quiz** a fine lezione, **download offline**.
- **Glossario** 200+ termini spiegati semplici.
- Illustrazioni nelle lezioni.

**Simulatore di borsa (paper trading)**
- Trading virtuale con crediti (no soldi veri), prezzi reali.
- Mercati USA/Europa/Cina; azioni, ETF, materie prime, crypto.
- Portafoglio virtuale con tracking, **PAC mensile simulato**, grafico storico.

**Schede aziende / analisi**
- Grafico prezzi, **ultimi conti trimestrali**, ricavi/utili, **acquisti/vendite
  dei dirigenti (insider)**, notizie correlate, **obiettivi analisti**,
  fondamentali (P/E, margini, crescita).
- **"Voto FinFast" / Metodo Max** (5 voti di qualità per aziende USA).
- Analisi approfondite + **video brevi**; aggiornamenti settimanali.

**Notizie**
- Notizie di mercato quotidiane, variazioni dei titoli citati evidenziate,
  **briefing giornaliero di 2 minuti**, notizie salvabili, notifiche.

**AI**
- **FinBot**: tutor AI (guida iniziale + **briefing settimanale** del lunedì).
- **"Fammi una domanda"**: Q&A (2 risposte/settimana nel free).

**Gamification**
- **XP + livelli**, **streak** giorni consecutivi (bonus), **crediti** (si
  guadagnano studiando, si spendono per sbloccare contenuti), **traguardi/
  sfide** (missioni da 3 giorni), **classifiche** globali/categoria.
- **Arena**: sfide 1v1, tornei a eliminazione, lega settimanale (chi cresce di
  più il portafoglio), tornei tematici, "Ritorno al Mercato".
- **Temi** colore (Oro/Platino/Smeraldo/Ametista) Premium.

**Utility / altro**
- Watchlist "segui titolo" + **avvisi earnings/movimenti**.
- **Calcolatore stipendio netto da RAL**.
- Accessibilità (VoiceOver, testo 200%, dark, contrasto).

**Premium (€4,99/mese)**: no pubblicità, tutti i percorsi/analisi/video,
+50% crediti, temi, contenuti senza limiti.

## Cosa vale la pena integrare in Wally (mia valutazione)
Criterio: coerente con la missione (investitore reale + comportamento), in-house,
senza snaturare il tono "companion serio".

| Idea | Interesse | Note |
|---|---|---|
| **Gamifica il comportamento giusto**: streak dei versamenti PAC, badge "not-quitter", traguardi (es. "12 mesi senza interrompere") | ⭐⭐⭐ | Rinforza esattamente la tesi di Wally; in-house; già c'è la metrica not-quitter |
| **Quiz + progresso nell'Academy** | ⭐⭐⭐ | Trasforma le lezioni statiche in un percorso; engagement; in-house |
| **Glossario** dei termini | ⭐⭐ | Easy win; completa l'Academy |
| **Briefing giornaliero/settimanale** (digest news in 2 min) | ⭐⭐ | Abbiamo già le news; sintesi curata; in-house |
| **Watchlist + avvisi earnings** | ⭐⭐ | Estende le notifiche; dati parziali da Yahoo |
| **Schede azienda più ricche**: insider, target analisti, earnings | ⭐⭐ | Dipende dai dati (Yahoo copre in parte); si lega al DCF appena fatto |
| **Tutor AI "Fammi una domanda"** | ⭐⭐⭐ (ma costo) | Potente e on-trend, ma richiede un **LLM a pagamento** → confligge col vincolo "niente servizi a pagamento". Da decidere |
| **Simulatore / paper trading** | ⭐ | Prodotto diverso (gioco pre-investitore). Al massimo un "prova una strategia" sandbox |
| **Arena/competizioni, temi premium** | ✩ | Non in linea col tono; semmai i temi come leva monetizzazione |

## Sintesi
FinFast è forte sull'**onboarding educativo e l'engagement** (il nostro punto più
debole), debole sulla **gestione reale** (il nostro punto forte). Le idee migliori
da prendere sono nel **layer educazione/engagement**: gamification del
comportamento virtuoso, quiz nell'Academy, glossario, briefing. Il **tutor AI** è
il salto di qualità, ma va deciso perché costa (LLM).
