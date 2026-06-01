# Wally — Brand Identity & Design System

> Documento vivo. Versione 0.1 — bozza iniziale. Allineato all'implementazione corrente (Flutter + Material 3).

---

## 1. Brand essence

| | |
|---|---|
| **Nome** | **Wally** |
| **Etimologia** | *Wallet* + *Ally* — il portafoglio che diventa un alleato |
| **Categoria** | Companion di **finanza comportamentale** per investitori retail |
| **One-liner** | *Il coach che ti tiene investito.* |
| **Tagline alternative** | "Non mollare. Ci penso io." · "Trasforma le emozioni in un piano." · "Diventa un not-quitter." |

### Mission
Ridurre il **behavior gap** degli investitori retail: aiutarli a definire un piano, restare disciplinati e **non mollare** nei momenti di paura, con un supporto umano e accessibile — senza gergo, senza costi da strumenti pro, senza gestire i loro soldi al posto loro.

### Vision
Un investitore che, grazie a Wally, attraversa le crisi **restando nel piano** e raccoglie i frutti del lungo periodo: un *not-quitter*.

### Valori
- **Empatia** — capiamo la paura; non la giudichiamo, la accompagniamo.
- **Disciplina serena** — metodo e PAC contro l'impulso; mai l'hype.
- **Chiarezza** — niente gergo, ogni numero (e ogni emozione) ha una spiegazione.
- **Trasparenza** — mostriamo dati, costi e limiti; non vendiamo prodotti finanziari.
- **Rispetto** — Wally informa e sostiene, non sostituisce il giudizio dell'utente né fa consulenza regolamentata.

---

## 2. Personalità & Tone of Voice

Wally è il **coach amichevole** — parte allenatore, parte amico esperto — che ti tiene calmo quando il mercato fa paura e ti spinge a non mollare il piano.

| È | Non è |
|---|---|
| Empatico, incoraggiante | Paternalistico |
| Calmo nei momenti di panico | Allarmista |
| Simpatico, umano | Freddo o robotico |
| Onesto sui rischi e sui costi | Promotore di rendimenti |
| Motivante ("non mollare") | Pressante o colpevolizzante |

**Regole di copy**
- Dai del "tu", tono caldo e simpatico; celebra i progressi.
- **Linguaggio del rischio friendly**: *prudente / equilibrato / aggressivo*, mai "rischioso/pericoloso". Spiega con scenari concreti.
- **Nei cali**: prima l'emozione ("è normale avere paura"), poi il contesto ("nel 2020 il mercato recuperò in N mesi"), poi il freno gentile. Mai "vendi/compra ora".
- **Commitment positivo**: usa riferimenti al passato dell'utente ("3 mesi fa eri preoccupato e sei rimasto: guarda ora") e proiezioni del traguardo.
- Mai linguaggio da consulenza personalizzata o garanzie. Preferisci "in base al tuo piano", "molti investitori nella tua situazione".
- Disclaimer sempre presente dove si mostrano dati/azioni: *"Informazioni a scopo educativo, non costituiscono consulenza finanziaria."*

**Esempi di micro-copy**
- Calo di mercato: *"Giornata rossa. È normale sentirsi nervosi — ma il tuo piano è pensato proprio per questo. Vuoi vedere cosa successe nelle ultime correzioni?"*
- PAC eseguito: *"Versamento fatto 💪 Stai comprando più quote proprio mentre costano meno. Questo è essere un not-quitter."*
- Sbilanciamento: *"Il titolo X è cresciuto tanto e ora pesa troppo. Possiamo riportare il piano in equilibrio col prossimo versamento."*

---

## 3. Logo & Wordmark

**Wordmark**: "Wally" in peso extra-bold, `letter-spacing` leggermente negativo (-0.5), colore *Wally Blue*.

**Symbol (concept)**: una **"W" stilizzata** le cui aste formano due barre in equilibrio che si trasformano in una linea ascendente — sintesi visiva di *bilanciamento* + *crescita*. In assenza del mark definitivo, l'app usa l'icona `savings` (salvadanaio) dentro un contenitore arrotondato (`primaryContainer`, raggio 20) come placeholder.

**Spazio di rispetto**: mantenere attorno al logo un padding pari all'altezza della "W".

**Don't**: non ruotare, non applicare ombre pesanti, non usare su sfondi a basso contrasto, non comprimere/allargare.

---

## 4. Colori

Palette ancorata alla finanza (fiducia = blu) con verde "crescita" e rosso "perdita" come colori funzionali. I valori marcati ✅ sono **già implementati** in `lib/core/theme/app_theme.dart`.

