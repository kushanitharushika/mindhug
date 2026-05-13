# Mindhug - Interim Progress Report

## Chapter 01 Introduction 
### 1.1 Introduction 
Mindhug is a comprehensive mental health and wellness mobile application designed to provide users with tools for emotional regulation, self-reflection, and personalized recommendations. The application serves as a companion for users seeking a structured approach to managing their mental wellbeing through various activities such as journaling, guided exercises, music therapy, and AI chatbot support.

### 1.2 Problem Definition 
In today's fast-paced world, many individuals struggle with stress, anxiety, and mood fluctuations without accessible, centralized tools to help them cope. Existing solutions are often fragmented, offering either journaling, meditation, or mood tracking separately, without an integrated approach that personalizes the experience based on the user's current mental state.

### 1.3 Project Objectives 
* To develop a cross-platform mobile application providing an all-in-one mental health toolkit.
* To integrate a machine learning engine that provides personalized exercise and wellness recommendations based on real-time mood and stress levels.
* To encourage healthy physical habits (like hydration) through smart, dynamically adjusting daily care timers.
* To provide secure and private user data management via Firebase services with role-based access control.
* To implement a conversational UI chatbot prototype to offer immediate, engaging support and coping strategies.
* To visualize users' mental health trends over time for better self-awareness.

## Chapter 02 System Analysis 
### 2.1 Facts Gathering Techniques 
* **Literature Review:** Analyzing existing research on mobile mental health interventions and effective coping mechanisms.
* **Competitor Analysis:** Evaluating existing mental wellness apps to identify feature gaps and improve UX/UI design.
* **User Personas & Scenarios:** Creating profiles of potential users to understand their needs, preferences, and pain points.

### 2.2 Existing System 
Currently, users often rely on multiple disaggregated tools: one app for meditation, physical journals for tracking thoughts, and generic articles for mental health education. They lack a cohesive ecosystem that adapts to their daily emotional fluctuations.

### 2.3 Drawbacks of the existing system 
* **Fragmentation:** Users have to switch between different tools, causing a disjointed experience.
* **Lack of Personalization:** Generic recommendations that do not take the user's immediate mood or stress level into consideration.
* **Poor Data Insights:** Inability to easily correlate journal entries with mood trends over an extended period.

## Chapter 03 Requirements Specification 
### 3.1 Functional Requirements 
* **User Authentication:** Secure email/password login and OTP phone authentication via Firebase.
* **User Profile & Preferences:** Ability to manage account details and personal configurations.
* **Journaling System:** Create, view, and store personal journal entries.
* **Mood Tracking & Assessment Quizzes:** Regular interactions to capture user emotional states.
* **ML-Based Recommendations:** Suggesting top 5 specific exercises or activities based on user input (`level` and `mood`).
* **Chatbot Interface:** A UI prototype for a conversational interface for user support.
* **Mental Health Trends Dashboard:** Visual charts (`fl_chart`) summarizing check-in results over time.

### 3.2 Non-Functional Requirements 
* **Security & Privacy:** User data must be securely stored in Firestore with strict custom security rules (UID validation and admin-only write access to global collections).
* **Scalability:** The backend services (Firebase and Python FastAPI) must be designed to accommodate future growth, such as upgrading from native `setState` to robust state management like Riverpod.
* **Usability:** A modern, calming, and intuitive user interface utilizing trauma-informed, emotionally safe copywriting (e.g., using "You might benefit from extra care today" instead of aggressive alerts).
* **Performance:** Fast load times and responsive UI with graceful fallbacks (e.g., local rule-based recommendations if the ML API is offline).

### 3.3 Hardware / Software Requirements 
* **Hardware:** Android or iOS smartphone with vibration and notification capabilities.
* **Software:** 
  * Mobile App: Flutter (Dart SDK >=3.10.1)
  * Backend API: Python 3.x server (FastAPI)
  * Database: Firebase (Firestore, Storage, Auth)

### 3.4 Networking Requirements (Optional) 
* Active internet connection for syncing data with Firebase and querying the Python ML API.
* Offline mode capability caches quiz results, journals, and user profiles via `shared_preferences`.

