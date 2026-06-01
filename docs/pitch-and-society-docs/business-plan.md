# Wally — Business Plan

> Documento vivo. Versione 0.1. Numeri e ipotesi da validare; serve a dare struttura alla visione emersa dal brainstorming.

---

## 1. Executive summary
**Wally** è un *companion di finanza comportamentale* per investitori retail. Non gestisce i soldi al posto dell'utente e non vende prodotti: lo aiuta a **definire un piano, restare disciplinato e non mollare** — specialmente nei momenti di paura, quando si commettono gli errori più costosi.

Il problema che risolviamo non è "quale titolo comprare", ma il **behavior gap**: la distanza tra il rendimento dei mercati e quello che l'investitore medio ottiene davvero, erosa da panic-sell, market timing e piani interrotti. Wally trasforma obiettivi di vita in **piani di accumulo (PAC)**, propone **lazy portfolio** diversificati, automatizza il **ribilanciamento**, e fornisce **coaching comportamentale** con un tono umano e incoraggiante.

**Modello**: freemium SaaS B2C (web PWA + mobile). **Metrica nord**: retention dei versamenti (quanti utenti continuano il PAC nel tempo).

---

## 2. Missione, visione, valori
- **Missione**: ridurre il behavior gap degli investitori retail, rendendoli disciplinati e sereni.
- **Visione**: un investitore che, grazie a Wally, **non molla** — attraversa le crisi restando nel piano e raccoglie i frutti del lungo periodo.
- **Valori**: chiarezza, metodo (non scommesse), trasparenza (anche sui costi e i limiti), rispetto (informiamo, non sostituiamo il giudizio), empatia.

**Mantra di prodotto**: *fare diventare l'investitore un "not-quitter".*

---

## 3. Il problema in profondità (la finanza comportamentale)
Bias che Wally combatte:
- **Loss aversion / panic selling** — la paura di perdere fa vendere sui minimi.
- **Recency bias / performance chasing** — si insegue ciò che è appena salito.
- **Action bias** — "fare qualcosa" sembra meglio di restare fermi (di solito è il contrario).
- **Analysis paralysis** — troppe scelte (quale ETF S&P 500? ACC o DIST? quale broker?) bloccano l'azione.
- **Present bias** — si interrompe il PAC quando "servono" i soldi o quando il mercato scende.

Evidenza da citare/validare: studi tipo Morningstar *"Mind the Gap"* e Dalbar QAIB stimano un gap comportamentale dell'ordine dell'1–3%+ annuo. Su 20–30 anni è la differenza tra obiettivo raggiunto e mancato.

---

## 4. La soluzione e il flusso utente

### 4.1 Onboarding (il cuore dell'esperienza)
1. **Obiettivo di vita** — comprare casa, indipendenza finanziaria, rendita, "ricco a 40", università dei figli…
2. **Strategia**: due ingressi possibili
   - *Capitale obiettivo* ("voglio arrivare a X €") → Wally calcola il versamento mensile necessario dato l'orizzonte.
   - *Versamento sostenibile* ("posso mettere Y €/mese") → Wally proietta il risultato atteso.
3. **Orizzonte e modalità d'ingresso** — quando si entra sul mercato; preferenza per **piani di accumulo** vs ingresso una tantum (Wally spinge sul PAC per ridurre il market timing).
4. **Profilo di rischio in linguaggio friendly** — *prudente / equilibrato / aggressivo* (mai "rischioso"), spiegato con scenari concreti ("in un brutto anno potresti vedere -X%; ecco perché ha senso").
5. **Piattaforme e costi** — su quali broker hai posizioni; calcolo (con override manuale) delle **commissioni** di piattaforma per mostrare il **netto**.

### 4.2 Costruzione del piano
- Selezione di un **lazy portfolio** adatto al profilo (es. all-world 100%, 80/20, 60/40, 3-fund).
- Spiegazione delle scelte di prodotto: a parità di indice (es. S&P 500) gli ETF differiscono per **TER**, **politica dei dividendi (ACC/DIST)**, valuta, replica. Wally aiuta a scegliere e spiega il *perché*.
- Definizione del **PAC**: importo, frequenza, allocazione.

### 4.3 Vita del piano (retention & coaching)
- **Dashboard del netto**: quanto hai davvero, al netto di costi e fee.
- **Ribilanciamento**: schedulato (mensile/trimestrale/annuale) e/o real-time con alert + mosse concrete; preferenza per ribilanciare **con i nuovi versamenti** (più efficiente fiscalmente).
- **Anti panic-sell**: nei cali, check-in emotivo, contesto storico ("nel 2020 il mercato fece -34% e recuperò in N mesi"), e un **freno gentile** prima di azioni impulsive.
- **Progressi e proiezioni**: riferimenti al passato ("3 mesi fa avevi paura e sei rimasto: ecco il risultato"), proiezione del traguardo, **costo del mollare** → commitment.
- **Tono**: simpatico, motivante, "vai avanti, non mollare".

