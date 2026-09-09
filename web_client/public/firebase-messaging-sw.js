importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyATdb3DAdF-NM59V_iSg8Fw-OXonlFqxwI',
  appId: '1:745547133225:web:867063751eb218cd230738',
  messagingSenderId: '745547133225',
  projectId: 'jobnoti-4c078',
  authDomain: 'jobnoti-4c078.firebaseapp.com',
  storageBucket: 'jobnoti-4c078.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
