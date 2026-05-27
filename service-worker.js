const CACHE_NAME='victoria-ayp-v7-ios-db-safe'
const ASSETS=['./','./index.html','./styles.css','./script.js','./config.js','./manifest.json','./assets/logo.png']
self.addEventListener('install',event=>{event.waitUntil(caches.open(CACHE_NAME).then(cache=>cache.addAll(ASSETS)).then(()=>self.skipWaiting()))})
self.addEventListener('activate',event=>{event.waitUntil(caches.keys().then(keys=>Promise.all(keys.map(key=>caches.delete(key)))).then(()=>self.clients.claim()))})
self.addEventListener('fetch',event=>{
  if(event.request.method!=='GET')return
  const url=new URL(event.request.url)
  if(url.origin.includes('supabase.co'))return
  event.respondWith(fetch(event.request,{cache:'no-store'}).then(response=>{
    const copy=response.clone()
    caches.open(CACHE_NAME).then(cache=>cache.put(event.request,copy))
    return response
  }).catch(()=>caches.match(event.request).then(cached=>cached||caches.match('./index.html'))))
})
