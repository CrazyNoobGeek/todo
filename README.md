# Todo Master Mobile Project

## Requirements & Environment

To install and run this project, you need the following environment:

- **Operating System:** Windows, macOS, or Linux
- **Flutter SDK:** Version 3.0.0 or higher (recommended: latest stable)
  - Download from: https://docs.flutter.dev/get-started/install
- **Dart SDK:** Included with Flutter (no separate installation needed)
- **Android Studio** (or VS Code with Flutter extension) for development and Android emulation
- **Android SDK:** Version 33 (Android 13) or higher recommended
- **Java Development Kit (JDK):** Version 11 or higher (JDK 17 recommended)
- **Firebase account:** Access to Firebase Console to configure authentication and Firestore
- **Internet connection:** Required for dependency installation and Firebase access

> Make sure to add Flutter and Dart to your system PATH for command-line usage.

## Overview

Todo Master is a Flutter mobile application for managing tasks and meetings, integrating Firebase authentication (login, registration, password reset) and user management with Firestore. The app offers a modern and smooth experience, suitable for professional or personal use.

## Main Features

- **Firebase Authentication:**
  - Secure registration and login via email/password.
  - Password reset by email (link sent, no code required).
- **User Management:**
  - User information is stored in Firestore, linked to the Firebase UID.
- **Task Management:**
  - Create, edit, and delete tasks.
  - Task status (Not started, In progress, Completed).
  - View, edit, and delete tasks.
- **Meeting Management:**
  - Create, edit, and delete meetings.
  - Add location or link (Google Meet, etc.).
  - View, edit, and delete meetings.
- **Notifications:**
  - Manage and display notifications.
- **User Interface:**
  - Modern UI with purple and white themes, optimized contrasts.
  - Main titles and texts in white for better readability.
  - Dark mode support.
- **Accessibility:**
  - Voice input (speech-to-text) support for text fields.
  - Integrated date, time, and location pickers.

## API Architecture

The Todo Master application uses Firebase as the main backend for managing users, tasks, meetings, and notifications. Here is the general interaction scheme:

- **Authentication:**
  - Firebase Auth (Email/Password)
  - Main endpoints:
    - `signUp(email, password)`
    - `signIn(email, password)`
    - `sendPasswordResetEmail(email)`
- **User Management:**
  - Firestore (collection `users`)
  - Create and retrieve user profiles linked to the Firebase UID.
- **Task Management:**
  - Firestore (collection `taches`)
  - CRUD via Firestore methods:
    - `add`: Add a task
    - `get`: Retrieve tasks
    - `update`: Edit a task
    - `delete`: Delete a task
- **Meeting Management:**
  - Firestore (collection `reunions`)
  - CRUD similar to tasks, with additional location/link info.
- **Notifications:**
  - Local: `flutter_local_notifications` plugin
  - Remote (optional): via Firebase Cloud Messaging (not enabled by default)

**General Flow:**
1. The user authenticates via Firebase Auth.
2. Data (tasks, meetings, profile) is stored and retrieved from Firestore, filtered by user UID.
3. Notifications are scheduled locally on the Android device.

## Technology Choices Justification

- **Flutter:**
  - Enables rapid development, modern UI, and high customization.
  - Large ecosystem of packages for advanced features (notifications, speech-to-text, etc).
  - High-performance native Android support.
- **Firebase:**
  - Secure and easy-to-integrate authentication.
  - Firestore: real-time database, suitable for collaborative task and meeting management.
  - Easy notification integration via Firebase and Flutter plugins.
- **Additional Packages:**
  - `flutter_local_notifications` for local reminders.
  - `speech_to_text` for accessibility and voice input.

> This stack choice enables a robust, secure, and scalable Android application, while accelerating development and maintenance.

## Installation & Configuration

1. **Prerequisites**
   - Flutter SDK (3.x recommended)
   - Firebase account and configured project

2. **Clone the project**
   ```bash
   git clone <repo-url>
   cd todo-master_mobile_project
   ```

3. **Configure Firebase**
   - Download `google-services.json` from the Firebase console and place it in `android/app/`.
   - Ensure the app package name matches the one declared in Firebase (`com.example.todo` by default).
   - Enable Email/Password authentication in the Firebase Console.

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

- `lib/`
  - `main.dart`: Application entry point
  - `connexion.dart`: Login screen
  - `register.dart`: Registration screen
  - `compte.dart`: User account management
  - `tache.dart`, `reunion.dart`: Task and meeting management
  - `modifier.dart`, `modifier_reunion.dart`: Task/meeting editing
  - `detaille.dart`: Task or meeting details
  - `notifications.dart`: Notifications
  - `notification_helper.dart`: Notification utilities
- `android/app/google-services.json`: Firebase configuration

## Best Practices & Tips

- **Security:** Passwords are never stored in Firestore, only managed by Firebase Auth.
- **Password Reset:** After clicking "Change Password", check your email and follow the link sent by Firebase.
- **UI/UX:** All important titles and texts are in white for better visibility on a purple background.

## Main Dependencies

- `firebase_auth`
- `cloud_firestore`
- `flutter_local_notifications`
- `speech_to_text`
- `intl`

## Authors
- Project developed by Yahya BAHLOUL.

## License
This project is open-source and licensed under the MIT license.