## Chapter 04 Feasibility Study 
### 4.1 Operational Feasibility 
The system is designed to be highly user-centric, requiring minimal technical knowledge from the end-user. The automated recommendation engine and intuitive dashboards ensure users can easily navigate and benefit from the tool on a daily basis.

### 4.2 Technical Feasibility 
The choice of Flutter for cross-platform mobile development ensures a single codebase for both iOS and Android, reducing development time. Utilizing Firebase provides robust, out-of-the-box backend infrastructure. The custom Python ML backend using FastAPI and `scikit-learn` is a well-documented, standard approach that is highly feasible for serving predictive models. Currently, the API runs locally during development, with cloud deployment (e.g., Render or Railway) planned.

### 4.3 Outline Budget 
* **Development Tools:** Open-source frameworks (Flutter, Python, scikit-learn) - $0
* **Backend Services:** Firebase (Spark/Blaze plan) - Freemium model, initial cost $0
* **Hosting (ML API):** Local deployment currently ($0); planned Cloud provider (e.g., Railway) - ~$5 to $20/month depending on usage.
* **Developer Time:** Primary investment in personnel hours.

## Chapter 05 System Architecture 
### 5.1 Use case diagram 
*(Placeholder for Use Case Diagram detailing interactions between User, Firebase Auth, Database, Chatbot API, and ML API)*

### 5.2 Class Diagram of Proposed System 
*(Placeholder for Class Diagram outlining the domain models: User, JournalEntry, Exercise, RecommendationService, AuthService)*

### 5.3 ER Diagram 
*(Placeholder for Entity-Relationship Diagram outlining the flat Firestore structure: collections `users/{userId}`, `questions`, `exercises`, `quiz_history`, and `journal`)*

### 5.4 High-level Architectural Diagram 
*(Placeholder for High-Level Architecture Diagram showing the Flutter Client communicating with Firebase BaaS and the Python Machine Learning API local endpoints)*

### 5.5 Networking Diagram (Optional) 
*(Placeholder for Networking Diagram showing client-server interaction via REST APIs over HTTPS)*

## Chapter 06 Development Tools and Technologies 
### 6.1 Development Methodology 
Agile development methodology with iterative sprints, allowing for continuous integration (via GitHub Actions workflow: linting, testing, and debug APK building), rapid prototyping, and frequent testing of individual modules.

### 6.2 Programming Languages and Tools 
* **Languages:** Dart (Frontend), Python (ML Backend)
* **IDEs:** Visual Studio Code / Android Studio
* **Version Control:** Git & GitHub

### 6.3 Third Party Components and Libraries 
* **Flutter Packages:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `shared_preferences`, `http`, `fl_chart`, `flutter_local_notifications`, `pinput`, `image_picker`, `permission_handler`.
* **Python Packages:** `FastAPI`, `uvicorn`, `pandas`, `scikit-learn`, `numpy`, `pydantic`.

### 6.4 Algorithms 
* **Machine Learning Algorithm:** `RandomForestClassifier` wrapped within `MultiOutputClassifier` to handle multi-label classification tasks. It predicts the probability of 11 different exercises being beneficial based on the user's stress 'level' (0-3) and 'mood' (0-4).

## Chapter 07 Implementation Progress
### 7.1 Development Environment Setup
* Configured Flutter SDK and initialized the project.
* Set up Firebase project, integrating Auth, Firestore, and Storage with rigorous custom security rules.
* Created a Python virtual environment (`.venv`) and installed ML dependencies.
* Implemented CI/CD pipeline using GitHub Actions for automated linting (`flutter analyze`) and testing (`flutter test`).

### 7.2 Implemented Features
* **Onboarding & Auth:** Complete email/password and phone OTP auth flows.
* **Home Dashboard:** Integrated "Mental Health Trends" chart showing user-specific data.
* **Daily Care & Smart Hydration:** A "Drink Timer" feature that sets a dynamic daily water intake goal (8-10 glasses) based on the user's logged mood (e.g., +1 for stress/anxiety) and recommended physical activities, complete with offline persistence and background push notifications every 2 hours.
* **Recommendation Engine:** A functional Python FastAPI backend hosting a serialized `.pkl` Random Forest model that predicts the top 5 exercise recommendations. Fallback rule-based local logic is implemented for offline resilience.
* **Chatbot Interface:** A prototype UI interface (`MeloChatScreen`) has been implemented; backend conversational intelligence integration is planned for the next phase.
* **Core Modules:** Journaling system, guided exercises UI, and music/relaxation features.

