# Technical Documentation – Todo Master Mobile Project

## Table of Contents
1. [General Architecture](#general-architecture)
2. [Dependencies & Configuration](#dependencies--configuration)
3. [Firebase Authentication Management](#firebase-authentication-management)
4. [User Management (Firestore)](#user-management-firestore)
5. [Task Management](#task-management)
6. [Meeting Management](#meeting-management)
7. [Local Notifications](#local-notifications)
8. [File Structure](#file-structure)
9. [Main Widgets/Screens](#main-widgets-screens)
10. [Best Practices & Security](#best-practices--security)

---

## 1. General Architecture

- **Flutter** (Dart): Widget-based architecture.
- **Firebase:**
  - Authentication (Firebase Auth)
  - NoSQL Database (Cloud Firestore)
- **Local notifications:** `flutter_local_notifications`

Main flow:
- The user authenticates (Firebase Auth)
- User info is retrieved/saved in Firestore
- The user manages tasks and meetings (CRUD)
- Notifications are scheduled for reminders

---

## 2. Dependencies & Configuration

- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `flutter_local_notifications`: Notifications
- `speech_to_text`: Voice input
- `intl`: Date/time formats

**Firebase Configuration:**
- Place `google-services.json` in `android/app/`
- Verify the package name in Firebase Console
- Enable Email/Password in Auth

---

## 3. Firebase Authentication Management

- **Login:**
  - `FirebaseAuth.instance.signInWithEmailAndPassword(email, password)`
- **Registration:**
  - `FirebaseAuth.instance.createUserWithEmailAndPassword(email, password)`
  - Add user info to Firestore (`user/{uid}`)
- **Logout:**
  - `FirebaseAuth.instance.signOut()`
- **Password Reset:**
  - `FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail)`
  - Link sent by email, no code to enter in the app

---

## 4. User Management (Firestore)

- Collection: `user`
- Document: Firebase UID
- Fields: `name`, `email`, etc.
- Access:
  - Retrieval: `FirebaseFirestore.instance.collection('user').doc(uid).get()`
  - Update: `.update({...})`

---

## 5. Task Management

- Collection: `tasks`
- Fields: `title`, `description`, `category`, `start_date`, `start_time`, `end_date`, `end_time`, `status`
- CRUD:
  - Creation: `.add({...})`
  - Read: `.snapshots()` or `.get()`
  - Update: `.doc(id).update({...})`
  - Deletion: `.doc(id).delete()`
- Status: `Not started`, `In progress`, `Completed`

---

## 6. Meeting Management

- Collection: `meetings`
- Fields: `title`, `description`, `meeting_link`, `date`, `start_time`, `end_time`
- CRUD identical to tasks
- Link or location: `meeting_link` field (URL or address)

---

## 7. Local Notifications

- Uses `flutter_local_notifications`
- Scheduling notifications for task/meeting reminders
- Main file: `notification_helper.dart`
- Example:
```dart
await NotificationHelper.showNotification(
  title: 'Title',
  body: 'Notification body',
  scheduledDate: DateTime(...),
);
```

---

## 8. File Structure

- `lib/`
  - `main.dart`: Bootstrap, navigation
  - `login.dart`: Authentication
  - `register.dart`: Registration
  - `account.dart`: User account
  - `task.dart` / `meeting.dart`: CRUD tasks/meetings
  - `edit.dart` / `edit_meeting.dart`: Editing
  - `detail.dart`: Task/meeting details
  - `notifications.dart`: Notification display
  - `notification_helper.dart`: Notification helper

---

## 9. Main Widgets/Screens

- **Login/Register:** Forms, validation, navigation
- **Account:** User info display, reset password button
- **Tasks/Meetings:** Lists, details, editing, deletion
- **Detail:** Detailed view, quick actions (edit, status)
- **Add/Edit:** Forms with date/time pickers, voice input

---

## 10. Best Practices & Security

- **Never store passwords in plain text**
- **Use Firebase UIDs as primary keys for users**
- **Verify email validity before sending reset**
- **UI: prioritize contrast (white text on purple background)**
- **Use try/catch for all Firestore/Firebase operations**

---

## Contact
For any technical questions, contact Yahya BAHLOUL.
bahloulyahya7@gmail.com
