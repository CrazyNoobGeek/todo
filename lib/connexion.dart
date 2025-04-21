import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'register.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  _ConnexionScreenState createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  // Contrôleurs pour capturer les entrées utilisateur dans les champs de texte
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Fonction pour afficher un message (succès ou erreur) dans une boîte de dialogue
  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title), // Titre de la boîte de dialogue
          content: Text(message), // Message affiché dans la boîte de dialogue
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Ferme la boîte de dialogue
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// Fonction de validation des entrées utilisateur
  bool _validateInputs() {
    // Récupère et nettoie les valeurs des champs de texte
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Vérifie si les champs sont vides
    if (email.isEmpty || password.isEmpty) {
      _showMessageDialog("Erreur", "Veuillez remplir tous les champs.");
      return false;
    }

    // Vérifie le format de l'adresse email avec une expression régulière
    String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp emailRegex = RegExp(emailPattern);
    if (!emailRegex.hasMatch(email)) {
      _showMessageDialog("Erreur", "Veuillez entrer une adresse email valide.");
      return false;
    }

    return true; // Les entrées sont valides
  }

  /// Fonction pour vérifier les informations de connexion dans Firestore
  Future<void> _loginUser() async {
    if (!_validateInputs()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Utilise Firebase Auth pour la connexion
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _showMessageDialog("Succès", "Connexion réussie !");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Aucun utilisateur trouvé pour cet email.";
          break;
        case 'wrong-password':
          errorMessage = "Mot de passe incorrect.";
          break;
        default:
          errorMessage = "Erreur : ${e.message}";
      }
      _showMessageDialog("Erreur", errorMessage);
    } catch (e) {
      _showMessageDialog("Erreur", "Une erreur est survenue : ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Définit le fond en blanc
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Ajoute un espace horizontal
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Centre les éléments horizontalement
              children: [
                // Logo de l'application
                const SizedBox(height: 50),
                Image.asset('assets/images/logo.png', width: 200),
                const SizedBox(height: 30),

                // Champ de texte pour l'adresse email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Adresse Email",
                    style: TextStyle(color: Color(0xFF491B6D), fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _emailController, // Lie le contrôleur au champ de texte
                  decoration: InputDecoration(
                    hintText: "Entrez votre email", // Texte indicatif
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF491B6D)), // Icône à gauche
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Bords arrondis
                      borderSide: const BorderSide(color: Color(0xFF491B6D)), // Couleur de la bordure
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Champ de texte pour le mot de passe
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Mot de passe",
                    style: TextStyle(color: Color(0xFF491B6D), fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _passwordController, // Lie le contrôleur au champ de texte
                  obscureText: true, // Cache le texte pour la saisie de mots de passe
                  decoration: InputDecoration(
                    hintText: "***************", // Texte indicatif
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF491B6D)), // Icône à gauche
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Bords arrondis
                      borderSide: const BorderSide(color: Color(0xFF491B6D)), // Couleur de la bordure
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lien "Mot de passe oublié"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, // Action à définir pour la réinitialisation du mot de passe
                    child: const Text("Mot de passe oublié?", style: TextStyle(color: Color(0xFF491B6D))),
                  ),
                ),
                const SizedBox(height: 10),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity, // Le bouton occupe toute la largeur disponible
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loginUser, // Action déclenchée lors du clic sur le bouton
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF491B6D), // Couleur de fond
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Forme arrondie
                      ),
                    ),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(color: Colors.white, fontSize: 16), // Style du texte
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lien pour accéder à la page d'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments horizontalement
                  children: [
                    const Text("Pas de compte ? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Inscrivez-vous",
                        style: TextStyle(color: Color(0xFF491B6D), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
