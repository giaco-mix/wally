# Wally — Brand Identity & Design System

> Documento vivo. Versione 0.1 — bozza iniziale. Allineato all'implementazione corrente (Flutter + Material 3).

---

## 1. Brand essence

| | |
|---|---|
| **Nome** | **Wally** |
| **Etimologia** | *Wallet* + *Ally* — il portafoglio che diventa un alleato |
| **Categoria** | Companion finanziario per investitori retail |
| **One-liner** | *Il tuo alleato per investire con metodo.* |
| **Tagline alternative** | "Ribilancia. Capisci. Cresci." · "Il portafoglio, ma con un piano." |

### Mission
Rendere la gestione consapevole del portafoglio semplice e accessibile a chiunque, unendo **ribilanciamento guidato** e **analisi fondamentale** comprensibile, senza il gergo e i costi degli strumenti professionali.

### Vision
Un mondo in cui ogni piccolo investitore prende decisioni con la stessa chiarezza di un professionista, capendo *cosa* possiede, *perché* e *cosa fare dopo*.

### Valori
- **Chiarezza prima di tutto** — niente gergo inutile, ogni numero ha una spiegazione.
- **Metodo, non scommesse** — promuoviamo disciplina e diversificazione, mai l'hype.
- **Trasparenza** — mostriamo i dati e i loro limiti; non vendiamo prodotti finanziari.
- **Rispetto** — Wally informa, non sostituisce il giudizio dell'utente né fa consulenza.

---

## 2. Personalità & Tone of Voice

Wally è il **collega esperto e tranquillo** che ti spiega le cose senza farti sentire ignorante.

| È | Non è |
|---|---|
| Chiaro, concreto | Accademico, prolisso |
| Rassicurante | Paternalistico |
| Competente | Saccente |
| Onesto sui rischi | Promotore di rendimenti |
| Caldo e umano | Freddo o robotico |

**Regole di copy**
- Dai del "tu", tono amichevole ma professionale.
- Una frase, un concetto. Preferisci numeri spiegati a numeri nudi.
- Mai linguaggio che suggerisca consulenza finanziaria o garanzie ("compra ora", "rendimento sicuro"). Usa "potresti valutare", "in base alla tua allocazione target".
- Disclaimer sempre presente dove si mostrano dati di mercato: *"Le informazioni hanno scopo puramente informativo e non costituiscono consulenza finanziaria."*

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
