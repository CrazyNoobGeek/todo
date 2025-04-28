Functional Specifications
========================

List of proposed features:
- [x] Authentication (login, registration, password reset)
- [x] Task management (add, edit, delete, status)
- [x] Meeting management (create, edit, delete, meeting link)
- [x] Local notifications for task/meeting reminders
- [x] Voice input for tasks
- [x] Intuitive and responsive user interface

Mockups
=======

The application mockups are available on Figma:
[View mockups on Figma](https://www.figma.com/design/pF8dQTA9ifVstFuKPWybYX/mokup-master-class-app?node-id=63-43&t=Ay4UaBGkwxhauJbT-0)

Or see below for a global overview of the main screens:

![Mockup Overview](docs/mockup_apercu.png)

(The mockups detail the login, registration, task list, add task, add meeting, and calendar screens.)

MVC Modeling
============

- Model:
  - User (uid, name, email)
  - Task (id, title, description, category, start/end date/time, status)
  - Meeting (id, title, description, meeting_link, date, start/end time)
- View:
  - Screens: Login, Registration, Task list, Task detail, Add/Edit, Meeting list, Notifications
- Controller:
  - Navigation management, Firebase calls, CRUD management, notifications, form validation

Technical Choices
================

- Language: Dart
- Framework/API: Flutter, Firebase (Auth, Firestore)
- Database: Cloud Firestore (NoSQL)
- Other tools/libraries: flutter_local_notifications, speech_to_text, intl

Java Class Diagram
==================

(The project being in Dart/Flutter, a UML class diagram can be provided for the main entities. Example: User, Task, Meeting.)

Architecture
============

- Architecture based on the MVC model adapted to Flutter (Widgets = View, Providers/Controllers = Controller, Dart Models = Model)
- Use of Firebase for data management and authentication
- Local notifications integrated via flutter_local_notifications

User Story
==========

- As a user, I want to create an account to access my personal space.
- As a user, I want to add/edit/delete tasks to organize my work.
- As a user, I want to receive notifications so I don't forget my tasks or meetings.
- As a user, I want to input my tasks by voice to go faster.
- As a user, I want to organize and consult my meetings with a link or associated address.

User Manual Summary
==================

1. Open the application and log in or create an account.
2. Access the task or meeting list.
3. Add, edit or delete a task/meeting via the dedicated buttons.
4. Receive notifications at the scheduled time.
5. Use voice input to quickly create a task.

Problems Encountered
====================

- Integration of voice input sometimes unstable on certain devices.
- Management of notification permissions depending on the Android version.
- Real-time synchronization with Firestore (possible network latency).

Conclusion
==========

The Todo Master Mobile Project offers a complete solution for task and meeting management, integrating secure authentication, notifications, and voice input. The prospects for improvement include adding themes, multi-device synchronization, and integrating a visual calendar.
