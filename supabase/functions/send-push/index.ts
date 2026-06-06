// Edge Function: invio Web Push delle notifiche di Wally.
//
// Viene chiamata dal cron giornaliero (vedi docs/web-push-setup.md). Calcola
// chi deve ricevere una notifica e la invia via VAPID alle sottoscrizioni
// salvate in `push_subscriptions`. Usa la service_role (bypassa la RLS).
//
// Tipi di notifica ("kind"):
//   - rebalance : il ribilanciamento schedulato è "due" (logica = client Dart)
//   - checkin   : nudge di check-in comportamentale (chi ha già usato il coach
//                 ma non fa un check-in da 7+ giorni). NON dipende dal mercato:
//                 resta dentro il confine "educational / non consulenza".
//
// Sicurezza: protetta da header `x-cron-secret` (env CRON_SECRET).
//
// Deploy:  supabase functions deploy send-push --no-verify-jwt
// Secrets: VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY, VAPID_SUBJECT, CRON_SECRET
//          (SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY sono iniettati da Supabase)

import { createClient } from "npm:@supabase/supabase-js@2";
import webpush from "npm:web-push@3.6.7";

const CHECKIN_INACTIVITY_DAYS = 7;

interface PushPayload {
  title: string;
  body: string;
  url: string;
  kind: string;
}

const PAYLOADS: Record<string, Omit<PushPayload, "kind">> = {
  rebalance: {
    title: "È ora di ribilanciare",
    body:
      "Secondo la tua cadenza è il momento di dare un'occhiata e riportare il " +
      "piano in equilibrio.",
    url: "/rebalance",
  },
  checkin: {
    title: "Come ti senti oggi?",
    body:
      "Un check-in veloce con Wally ti aiuta a restare nel piano, anche quando " +
      "il mercato fa rumore.",
    url: "/coach",
  },
};

// Replica di _addMonths (lib/.../rebalance_settings.dart) per parità col client.
function addMonths(d: Date, months: number): Date {
  const m = d.getUTCMonth() + months;
  const y = d.getUTCFullYear() + Math.floor(m / 12);
  const nm = ((m % 12) + 12) % 12;
  const lastDay = new Date(Date.UTC(y, nm + 1, 0)).getUTCDate();
  const day = Math.min(d.getUTCDate(), lastDay);
  return new Date(Date.UTC(y, nm, day));
}

const FREQ_MONTHS: Record<string, number> = {
  none: 0,
  monthly: 1,
  quarterly: 3,
  annual: 12,
};

function isRebalanceDue(frequency: string, lastRebalancedAt: string | null): boolean {
  const months = FREQ_MONTHS[frequency] ?? 0;
  if (months === 0) return false;
  if (!lastRebalancedAt) return false; // base = now -> next nel futuro -> non due
  const next = addMonths(new Date(lastRebalancedAt + "T00:00:00Z"), months);
  return Date.now() >= next.getTime();
}

Deno.serve(async (req) => {
  // 1) Autenticazione del cron.
  const cronSecret = Deno.env.get("CRON_SECRET");
  if (!cronSecret || req.headers.get("x-cron-secret") !== cronSecret) {
    return new Response("unauthorized", { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  webpush.setVapidDetails(
    Deno.env.get("VAPID_SUBJECT") ?? "mailto:hello@wally.app",
    Deno.env.get("VAPID_PUBLIC_KEY")!,
    Deno.env.get("VAPID_PRIVATE_KEY")!,
  );

  const today = new Date().toISOString().slice(0, 10);

  // 2) Determina i destinatari per ciascun "kind".
  //    Mappa userId -> Set<kind>.
  const targets = new Map<string, Set<string>>();
  const addTarget = (userId: string, kind: string) => {
    const set = targets.get(userId) ?? new Set<string>();
    set.add(kind);
    targets.set(userId, set);
  };

  // 2a) Ribilanciamento "due".
  const { data: settings } = await supabase
    .from("rebalance_settings")
    .select("user_id, frequency, last_rebalanced_at")
    .neq("frequency", "none");
  for (const s of settings ?? []) {
    if (isRebalanceDue(s.frequency, s.last_rebalanced_at)) {
      addTarget(s.user_id, "rebalance");
    }
  }

  // 2b) Nudge di check-in: chi ha già fatto almeno un check-in ma non da 7+
  //     giorni. Consideriamo solo utenti con una sottoscrizione push.
  const { data: subRows } = await supabase
    .from("push_subscriptions")
    .select("user_id");
  const subscribedUsers = new Set<string>((subRows ?? []).map((r) => r.user_id));
  const cutoff = new Date(Date.now() - CHECKIN_INACTIVITY_DAYS * 86400000);
  for (const userId of subscribedUsers) {
    const { data: lastCheckin } = await supabase
      .from("mood_checkins")
      .select("created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (lastCheckin && new Date(lastCheckin.created_at) < cutoff) {
      addTarget(userId, "checkin");
    }
  }

  // 3) Invia, saltando ciò che è già stato mandato oggi.
  let sent = 0;
  let removed = 0;

  for (const [userId, kinds] of targets) {
    for (const kind of kinds) {
      // Anti-duplicato giornaliero.
      const { data: already } = await supabase
        .from("push_notification_log")
        .select("kind")
        .eq("user_id", userId)
        .eq("kind", kind)
        .eq("sent_on", today)
        .maybeSingle();
      if (already) continue;

      const { data: subs } = await supabase
        .from("push_subscriptions")
        .select("endpoint, p256dh, auth")
        .eq("user_id", userId);
      if (!subs || subs.length === 0) continue;

      const base = PAYLOADS[kind];
      const payload = JSON.stringify({ ...base, kind });

      let anyDelivered = false;
      for (const sub of subs) {
        try {
          await webpush.sendNotification(
            { endpoint: sub.endpoint, keys: { p256dh: sub.p256dh, auth: sub.auth } },
            payload,
          );
          anyDelivered = true;
          sent++;
        } catch (err) {
          const status = (err as { statusCode?: number }).statusCode;
          // Sottoscrizione scaduta/rimossa: pulisci.
          if (status === 404 || status === 410) {
            await supabase
              .from("push_subscriptions")
              .delete()
              .eq("endpoint", sub.endpoint);
            removed++;
          }
        }
      }

      if (anyDelivered) {
        await supabase
          .from("push_notification_log")
          .insert({ user_id: userId, kind, sent_on: today });
      }
    }
  }

  return new Response(
    JSON.stringify({ ok: true, sent, removed, day: today }),
    { headers: { "Content-Type": "application/json" } },
  );
});
