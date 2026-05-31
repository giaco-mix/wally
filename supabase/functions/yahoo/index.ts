// Edge Function: proxy verso Yahoo Finance (API non ufficiale).
//
// Perché serve: Yahoo non espone header CORS, quindi non è chiamabile
// direttamente da una web app. Questa funzione gira server-side, aggiunge un
// User-Agent, gestisce cookie+crumb per i fondamentali e restituisce JSON con
// header CORS validi.
//
// Azioni (query param `action`):
//   chart   ?symbol=AAPL                 -> quotazione/serie prezzi
//   summary ?symbol=AAPL                 -> moduli quoteSummary (fondamentali)
//   search  ?q=apple                     -> ricerca simboli
//
// Deploy:  supabase functions deploy yahoo --no-verify-jwt

const UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/124.0 Safari/537.36";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SUMMARY_MODULES = [
  "assetProfile",
  "summaryDetail",
  "defaultKeyStatistics",
  "financialData",
  "price",
].join(",");

// Cache in-memory di cookie+crumb (riusati tra invocazioni a caldo).
let cachedCrumb: { crumb: string; cookie: string; ts: number } | null = null;

async function getCrumb(): Promise<{ crumb: string; cookie: string }> {
  if (cachedCrumb && Date.now() - cachedCrumb.ts < 30 * 60 * 1000) {
    return cachedCrumb;
  }
  const res = await fetch("https://fc.yahoo.com", {
    headers: { "User-Agent": UA },
  });
  const setCookie = res.headers.get("set-cookie") ?? "";
  const cookie = setCookie.split(";")[0];
  await res.body?.cancel();

  const crumbRes = await fetch(
    "https://query2.finance.yahoo.com/v1/test/getcrumb",
    { headers: { "User-Agent": UA, cookie } },
  );
  const crumb = (await crumbRes.text()).trim();
  cachedCrumb = { crumb, cookie, ts: Date.now() };
  return cachedCrumb;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

async function fetchJson(url: string, extra: Record<string, string> = {}) {
  const res = await fetch(url, {
    headers: { "User-Agent": UA, accept: "application/json", ...extra },
  });
  if (!res.ok) {
    throw new Error(`Yahoo ha risposto ${res.status}: ${await res.text()}`);
  }
  return res.json();
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }

  const url = new URL(req.url);
  const action = url.searchParams.get("action");
  const symbol = url.searchParams.get("symbol") ?? "";
  const q = url.searchParams.get("q") ?? "";

  try {
    switch (action) {
      case "chart": {
        if (!symbol) return json({ error: "symbol mancante" }, 400);
        // range/interval opzionali (default 5d/1d, retro-compatibile con le
        // quotazioni). Usati per il grafico storico (es. 1mo, 6mo, 1y).
        const allowedRange = new Set([
          "1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "max",
        ]);
        const allowedInterval = new Set([
          "1m", "5m", "15m", "1h", "1d", "1wk", "1mo",
        ]);
        const range = url.searchParams.get("range") ?? "5d";
        const interval = url.searchParams.get("interval") ?? "1d";
        if (!allowedRange.has(range) || !allowedInterval.has(interval)) {
          return json({ error: "range/interval non validi" }, 400);
        }
        const data = await fetchJson(
          `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}?interval=${interval}&range=${range}`,
        );
        return json(data);
      }
      case "summary": {
        if (!symbol) return json({ error: "symbol mancante" }, 400);
        const { crumb, cookie } = await getCrumb();
        const data = await fetchJson(
          `https://query2.finance.yahoo.com/v10/finance/quoteSummary/${encodeURIComponent(symbol)}?modules=${SUMMARY_MODULES}&crumb=${encodeURIComponent(crumb)}`,
          { cookie },
        );
        return json(data);
      }
      case "search": {
        if (!q) return json({ error: "q mancante" }, 400);
        const data = await fetchJson(
          `https://query2.finance.yahoo.com/v1/finance/search?q=${encodeURIComponent(q)}&quotesCount=10&newsCount=0`,
        );
        return json(data);
      }
      default:
        return json({ error: "action non valida (chart|summary|search)" }, 400);
    }
  } catch (e) {
    return json({ error: String(e) }, 502);
  }
});
