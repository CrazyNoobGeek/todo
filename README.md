# Todo Master Mobile Project

## Présentation

Todo Master est une application mobile Flutter de gestion de tâches et de réunions, intégrant l’authentification Firebase (login, inscription, réinitialisation du mot de passe) et la gestion des utilisateurs avec Firestore. L’application offre une expérience moderne et fluide, adaptée à une utilisation professionnelle ou personnelle.

## Fonctionnalités principales

- **Authentification Firebase** :
  - Inscription et connexion sécurisées via email/mot de passe.
  - Réinitialisation du mot de passe par email (lien envoyé, pas de code requis).
- **Gestion des utilisateurs** :
  - Les informations utilisateurs sont stockées dans Firestore, liées à l’UID Firebase.
- **Gestion des tâches** :
  - Création, modification, suppression de tâches.
  - Statut de tâche (Non débutée, En cours, Terminée).
  - Détail, édition et suppression des tâches.
- **Gestion des réunions** :
  - Création, modification, suppression de réunions.
  - Ajout de lieu ou de lien (Google Meet, etc.).
  - Détail, édition et suppression des réunions.
- **Notifications** :
  - Gestion et affichage des notifications.
- **Interface utilisateur** :
  - UI moderne avec thèmes violet et blanc, contrastes optimisés.
  - Titres et textes principaux en blanc pour une meilleure lisibilité.
  - Prise en charge du mode sombre.
- **Accessibilité** :
  - Support de la saisie vocale (speech-to-text) pour les champs de texte.
  - Sélecteurs de date, heure et lieu intégrés.

## Installation & Configuration

1. **Prérequis**
   - Flutter SDK (3.x recommandé)
   - Compte Firebase et projet configuré

2. **Cloner le projet**
   ```bash
   git clone <repo-url>
   cd todo-master_mobile_project
   ```

3. **Configurer Firebase**
   - Télécharger `google-services.json` depuis la console Firebase et le placer dans `android/app/`.
   - Vérifier que le package name de l’app correspond à celui déclaré dans Firebase (`com.example.todo` par défaut).
   - Activer l’authentification Email/Password dans Firebase Console.

4. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

5. **Lancer l’application**
   ```bash
   flutter run
   ```

## Structure du projet

- `lib/`
  - `main.dart` : Point d’entrée de l’application
  - `connexion.dart` : Écran de connexion
  - `register.dart` : Écran d’inscription
  - `compte.dart` : Gestion du compte utilisateur
  - `tache.dart`, `reunion.dart` : Gestion des tâches et réunions
  - `modifier.dart`, `modifier_reunion.dart` : Édition des tâches/réunions
  - `detaille.dart` : Détail d’une tâche ou réunion
  - `notifications.dart` : Notifications
  - `notification_helper.dart` : Utilitaires de notifications
- `android/app/google-services.json` : Configuration Firebase

## Bonnes pratiques & conseils

- **Sécurité** : Les mots de passe ne sont jamais stockés dans Firestore, uniquement gérés par Firebase Auth.
- **Réinitialisation du mot de passe** : Après avoir cliqué sur "Changer le mot de passe", vérifiez votre email et suivez le lien envoyé par Firebase.
- **UI/UX** : Tous les titres et textes importants sont en blanc pour une meilleure visibilité sur fond violet.

## Dépendances principales

- `firebase_auth`
- `cloud_firestore`
- `flutter_local_notifications`
- `speech_to_text`
- `intl`

## Auteurs
- Projet développé par [Votre Nom ou Équipe].

## Licence
Ce projet est open-source et sous licence MIT.
