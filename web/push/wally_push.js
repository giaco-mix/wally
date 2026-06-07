// Ponte JS per il Web Push, richiamato dal codice Dart via js_interop.
// Espone tre funzioni su window:
//   wallyPushSupported()            -> bool
//   wallyEnablePush(vapidPublicKey) -> Promise<string JSON>
//   wallyDisablePush()              -> Promise<string JSON>
//
// Le funzioni che "abilitano/disabilitano" restituiscono SEMPRE una stringa
// JSON (mai una reject) così il lato Dart la può parsare in modo uniforme:
//   { ok: true, endpoint, p256dh, auth }          (enable)
//   { ok: true }                                   (disable)
//   { ok: false, error: "<motivo>" }               (errore gestito)

(function () {
  'use strict';

  // Scope dedicato per non collidere col service worker di Flutter ("/").
  const SW_URL = 'push/wally_push_sw.js';
  const SW_SCOPE = 'push/';

  function supported() {
    return (
      'serviceWorker' in navigator &&
      'PushManager' in window &&
      'Notification' in window
    );
  }

  // Converte la VAPID public key (base64url) in Uint8Array per subscribe().
  function urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - (base64String.length % 4)) % 4);
    const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
    const raw = atob(base64);
    const output = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) output[i] = raw.charCodeAt(i);
    return output;
  }

  function bufferToBase64Url(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  function subscriptionToJson(sub) {
    const json = sub.toJSON();
    return {
      ok: true,
      endpoint: sub.endpoint,
      p256dh: (json.keys && json.keys.p256dh) || bufferToBase64Url(sub.getKey('p256dh')),
      auth: (json.keys && json.keys.auth) || bufferToBase64Url(sub.getKey('auth')),
    };
  }

  window.wallyPushSupported = function () {
    return supported();
  };

  window.wallyEnablePush = async function (vapidPublicKey) {
    try {
      if (!supported()) {
        return JSON.stringify({ ok: false, error: 'unsupported' });
      }
      if (!vapidPublicKey) {
        return JSON.stringify({ ok: false, error: 'missing-vapid-key' });
      }

      const permission = await Notification.requestPermission();
      console.log('[wally-push] permission:', permission);
      if (permission !== 'granted') {
        return JSON.stringify({ ok: false, error: 'permission-' + permission });
      }

      const reg = await navigator.serviceWorker.register(SW_URL, { scope: SW_SCOPE });
      console.log('[wally-push] SW registrato, scope:', reg.scope);
      // Attende che QUESTO service worker (scope /push/) diventi attivo: la
      // subscribe() fallisce se non c'è un worker attivo per la registrazione.
      await _waitActive(reg);
      console.log('[wally-push] SW attivo:', !!reg.active);

      let sub = await reg.pushManager.getSubscription();
      if (!sub) {
        sub = await reg.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(vapidPublicKey),
        });
      }
      console.log('[wally-push] subscription ok:', sub && sub.endpoint);

      return JSON.stringify(subscriptionToJson(sub));
    } catch (e) {
      const detail = e && e.name ? e.name + ': ' + e.message : String(e);
      console.error('[wally-push] enable error:', detail, e);
      return JSON.stringify({ ok: false, error: detail });
    }
  };

  // Risolve quando la registrazione ha un service worker attivo.
  function _waitActive(reg) {
    if (reg.active) return Promise.resolve();
    return new Promise((resolve) => {
      const sw = reg.installing || reg.waiting;
      if (!sw) return resolve();
      sw.addEventListener('statechange', () => {
        if (sw.state === 'activated') resolve();
      });
      // Salvagente: non bloccare oltre 10s.
      setTimeout(resolve, 10000);
    });
  }

  window.wallyDisablePush = async function () {
    try {
      if (!supported()) return JSON.stringify({ ok: true });
      const reg = await navigator.serviceWorker.getRegistration(SW_SCOPE);
      if (!reg) return JSON.stringify({ ok: true });
      const sub = await reg.pushManager.getSubscription();
      let endpoint = null;
      if (sub) {
        endpoint = sub.endpoint;
        await sub.unsubscribe();
      }
      return JSON.stringify({ ok: true, endpoint: endpoint });
    } catch (e) {
      return JSON.stringify({ ok: false, error: String((e && e.message) || e) });
    }
  };
})();