> **Confine importante**: Wally fornisce educazione, portafogli-modello e regole generali. Evita raccomandazioni personalizzate su singoli strumenti finanziari che possano configurare **consulenza finanziaria** regolamentata (vedi §9).

---

## 5. Prodotto: stato attuale e backlog
**Costruito (MVP tecnico)**: auth, portafoglio CRUD, dashboard + grafici, ribilanciamento target, analisi fondamentale + health score, storico prezzi, performance nel tempo, alert di sbilanciamento. Stack Flutter Web PWA + Supabase, live su Vercel.

**Backlog prioritario (visione)**:
1. Onboarding goal-based + profilazione rischio friendly
2. Motore PAC (calcolo versamento/proiezione) + lazy portfolio templates
3. Dashboard al netto (commissioni broker, modello fondi TER/ACC-DIST)
4. Ribilanciamento schedulato + real-time, notifiche comportamentali
5. Modulo anti panic-sell + check-in emotivi + progressi/commitment

---

## 6. Mercato e segmenti
- **Primario**: 25–45 anni, reddito medio, prima/seconda esperienza d'investimento, già su un broker (Directa, Fineco, Scalable, Trade Republic, Degiro…), tentati dal PAC ma senza metodo o disciplina.
- **Secondario**: chi ha smesso di versare dopo un calo e vuole ripartire con struttura.
- **B2B2C futuro**: educatori finanziari, creator, reti che vogliono uno strumento white-label per i propri follower/clienti.

Stime TAM/SAM/SOM: vedi pitch §5 (da quantificare con fonti primarie).

---

## 7. Modello di business e pricing
Freemium SaaS (vedi pitch §7). Principi:
- **Allineamento di interessi**: ricavi dall'abbonamento, **non** da commissioni sui prodotti né da churn. Il successo di Wally = utenti che restano investiti e contenti.
- **Possibili linee future**: B2B2C white-label; contenuti/coaching premium; **mai** conflitti d'interesse occulti.

KPI economici da modellare: CAC, conversion free→Pro, churn, LTV, payback. Metrica nord di prodotto: **% utenti con PAC attivo dopo 6/12 mesi**.

---

## 8. Go-to-market
1. **Content & SEO in italiano** sul tema comportamentale (panic-sell, "non interrompere il PAC", come scegliere un ETF).
2. **Community e creator** di finanza personale IT.
3. **Loop di prodotto**: demo + onboarding a basso attrito; condivisione dei progressi.
4. **Referral**: l'utente "not-quitter" come ambasciatore.

---

## 9. Compliance e aspetti legali (critico)
- **Rischio**: "fare il lavoro del consulente finanziario" può ricadere nella **consulenza in materia di investimenti** (MiFID II), riservata a soggetti autorizzati (in Italia: iscrizione all'**Albo OCF**, vigilanza **CONSOB**).
- **Strategia di posizionamento**: Wally è **strumento educativo e di organizzazione**, offre **portafogli-modello generici** e **regole**, non raccomandazioni personalizzate su strumenti specifici. Linguaggio e UX progettati per restare in questo perimetro.
- **Azioni**: disclaimer pervasivi; parere legale **prima** di funzioni che si avvicinano alla consulenza; valutare partnership con un consulente/SCF autorizzato se si vuole spingere oltre.
- **Privacy (GDPR)**: dati finanziari ed emotivi sono sensibili → minimizzazione, RLS, trasparenza, base giuridica chiara.

---

## 10. Tecnologia e operations
- **Stack**: Flutter (web+mobile), Supabase (Auth/Postgres/Edge Functions/Cron), Vercel. Architettura feature-based, repository pattern (dati di mercato astratti → provider licenziabile).
- **Operations**: deploy via git (Vercel) + dashboard/CLI Supabase; cron per snapshot/ribilanciamento/notifiche schedulate.
- **Costi**: bassi in fase early (tier gratuiti); le voci che scalano sono **dati di mercato licenziati** e **notifiche/infra** con la crescita utenti.

---

## 11. Rischi principali
Vedi pitch §10. Top 3: **regolamentazione**, **retention/engagement comportamentale**, **qualità/licenza dei dati**.

---

## 12. Roadmap e milestone
- **M1–M3**: onboarding + PAC + lazy portfolio + dashboard netto → primi 100 utenti, interviste.
- **M4–M6**: ribilanciamento real-time + notifiche + modellazione costi → misurare retention versamenti.
- **M7–M9**: modulo comportamentale (anti panic-sell, proiezioni, progressi) → ottimizzare retention.
- **M10–M12**: Pro tier + pagamenti, mobile, parere regolamentare → monetizzazione.

---

## 13. Team & ask
- Team: founder dell'idea + sviluppo prodotto (Wally). Da rafforzare: marketing/content, eventuale advisor regolamentare.
- Ask immediato: validazione del problema comportamentale, definizione lazy portfolio e profilazione, parere legale sul confine educational/consulenza.
