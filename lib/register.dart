import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'connexion.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Fonction pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erreur"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// Fonction de validation des champs
  bool _validateInputs() {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Vérifier si les champs sont vides
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog("Veuillez remplir tous les champs.");
      return false;
    }

    // Vérification du format de l'email
    String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp emailRegex = RegExp(emailPattern);
    if (!emailRegex.hasMatch(email)) {
      _showErrorDialog("Veuillez entrer une adresse email valide.");
      return false;
    }

    // Vérification que le nom contient uniquement des lettres alphabétiques
    String namePattern = r'^[a-zA-Z\s]+$';
    RegExp nameRegex = RegExp(namePattern);
    if (!nameRegex.hasMatch(name)) {
      _showErrorDialog("Le nom ne doit contenir que des lettres alphabétiques.");
      return false;
    }

    return true;
  }

  /// Fonction pour enregistrer les données dans Firestore
  Future<void> _registerUser() async {
    if (!_validateInputs()) {
      return;
    }

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      
      print("Nom: $name, Email: $email");

      // Enregistrer les données de l'utilisateur dans Firestore
      var result = await FirebaseFirestore.instance.collection('utilisateur').add({
        'nom': name,
        'email': email,
        'motdepasse': password,
      });

      print("Utilisateur enregistré avec ID : ${result.id}");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Succès"),
            content: const Text("Inscription réussie !"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'permission-denied':
          errorMessage = "Permission refusée. Vérifiez les règles Firestore.";
          break;
        case 'unavailable':
          errorMessage = "Service Firestore indisponible. Vérifiez votre connexion Internet.";
          break;
        case 'not-found':
          errorMessage = "Collection Firestore non trouvée.";
          break;
        case 'aborted':
          errorMessage = "L'opération a été annulée.";
          break;
        case 'deadline-exceeded':
          errorMessage = "Délai d'attente dépassé. Veuillez réessayer.";
          break;
        default:
          errorMessage = "Erreur Firestore inconnue : ${e.message}";
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog("Erreur inattendue : ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/images/logo.png', width: 200),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nom Complet",
                    style: TextStyle(color: Color(0xFF491B6D), fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Entrez votre nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF491B6D)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Adresse Email",
                    style: TextStyle(color: Color(0xFF491B6D), fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Entrez votre email",
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF491B6D)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF491B6D)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Mot de passe",
                    style: TextStyle(color: Color(0xFF491B6D), fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "***************",
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF491B6D)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF491B6D)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF491B6D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                   Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Vous avez déjà un compte ? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConnexionScreen()),
                        );
                      },
                      child: const Text(
                        "Connectez-vous",
                        style: TextStyle(color: Color(0xFF491B6D), fontWeight: FontWeight.bold),
                      ),
                    )
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
