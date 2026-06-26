# Wally — Feature Backlog

> Idee estratte dal brainstorming (giu 2026). Non ancora pianificate per
> l'implementazione: servono a non perdere nulla e a decidere insieme la
> sequenza. Stato: 💡 idea · 🔜 candidata · 🚧 in corso · ✅ fatta.

Contesto: l'utente ha appena avviato il suo **primo PAC** e vuole **registrarlo
nell'app per tracciare il bilanciamento** nel tempo. Molte idee qui sotto nascono
da quel bisogno concreto.

---

## 🔑 Intuizione architetturale trasversale: ledger delle operazioni
Oggi il modello tiene solo le **posizioni correnti** (`holdings`: quantità + prezzo
medio). Diverse idee qui sotto (PAC registrato a posteriori, prezzo alla data,
buy-the-dip, maxi-canone, composizione variabile, tracciare il bilanciamento nel
tempo) richiedono di passare a un **ledger di operazioni/contributi**: ogni
acquisto/versamento come record con **data, strumento, importo, quantità, prezzo**.
Le posizioni diventano la somma delle operazioni. **È la fondazione di gran parte
del backlog "PAC realistico": va decisa presto.**

---

## A. Onboarding & profilazione

### A1. Quiz iniziale sulla situazione della persona 💡
Una schermata iniziale con **un paio di domande** per capire la situazione
dell'utente (es. esperienza, reddito/risparmio, conoscenza). In prospettiva l'app
**si adatta** alle risposte. *Nota dell'utente: roba più ampia, da analizzare più
avanti — tenere come idea.*

### A2. Reality-check rischio/rendimento ("la psicanalisi del consulente") 🔜
Domanda tipo *"Quanto vorresti rendere? 13–15% all'anno?"* → poi Wally fa capire,
con un paio di domande, che **rendimento e rischio non si separano**: per puntare al
15%/anno serve rischiare davvero tanto. Se l'utente **è consapevole** e lo vuole, ok;
se invece *"pensavo si potesse guadagnare tanto rischiando poco"*, allora lo aiuta a
**ribilanciare le aspettative**. È il momento in cui un consulente sonda
*"quanto sei disposto a rischiare?"*. Ottimo innesto comportamentale, da legare al
profilo di rischio dell'onboarding esistente.

---

## B. PAC realistico (richiede il ledger, vedi sopra)

### B1. Registrare un acquisto/PAC a posteriori, col prezzo alla data 🔜
Ho fatto il PAC ieri: inserendolo oggi, l'app deve usare **i prezzi a quella data**,
non quelli odierni. → ogni operazione ha una **data**, e il prezzo viene preso
storicamente (la edge function `yahoo` già supporta `chart` con range/intervallo).

### B2. Cadenza del PAC configurabile 🔜
Ogni quanto versi: **settimanale, bisettimanale (2× mese), mensile, trimestrale,
semestrale, annuale**, oppure **personalizzata**. (Estende/affianca la cadenza di
ribilanciamento già esistente — qui è la cadenza dei *versamenti*.)

### B3. Composizione variabile del PAC (core / satellite a rotazione) 💡
Il PAC non sempre compra la stessa cosa: es. un mese **core**, un mese **satellite**,
poi di nuovo core. Servono "ricette" di versamento che possono **ruotare** nel tempo,
non un'allocazione fissa per ogni contributo.

### B4. Investimenti aggiuntivi one-off / buy-the-dip 🔜
Possibilità di registrare **versamenti extra estemporanei** fuori dal PAC: es.
"quando il mercato crolla butto 1000€". Tracciati come operazioni a sé.

### B5. Maxi-canone / quota iniziale maggiore 💡
Supportare una **somma iniziale più grande** all'avvio del piano (lump sum iniziale)
oltre ai versamenti ricorrenti.

---

## C. Modello strumento / ETF

