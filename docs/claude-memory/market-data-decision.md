---
name: market-data-decision
description: "Wally — decisione su provider dati di mercato: tenere Yahoo per ora, derivati fuori scope, licenziato rimandato"
metadata:
  type: project
---

Decisione (giu 2026) sui dati di mercato di Wally:
- **Tenere Yahoo non ufficiale (via edge function) per ora.** Copre azioni + ETF, che è ciò che serve a Wally (PAC/ETF). Va bene per MVP/dogfooding/interviste. Non "diventa a pagamento": non c'è account/contratto: il rischio è rottura/blocco/ToS, non la fatturazione.
- **Derivati fuori scope.** Yahoo li copre male (certificati EU assenti, niente option chain nella edge function) e sono fuori dalla tesi comportamentale (PAC, lungo periodo) + sfiorano il confine "non consulenza". L'`AssetClass` non li modella.
- **Switch a provider licenziato rimandato** alla fase di scaling. Lo swap è già predisposto: `LicensedMarketRepository` (scaffold) + selezione via `--dart-define=MARKET_PROVIDER=licensed`/`MARKET_API_BASE_URL`/`MARKET_API_KEY` in `lib/core/providers.dart`. Confronto candidati in `docs/market-data-providers.md`.
- **Quando si sceglierà**: per un'app da PAC basta l'**EOD** (non servono tick real-time) → preferire un tier EOD economico/freemium; valutare se la licenza obbliga a tenere la API key server-side (allora dietro edge function come Yahoo).
- **Costo delle chiamate**: l'API non ufficiale di Yahoo può rate-limitare → evitare raffiche di richieste (es. niente storico per-riga in liste lunghe). La sparkline è stata limitata alle viste di drill-down (poche righe).

**How to apply:** non implementare i 5 mapping di LicensedMarketRepository finché l'utente non sceglie il provider; non aggiungere feature sui derivati senza richiesta esplicita. Vedi [project_overview](project_overview.md).
