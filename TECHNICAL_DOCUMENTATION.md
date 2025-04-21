# Documentation Technique – Todo Master Mobile Project

## Table des matières
1. [Architecture générale](#architecture-générale)
2. [Dépendances et configuration](#dépendances-et-configuration)
3. [Gestion de l’authentification Firebase](#gestion-de-lauthentification-firebase)
4. [Gestion des utilisateurs (Firestore)](#gestion-des-utilisateurs-firestore)
5. [Gestion des tâches](#gestion-des-tâches)
6. [Gestion des réunions](#gestion-des-réunions)
7. [Notifications locales](#notifications-locales)
8. [Structure des fichiers](#structure-des-fichiers)
9. [Principaux Widgets/Screens](#principaux-widgets-screens)
10. [Bonnes pratiques & sécurité](#bonnes-pratiques--sécurité)

---

## 1. Architecture générale

- **Flutter** (Dart) : architecture basée sur des Widgets.
- **Firebase** :
  - Authentification (Firebase Auth)
  - Base de données NoSQL (Cloud Firestore)
- **Notifications locales** : `flutter_local_notifications`

Flux principal :
- L’utilisateur s’authentifie (Firebase Auth)
- Les infos utilisateur sont récupérées/sauvegardées dans Firestore
- L’utilisateur gère ses tâches et réunions (CRUD)
- Notifications programmées pour rappels

---

## 2. Dépendances et configuration

- `firebase_auth` : Authentification
- `cloud_firestore` : Base de données
- `flutter_local_notifications` : Notifications
- `speech_to_text` : Saisie vocale
- `intl` : Formats date/heure

**Configuration Firebase** :
- Placer `google-services.json` dans `android/app/`
- Vérifier le package name dans Firebase Console
- Activer Email/Password dans Auth

---

## 3. Gestion de l’authentification Firebase

- **Connexion** :
  - `FirebaseAuth.instance.signInWithEmailAndPassword(email, password)`
- **Inscription** :
  - `FirebaseAuth.instance.createUserWithEmailAndPassword(email, password)`
  - Ajout des infos utilisateur dans Firestore (`utilisateur/{uid}`)
- **Déconnexion** :
  - `FirebaseAuth.instance.signOut()`
- **Réinitialisation du mot de passe** :
  - `FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail)`
  - Lien envoyé par email, pas de code à saisir dans l’app

---

## 4. Gestion des utilisateurs (Firestore)

- Collection : `utilisateur`
- Document : UID Firebase
- Champs : `nom`, `email`, etc.
- Accès :
  - Récupération : `FirebaseFirestore.instance.collection('utilisateur').doc(uid).get()`
  - Mise à jour : `.update({...})`

---

## 5. Gestion des tâches

- Collection : `taches`
- Champs : `titre`, `description`, `categorie`, `date_debut`, `heure_debut`, `date_fin`, `heure_fin`, `statut`
- CRUD :
  - Création : `.add({...})`
  - Lecture : `.snapshots()` ou `.get()`
  - Mise à jour : `.doc(id).update({...})`
  - Suppression : `.doc(id).delete()`
- Statuts : `Non débutée`, `En cours`, `Terminée`

---

## 6. Gestion des réunions

- Collection : `reunions`
- Champs : `titre`, `description`, `lien_reunion`, `date`, `heure_debut`, `heure_fin`
- CRUD identique aux tâches
- Lien ou lieu : champ `lien_reunion` (URL ou adresse)

---

## 7. Notifications locales

- Utilise `flutter_local_notifications`
- Planification de notifications pour rappels de tâches/réunions
- Fichier principal : `notification_helper.dart`
- Exemple :
```dart
await NotificationHelper.showNotification(
  title: 'Titre',
  body: 'Corps de la notification',
  scheduledDate: DateTime(...),
);
```

---

## 8. Structure des fichiers

- `lib/`
  - `main.dart` : Bootstrap, navigation
  - `connexion.dart` : Authentification
  - `register.dart` : Inscription
  - `compte.dart` : Compte utilisateur
  - `tache.dart` / `reunion.dart` : CRUD tâches/réunions
  - `modifier.dart` / `modifier_reunion.dart` : Édition
  - `detaille.dart` : Détail tâche/réunion
  - `notifications.dart` : Affichage notifications
  - `notification_helper.dart` : Logiciel notifications

---

## 9. Principaux Widgets/Screens

- **Connexion/Register** : Formulaires, validation, navigation
- **Compte** : Affichage infos, bouton reset password
- **Tâches/Réunions** : Listes, détails, édition, suppression
- **Détail** : Vue détaillée, actions rapides (modifier, statut)
- **Ajout/Modification** : Formulaires avec sélecteurs date/heure, saisie vocale

---

## 10. Bonnes pratiques & sécurité

- **Jamais stocker de mot de passe en clair**
- **Utiliser les UID Firebase comme clé primaire pour les utilisateurs**
- **Vérifier la validité des emails avant envoi de reset**
- **UI : privilégier le contraste (titres/textes en blanc sur fond violet)**
- **Utiliser des try/catch pour toutes opérations Firestore/Firebase**

---

## Contact
Pour toute question technique, contacter Yahya BAHLOUL.