### C1. Valuta dello strumento (EUR/USD) 🔜
Distinguere la **valuta** dello strumento. Focus iniziale su **EUR e USD** (le
principali per l'Italia). Impatta valore/performance quando la valuta differisce da
quella di conto.

### C2. ETF a leva 💡
Flag per ETF **a leva**: cambia il profilo di rischio/comportamento. (L'ETF "normale"
replica l'indice, quindi a parità d'indice cambia poco; la differenza vera la fanno
**leva** e **valuta**.)

---

## D. Struttura

### D1. Multi-obiettivo / multi-portafoglio 🔜
Più piani/obiettivi in parallelo (es. casa + pensione), ciascuno col suo portafoglio,
target e ribilanciamento. **Strutturale**: oggi `plans`/`holdings`/`targets`/
`rebalance_settings` assumono *un* portafoglio per utente → da decidere presto perché
le altre feature ci si appoggiano.

---

## E. Import & dati

### E1. Import posizioni da CSV/broker 🔜
Caricare le posizioni da un **CSV** esportato dal broker, con mappatura colonne e
anteprima, invece dell'inserimento manuale. Si integra bene col ledger (E1 può
importare anche lo storico operazioni).

---

## F. Analisi & decisioni

### F1. Confronto fondi/ETF 🔜
Stesso indice, fondi diversi: confronto **TER, ACC/DIST, valuta, leva, performance,
costi** per scegliere il migliore. Sfrutta i nuovi fondamentali ETF già implementati.

### F2. Dividendi & rendita 🔜
Calendario dividendi, **rendita annua stimata** dal portafoglio (specie fondi DIST),
cashflow previsto.

---

## G. Esplorative / complesse

### G1. Notizie che potrebbero intaccare il portafoglio 💡
Sezione con **news** rilevanti per i titoli/temi in portafoglio. *L'utente la segnala
come "veramente complicata" — solo idea, da valutare molto più avanti.*

### G2. App adattiva post-quiz 💡
Far evolvere UI/contenuti in base alle risposte del quiz A1. Ampio, lungo termine.

---

## Sequenza suggerita (bozza, da decidere insieme)
1. **Ledger delle operazioni** (fondazione) → sblocca B1–B5 e il tracciamento del bilanciamento.
2. **Attributi strumento**: valuta EUR/USD (C1), poi leva (C2).
3. **PAC**: cadenza (B2) + maxi-canone (B5) + a posteriori con prezzo alla data (B1).
4. **Multi-portafoglio** (D1) — strutturale: valutare se anticiparlo prima del ledger.
5. **Import CSV** (E1) — si appoggia al ledger.
6. **Analisi**: confronto ETF (F1), dividendi & rendita (F2).
7. **Onboarding**: reality-check rischio/rendimento (A2), poi quiz situazione (A1).
8. **Composizione variabile PAC** (B3) e **buy-the-dip** (B4) come raffinamenti.
9. **Esplorative**: news (G1), app adattiva (G2).

> Vincolo di prodotto sempre valido: restare **educational / portafogli-modello**,
> NON consulenza personalizzata (MiFID/CONSOB).

---

## Stato implementazione (aggiornato)
- ✅ **A** — quiz profilo + reality-check rischio/rendimento (onboarding)
- ✅ **B** — ledger operazioni (PAC a posteriori col prezzo alla data, buy-the-dip, maxi-canone) + cadenza PAC + versamento iniziale nel piano
- ✅ **C** — valuta (EUR/USD) e leva sugli strumenti
- ✅ **E** — import posizioni da CSV
- ✅ **F** — confronto fondi/ETF + dividendi & rendita
- ✅ **G1** — news sul portafoglio
- ⏳ **D** — multi-obiettivo / multi-portafoglio: **rinviato di proposito** (vedi piano sotto)
- 💡 **B3** composizione PAC variabile (core/satellite) e **G2** app adattiva: idee, rinviate

### Piano per D (multi-portafoglio) — da fare in un passo dedicato
È l'unico pezzo strutturale: oggi `holdings`, `plans`, `targets`, `rebalance_settings`,
`transactions` sono per-utente. Approccio non-breaking proposto:
1. Tabella `portfolios (id, user_id, name)` + `ensureDefault` ("Principale").
2. Colonna `portfolio_id` (nullable) su `holdings` e `transactions`; le righe esistenti
   (null) appartengono al default.
3. `selectedPortfolioProvider`; `fetchHoldings/fetchTransactions` filtrano
   `portfolio_id is null or = selected`; nuove righe ereditano il portafoglio selezionato.
4. Selettore di portafoglio nella app bar della dashboard.
5. Decisione UX da prendere insieme: i `plans`/`targets`/`rebalance_settings` restano
   globali (una strategia) o diventano per-portafoglio? (impatta onboarding e ribilanciamento).
Motivo del rinvio: tocca tutti i provider che alimentano dashboard/ribilanciamento;
meglio farlo con verifica end-to-end dedicata e con la scelta UX del punto 5.
