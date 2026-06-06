# Wally — Passaggio a un provider dati di mercato licenziato

> Oggi i dati arrivano da **Yahoo Finance non ufficiale** via edge function
> (proxy CORS). Funziona, ma è fuori dai ToS e senza garanzie: prima di scalare
> conviene passare a un provider **licenziato**. Questo doc serve a **scegliere**;
> l'integrazione tecnica è già predisposta (vedi "Come si innesta").

## Perché cambiare
- **Legale/ToS**: l'API non ufficiale di Yahoo può cambiare o bloccarci senza
  preavviso; nessun diritto d'uso commerciale.
- **Affidabilità/SLA**: un provider a pagamento offre uptime e supporto.
- **Copertura**: ci servono soprattutto **ETF/azioni europee** (Borsa Italiana,
  Xetra…), valute EUR, e qualche **fondamentale** per la scheda titolo.

## Cosa ci serve davvero (requisiti di Wally)
I 5 metodi di `MarketRepository`:
| Metodo | Dato | Priorità |
|---|---|---|
| `quote` / `quotes` | prezzo + chiusura precedente (anche batch) | **alta** |
| `history` | serie storica (curva performance) | **alta** |
| `search` | ricerca simboli per onboarding/aggiunta titoli | media |
| `fundamentals` | TER non esiste qui; servono pochi fondamentali per l'health score | media/bassa |

> Nota prodotto: restiamo **educational/portafogli-modello**. I dati servono a
> monitoraggio e ribilanciamento, non a raccomandazioni personalizzate.

## Candidati (da validare con i listini ufficiali e i prezzi correnti)
| Provider | Punti di forza | Attenzioni | Free tier |
|---|---|---|---|
| **Twelve Data** | Buona copertura EU/borse, batch quote, storico, WebSocket | Limiti di rate sul free | Sì (limitato) |
| **EODHD** (EOD Historical Data) | Ottimo su **ETF europei** e EOD, fondamentali | Real-time costa di più | Sì (limitato) |
| **Financial Modeling Prep** | Fondamentali ricchi, prezzi, storico | Copertura EU da verificare | Sì (limitato) |
| **Finnhub** | Real-time US forte, websocket | Copertura/condizioni EU da verificare | Sì (limitato) |
| **Marketstack** | Semplice, EOD, molte borse | Real-time/intraday limitato | Sì (limitato) |
| **Alpha Vantage** | Gratuito, storico | Rate limit molto basso, EU debole | Sì (molto limitato) |

> ⚠️ I dettagli (prezzi, rate limit, copertura esatta delle borse EU, diritti di
> ridistribuzione in una web app B2C) **vanno verificati sul sito del provider**:
> cambiano spesso. Conta soprattutto: copertura Borsa Italiana/Xetra, costo del
> real-time vs delayed, e licenza per uso commerciale lato client.

## Raccomandazione di metodo (non di brand)
1. Scegli **1–2 provider** che coprano bene gli **ETF europei** del tuo target.
2. Parti dal **delayed/EOD** (più economico e sufficiente per un'app da PAC: non
   servono tick real-time per ribilanciare).
3. Verifica la **licenza di ridistribuzione** in un client B2C.
4. Stima il **costo a regime** in funzione di chiamate/utente (con cache).

## Come si innesta (già pronto nel codice)
- Astrazione: `lib/features/market/data/market_repository.dart` (5 metodi).
- Scaffold pronto: `lib/features/market/data/licensed_market_repository.dart`
  (plumbing HTTP + API key già fatti; restano i 5 mapping `*_fromX`).
- Selezione: `lib/core/providers.dart` → se `MARKET_PROVIDER=licensed` e ci sono
  `MARKET_API_BASE_URL` + `MARKET_API_KEY`, usa il licenziato; altrimenti Yahoo.
- Attivazione:
  ```bash
  flutter run -d chrome \
    --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... \
    --dart-define=MARKET_PROVIDER=licensed \
    --dart-define=MARKET_API_BASE_URL=https://api.provider.com \
    --dart-define=MARKET_API_KEY=...
  ```
  Su Vercel: aggiungere le stesse env e passarle come dart-define nel build.

### Dove tenere la API key
Se la licenza vieta di esporre la chiave nel client (comune), **non** passarla
via dart-define: instradare le chiamate attraverso una **edge function**
Supabase (come per Yahoo) che aggiunge la chiave server-side. In tal caso
`MARKET_API_BASE_URL` punta alla nostra edge function, non al provider.

## Passi quando avrai scelto
1. Verificare copertura/licenza/prezzi sul sito del provider.
2. Decidere client-side (dart-define) vs edge function (chiave server-side).
3. Completare i 5 metodi in `LicensedMarketRepository` (o nell'edge function).
4. Tarare una piccola cache per restare nei rate limit.
5. Test end-to-end sui simboli reali del tuo portafoglio.
