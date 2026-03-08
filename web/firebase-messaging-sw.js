importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAi2dvfPvFbH8aJOoAuje0ImXsRnI_TS-I',
  authDomain: 'adil-taxi-dms.firebaseapp.com',
  projectId: 'adil-taxi-dms',
  storageBucket: 'adil-taxi-dms.firebasestorage.app',
  messagingSenderId: '440481124362',
  appId: '1:440481124362:web:7c9fc6ef224b351a290ff3',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const title = notification.title || 'Adil Travels';
  const options = {
    body: notification.body || '',
    icon: '/icons/Icon-192.png',
  };
  self.registration.showNotification(title, options);
});