### Core
| Ruolo | Hex | Note |
|---|---|---|
| **Wally Blue** (primary, seed) ✅ | `#1565C0` | Genera lo schema Material 3 (`ColorScheme.fromSeed`) |
| Deep Navy | `#0D2C54` | Testi forti su chiaro, superfici scure |
| Ink | `#11161C` | Testo primario |
| Slate | `#5B6B7B` | Testo secondario |
| Mist | `#EEF2F6` | Sfondi/superfici chiare |

### Funzionali (semantici)
| Ruolo | Hex | Uso |
|---|---|---|
| **Growth Green** ✅ | `#2E7D32` | Guadagni, variazioni positive, azioni "compra" |
| **Signal Red** ✅ | `#C62828` | Perdite, variazioni negative, azioni "vendi" |
| Balance Teal (accent) | `#00897B` | Highlight/CTA secondari, elementi "in linea" |

> Regola d'oro finanza: **verde = su, rosso = giù**, sempre, in ogni grafico e cifra. Mai invertire.

### Tema
Material 3 con `useMaterial3: true`, supporto **light e dark** (`ThemeMode.system`). Lo schema completo (surface, container, outline) è derivato automaticamente dal seed.

---

## 5. Tipografia

| Ruolo | Font consigliato | In uso ora |
|---|---|---|
| Display / Headings | **Sora** o **Plus Jakarta Sans** (geometrico, fintech) | Roboto (default Flutter) |
| Body / UI | **Inter** | Roboto (default Flutter) |
| Numeri / cifre | Inter con **tabular figures** (`fontFeatures: tabularFigures`) | — da introdurre |

**Raccomandazione**: per le tabelle (portafoglio, piano di ribilanciamento) attivare le **tabular figures** così le cifre restano incolonnate. È il prossimo upgrade tipografico suggerito.

Scala (Material 3 type scale): `headlineMedium` per il wordmark, `headlineSmall`/`titleLarge` per titoli schermata, `titleMedium` per titoli card, `bodyMedium`/`bodySmall` per contenuti e didascalie.

---

## 6. Iconografia & Imagery
- **Icone**: Material Symbols (outline per stati inattivi, filled per attivi) — già usato nella `NavigationRail`/`NavigationBar`.
- **Stile**: arrotondato, lineare, peso medio. Niente icone scheumorfiche.
- **Imagery**: grafici puliti e dati come protagonisti; evitare foto stock di "uomini d'affari".

---

## 7. Layout & Spacing
- **Scala di spaziatura** (px): `4 · 8 · 12 · 16 · 24 · 32`.
- **Larghezza massima contenuto**: `1100` (centrata) — già applicata nello shell.
- **Breakpoint**: `≥ 760px` → layout wide con `NavigationRail`; sotto → `NavigationBar` in basso. ✅
- **Griglia metriche** (scheda titolo): 1 / 2 / 3 colonne in base alla larghezza. ✅

---

## 8. Componenti (design tokens → codice)

Valori **già implementati** in `app_theme.dart`:

| Componente | Token | Valore |
|---|---|---|
| Card | raggio / bordo / elevazione | `16` · outline `outlineVariant` · `0` |
| Bottone primario (Filled) | raggio / altezza minima | `12` · `48` |
| Input | stile / densità | `OutlineInputBorder` · dense |
| Chip | uso | tag asset class, settore |
| Banner demo | colore | `tertiaryContainer` |

**Pattern UI ricorrenti**
- **Summary card**: icona in `CircleAvatar` colorato + label + valore in grassetto.
- **Stati**: `loading` (spinner centrato), `error` (messaggio), `empty` (icona + invito all'azione). Ogni lista li gestisce.
- **Colore semantico**: guadagni/perdite usano `AppTheme.positive`/`AppTheme.negative`.

---

## 9. Accessibilità
- Contrasto minimo **AA** (4.5:1) per testo; lo schema Material 3 lo garantisce sui colori `on*`.
- Non affidare informazione **solo** al colore: affianca segno (`+`/`-`) e label ("Compra"/"Vendi"). ✅ già fatto.
- Target touch ≥ 48px. ✅
- Supporto dark mode. ✅

---

## 10. Roadmap del brand
1. Mark/logo definitivo + favicon e icone PWA brandizzate (ora placeholder Flutter).
2. Introduzione font Inter + tabular figures.
3. Token accent **Balance Teal** nei CTA secondari.
4. Illustrazioni custom per empty state.
5. Brand guidelines complete (PDF) + asset kit.
