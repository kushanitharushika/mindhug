# Mindhug 🫂

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![scikit-learn](https://img.shields.io/badge/scikit--learn-%23F7931E.svg?style=for-the-badge&logo=scikit-learn&logoColor=white)

Mindhug is a comprehensive mental health and wellness cross-platform mobile application designed to provide users with tools for emotional regulation, self-reflection, and personalized recommendations. It serves as a companion for users seeking a structured approach to managing their mental wellbeing through various activities such as journaling, guided exercises, cognitive testing, and AI chatbot support.

---

## ✨ Features

- **User Authentication:** Secure email/password login and OTP phone authentication via Firebase.
- **Personalized Profiles:** Manage account details, personal configurations, and avatars.
- **Journaling System:** Create, view, and store personal journal entries with mood tags. Media uploads are securely stored in Firebase Storage.
- **Mood Tracking & Assessment Quizzes:** Regular interactions to capture emotional states, including a comprehensive Stroop Cognitive Quiz to assess cognitive flexibility and focus.
- **ML-Based Exercise Recommendations:** Uses a custom Random Forest machine learning model to suggest the top 5 specific exercises or activities based on user input (stress level and mood).
- **Daily Care & Smart Reminders:** Configurable daily task management featuring a smart Hydration Timer (based on mood/activity), Posture Checks, and custom habits. Managed reliably via background inexact alarms.
- **Chatbot Interface:** Integration with Chatbase for an engaging conversational AI companion to offer immediate support and coping strategies.
- **Mental Health Trends Dashboard:** Visual charts summarizing check-in results and cognitive performance over time.
- **Admin Dashboard:** Secure data-driven overview of the system for administrators.

## 🏗️ Architecture

The system utilizes a modern, decoupled architecture:
1. **Frontend (Mobile App):** Built with **Flutter (Dart)** for cross-platform availability on iOS and Android. It handles UI/UX, local state, offline persistence, and scheduling background notifications.
2. **Backend Services (BaaS):** Relies on **Firebase** (Auth, Firestore, Storage) for secure, scalable, and real-time data management. Custom security rules strictly govern access.
3. **Machine Learning Engine:** A custom **Python (FastAPI)** backend hosting a serialized `.pkl` Random Forest model (utilizing `scikit-learn`). It exposes RESTful APIs to predict tailored exercise recommendations. The app implements graceful fallback rule-based local logic if the ML API is offline.

## 🛠️ Technology Stack

- **Mobile Framework:** Flutter (Dart SDK >=3.10.1)
- **Database & Auth:** Firebase (Cloud Firestore, Firebase Auth, Firebase Storage)
- **Machine Learning API:** Python 3.x, FastAPI, scikit-learn, pandas, numpy, uvicorn
- **Key Flutter Packages:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `shared_preferences`, `fl_chart`, `flutter_local_notifications`, `pinput`

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Python 3.9+ (for the ML Engine)
- A Firebase project configured with your Android/iOS bundle ID.

### Running the Flutter Application

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kushanitharushika/mindhug.git
   cd mindhug
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure you have your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) placed in the respective directories according to Firebase documentation. Alternatively, use the `flutterfire_cli` to configure it.

4. **Run the app:**
   ```bash
   flutter run
   ```

### Running the Python ML Engine

The machine learning recommendation engine runs locally during development. 

1. **Navigate to the ML engine directory:**
   ```bash
   cd ml_engine
   ```

2. **Create and activate a virtual environment (optional but recommended):**
   ```bash
   python -m venv .venv
   # Windows
   .venv\Scripts\activate
   # macOS/Linux
   source .venv/bin/activate
   ```

3. **Install dependencies:**
   *(Ensure you have a `requirements.txt` file or install manually)*
   ```bash
   pip install fastapi uvicorn scikit-learn pandas numpy pydantic
   ```

4. **Run the FastAPI server:**
   ```bash
   uvicorn main:app --reload
   # OR
   python app.py
   ```
   The API will be available at `http://127.0.0.1:8000`. The Flutter app is configured to communicate with this local endpoint.

## 🔒 Security

User data is securely stored in Firestore with strict custom security rules. Only authenticated users can access their personal data, while global collections are protected by admin-only write access.
