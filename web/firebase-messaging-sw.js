importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "feel-care-2e521",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "1:244212724590:android:7b2600c0190ea8c436477f",
});

// Receive background messages
const messaging = firebase.messaging();
