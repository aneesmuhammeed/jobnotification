import { initializeApp } from 'firebase/app';
import { getMessaging, getToken, onMessage } from 'firebase/messaging';
import { supabase } from './supabase';

const firebaseConfig = {
  apiKey: 'AIzaSyATdb3DAdF-NM59V_iSg8Fw-OXonlFqxwI',
  appId: '1:745547133225:web:867063751eb218cd230738',
  messagingSenderId: '745547133225',
  projectId: 'jobnoti-4c078',
  authDomain: 'jobnoti-4c078.firebaseapp.com',
  storageBucket: 'jobnoti-4c078.firebasestorage.app',
  measurementId: 'G-CBB8SVH6F9',
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

export const requestNotificationPermission = async () => {
  try {
    const permission = await Notification.requestPermission();
    if (permission === 'granted') {
      const currentToken = await getToken(messaging, {
        // You usually need a VAPID key here, but it works without it if the backend doesn't enforce WebPush VAPID explicitly.
        // It's better to configure a VAPID key in Firebase Console -> Project Settings -> Cloud Messaging -> Web configuration.
        // But for MVP, let's just request the token.
      });
      
      if (currentToken) {
        // Save the token to Supabase profiles
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) {
          await supabase.from('profiles').update({ fcm_token: currentToken }).eq('id', session.user.id);
        }
        return currentToken;
      } else {
        console.log('No registration token available. Request permission to generate one.');
      }
    } else {
      console.log('Unable to get permission to notify.');
    }
  } catch (err) {
    console.log('An error occurred while retrieving token. ', err);
  }
};

export const listenForForegroundMessages = () => {
  onMessage(messaging, (payload) => {
    console.log('Message received. ', payload);
    // Custom foreground notification if needed
    alert(`${payload.notification?.title}: ${payload.notification?.body}`);
  });
};
