// サービスワーカーファイル
// 開発中はバージョン番号を随時変更することでキャッシュを強制的に更新できます
const CACHE_NAME = 'ar-app-cache-v2';
// 開発モードフラグ - 開発中はtrueに設定
const DEV_MODE = true;
const urlsToCache = [
];

// インストール時に既存のキャッシュをクリアして新しいリソースをキャッシュ
self.addEventListener('install', event => {
  console.log('サービスワーカーがインストールされました');
  
  // 開発モードの場合は即座にアクティブ化
  if (DEV_MODE) {
    self.skipWaiting();
  }
  
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          return caches.delete(cacheName);
        })
      );
    }).then(() => {
      return caches.open(CACHE_NAME)
        .then(cache => {
          console.log('新しいキャッシュを作成しました');
          return cache.addAll(urlsToCache);
        });
    })
  );
});

// ネットワークリクエストをインターセプト
self.addEventListener('fetch', event => {
  // 開発モードではキャッシュを使わず常に新しいコンテンツを取得
  if (DEV_MODE) {
    return fetch(event.request, { cache: 'no-store' })
      .catch(err => console.log('Fetch error:', err));
  }
  
  event.respondWith(
    fetch(event.request, { cache: 'no-cache' })
      .then(response => {
        // レスポンスのクローンを作成
        const responseToCache = response.clone();
        
        // キャッシュを更新
        caches.open(CACHE_NAME)
          .then(cache => {
            cache.put(event.request, responseToCache);
          });
          
        return response;
      })
      .catch(() => {
        // ネットワークエラーの場合はキャッシュから返す
        return caches.match(event.request);
      })
  );
});

// 古いキャッシュを削除して即座にコントロール開始
self.addEventListener('activate', event => {
  console.log('サービスワーカーがアクティブになりました');
  
  // 即座にページのコントロールを取得
  event.waitUntil(self.clients.claim());
  
  // 古いバージョンのキャッシュを削除
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('古いキャッシュを削除:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});