### 7.3 Model Evaluation & Validation
* **Dataset:** Synthetically generated 200 rows with dynamically injected noise (30% randomness) across input features to prevent overfitting and mimic realistic variance.
* **Evaluation Metric:** The model implements an 80/20 train/test split. It currently achieves **62% Exact Match (Subset) Accuracy**. Because a `MultiOutputClassifier` is utilized, subset accuracy is an exceptionally strict metric—it requires the model to correctly predict *all* applicable labels simultaneously to register a correct prediction. Future evaluation plans include implementing **Hamming Loss** to better capture partial correctness in multi-label scenarios. 
* **Thresholding Logic:** The `predict_proba()` method is utilized to rank the top 5 highest-probability exercise matches to maintain UI consistency on the frontend, ensuring the user always receives exactly 5 tailored options regardless of confidence bounds.

### 7.4 Screenshots / Code Snippets (where appropriate)
*(Placeholder for screenshots of the Home Screen, Chatbot Prototype, Journal, and Data visualizations)*

### 7.5 Current System Limitations & Challenges
* **API Deployment:** The FastAPI recommendation backend is currently running locally (`127.0.0.1` / `10.0.2.2`). This requires active local server hosting during development and creates temporary networking challenges.
* **State Management:** The current implementation uses native Flutter `setState` management. While efficient for the prototype, scalable state architecture (e.g., Provider or Riverpod) is planned for future versions.
* **Chatbot Integration:** The chatbot prototype is currently a stateless UI mock without natural language processing capabilities.
* **API Resilience:** The ML API backend currently lacks comprehensive input validation parameters and formal Python request/error `logging` loops.

## Chapter 08 Discussion [Max of 1 Page] 
### Overview of the Interim Report 
This report details the mid-point progress of the Mindhug application, a cross-platform mobile mental health solution. It outlines the foundational architecture, technology stack, security implementations, and functional modules completed to date.

### Summary of the Report 
We have successfully established the core application framework using Flutter and integrated it smoothly with Firebase. We accomplished strict security models using Firestore rules and CI/CD pipelines via GitHub actions. A major milestone achieved is the custom Python ML backend utilizing Random Forest to deliver personalized activity recommendations, demonstrating a strong technical base that degrades gracefully to local rules when offline.

### Upcoming Testing Strategies
To ensure robustness prior to final submission, manual edge-case testing is underway. Key impending test cases include:
| Feature | Test Case | Expected Result |
|---|---|---|
| ML API Resilience | Simulate network timeout during fetch | App silently falls back to `_getLocalRules` recommendations |
| Form Validation | Attempt submission of empty journal entry | UI prevents submission and displays emotional safety error text |
| ML Extremes | Dispatch `level=0` & `mood=0` to API | Model strictly prioritizes calming grounding/breathing exercises |

### Future Plans & Improvements 
Our immediate next steps represent significant leaps in maturity:
1. **Cloud Deployment:** We plan to deploy the FastAPI on a cloud provider (e.g., Railway/Render) and shift the Flutter endpoint URL to dynamic environment variables.
2. **Backend Hardening:** Implementing strict Pydantic input validation ranges (0-3, 0-4) and detailed system logging in the Python API.
3. **Conversational Intelligence:** Upgrading the chatbot prototype; integrating backend conversational intelligence (NLP or rule-based models) to replace the current stateless UI mock.
4. **UX & Feedback Loops:** Expanding emotionally-safe copywriting, adding explicit "Recommended because you selected X" explainability logic, and inserting a post-exercise feedback prompt ("Did this help?") to allow for future real-user data retraining and improved dataset realism.

## References 
* Flutter Documentation: https://docs.flutter.dev/
* Firebase Documentation: https://firebase.google.com/docs
* scikit-learn Documentation: https://scikit-learn.org/stable/
* FastAPI Documentation: https://fastapi.tiangolo.com/
