// Proxies Google CDN assets that Chrome sometimes blocks (ERR_CONNECTION_RESET)
// to local copies under /firebasejs and /fonts so Flutter web can boot.
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  if (url.hostname === 'www.gstatic.com' && url.pathname.includes('/firebasejs/')) {
    const fileName = url.pathname.split('/').pop();
    event.respondWith(fetch(new URL(`/firebasejs/${fileName}`, self.location.origin)));
    return;
  }

  if (url.hostname === 'fonts.gstatic.com' && url.pathname.includes('/roboto/')) {
    const isMedium = url.pathname.includes('EU9f') || url.pathname.includes('Medium');
    const local = isMedium ? '/fonts/Roboto-Medium.woff2' : '/fonts/Roboto-Regular.woff2';
    event.respondWith(fetch(new URL(local, self.location.origin)));
  }
});
