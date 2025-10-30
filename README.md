# 💬 Chatify - Messaging App

**Chatify** is a cross-platform real-time messaging application built with **Flutter** (frontend) and **Firebase Cloud Functions** (backend).  
It supports authentication, chat messaging, and cloud-based real-time data syncing — providing a smooth and responsive user experience.

---

<h2>📱 App Screenshots</h2>

<p align="center">
  <img src="https://github.com/user-attachments/assets/6834b228-aba3-446d-998e-48cf0e8df9cc" width="200" />
  <img src="https://github.com/user-attachments/assets/c036f404-9605-4981-b094-ba37b2b95241" width="200" />
  <img src="https://github.com/user-attachments/assets/64a6b60b-98fd-424e-abfc-93b33442a8b2" width="200" />
  <img src="https://github.com/user-attachments/assets/e1011ca1-808c-4a35-a2b0-1539cd7307e1" width="200" />
  <img src="https://github.com/user-attachments/assets/e8c04bab-b3b1-458c-817f-828ccb8cd306" width="200" />
  <img src="https://github.com/user-attachments/assets/56c8744d-d3b9-44d7-9404-8087320d5cb6" width="200" />
  <img src="https://github.com/user-attachments/assets/f2dba83d-eff4-4773-82f6-07fb6e8ea53b" width="200" />
  <img src="https://github.com/user-attachments/assets/c26310e8-e580-4d7d-81c5-b394114dc857" width="200" />
  <img src="https://github.com/user-attachments/assets/0d8e8352-e2da-4990-b7b0-951e05e54818" width="200" />
  <img src="https://github.com/user-attachments/assets/eaf3a789-3148-42d4-95f9-334ef25f8b99" width="200" />
  <img src="https://github.com/user-attachments/assets/108b37a8-ca2f-4c3f-938c-c81d4ed37404" width="200" />
  <img src="https://github.com/user-attachments/assets/2f0e33a5-c2a2-461e-8ebe-21440ee90bdd" width="200" />
</p>

---)

## 🚀 Features
- 🔐 Firebase Authentication (Login & Signup)
- 💬 Real-time Messaging
- 📱 Flutter Frontend with clean UI
- ☁️ Firebase Cloud Functions for backend logic
- 🔔 Push Notifications support (optional)
- 🌐 Cross-platform (Android, iOS, Web)

---

## 🏗️ Project Structure
Chatify/
├── chatify_app/ # Flutter frontend
│ ├── lib/
│ ├── android/
│ └── pubspec.yaml
│
└── chatify_firebase_provider/ # Firebase backend
├── functions/
│ ├── src/
│ ├── lib/
│ └── package.json
├── firebase.json
└── .firebaserc


---

## ⚙️ Setup Instructions

### 🖥️ 1. Clone the Repository

git clone https://github.com/mushrifa-hussain/chatify.git
cd "CHATIFY - MEASSAGING APP"

### 📱 2. Setup Flutter Frontend

bash
Copy code
cd chatify_app
flutter pub get
flutter run

### ☁️ 3. Setup Firebase Backend

bash
Copy code
cd ../chatify_firebase_provider/functions
npm install
firebase deploy

---

## Note:

Make sure you have Flutter SDK and Firebase CLI installed.

You must be logged in to Firebase CLI and have access to your Firebase project before deploying.


---

✅ You can paste this block directly inside your **README.md** under “Setup Instructions” — it will render perfectly formatted on GitHub.  

Would you like me to include a short **“Requirements” section** (tools needed like Flutter, Node.js, Firebase CLI) right before this one for clarity?
