// Service worker dedicato al Web Push di Wally.
// Registrato su uno scope separato ("push/") per non interferire con il service
// worker di Flutter (che gestisce la cache offline sullo scope "/").

self.addEventListener('install', (event) => {
  // Attiva subito la nuova versione senza attendere la chiusura delle tab.
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

// Arrivo di una notifica push dal server (edge function send-push).
self.addEventListener('push', (event) => {
  let payload = {};
  try {
    payload = event.data ? event.data.json() : {};
  } catch (_) {
    payload = { title: 'Wally', body: event.data ? event.data.text() : '' };
  }

  const title = payload.title || 'Wally';
  const options = {
    body: payload.body || '',
    icon: payload.icon || '/icons/Icon-192.png',
    badge: payload.badge || '/icons/Icon-192.png',
    tag: payload.tag || payload.kind || 'wally',
    renotify: true,
    data: { url: payload.url || '/' },
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

// Click sulla notifica: porta l'utente nel punto giusto dell'app.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = (event.notification.data && event.notification.data.url) || '/';

  event.waitUntil(
    self.clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then((clientList) => {
        // Se una tab di Wally è già aperta, la focalizza e naviga.
        for (const client of clientList) {
          if ('focus' in client) {
            client.focus();
            if ('navigate' in client) {
              try { client.navigate(targetUrl); } catch (_) {}
            }
            return;
          }
        }
        // Altrimenti apre una nuova finestra.
        if (self.clients.openWindow) {
          return self.clients.openWindow(targetUrl);
        }
      }),
  );
});
