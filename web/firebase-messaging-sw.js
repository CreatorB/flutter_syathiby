importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyBlq_IMB8RzggMXABz-bcigTW1AoqG8GOE",
    appId: "1:1016347653502:web:63ff317a7ab88c79aaef2f",
    messagingSenderId: "1016347653502",
    projectId: "al-ukhuwah",
    authDomain: "al-ukhuwah.firebaseapp.com",
    storageBucket: "al-ukhuwah.appspot.com",
    measurementId: "G-4HYN0ZHZXG"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    return self.registration.showNotification(notificationTitle,
        notificationOptions);
});
