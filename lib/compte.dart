import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompteScreen extends StatefulWidget {
  const CompteScreen({Key? key}) : super(key: key);

  @override
  State<CompteScreen> createState() => _CompteScreenState();
}

class _CompteScreenState extends State<CompteScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userInfo;
  bool loading = true;

  void _changePassword() async {
    if (user != null && user!.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Réinitialisation du mot de passe', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF491B6D),
          content: const Text(
            'Un lien de réinitialisation a été envoyé à votre adresse email. Veuillez suivre ce lien pour changer votre mot de passe.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      print("Fetching user info for: "+(user?.uid ?? 'null'));
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('utilisateur')
            .doc(user!.uid)
            .get();
        if (doc.exists) {
          setState(() {
            userInfo = doc.data();
            loading = false;
          });
          print("User info loaded: $userInfo");
        } else {
          setState(() {
            userInfo = null;
            loading = false;
          });
          print("No user info found for UID: ${user!.uid}");
        }
      } else {
        setState(() {
          userInfo = null;
          loading = false;
        });
        print("User is null");
      }
    } catch (e, stack) {
      setState(() {
        userInfo = null;
        loading = false;
      });
      print("Error fetching user info: $e");
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mon Compte', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF491B6D),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
        backgroundColor: const Color(0xFF491B6D),
      );
    }
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mon Compte', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF491B6D),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Utilisateur non connecté.', style: TextStyle(color: Colors.white))),
        backgroundColor: const Color(0xFF491B6D),
      );
    }
    if (userInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mon Compte', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF491B6D),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Aucune information utilisateur trouvée.', style: TextStyle(color: Colors.white))),
        backgroundColor: const Color(0xFF491B6D),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF491B6D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF491B6D),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    userInfo!["nom"] != null && userInfo!["nom"].isNotEmpty
                        ? userInfo!["nom"][0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userInfo!["nom"] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user!.email ?? '', style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text("Mot de passe :", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_reset, color: Colors.white),
              label: const Text('Changer le mot de passe', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            const Text(
              "Après avoir cliqué sur 'Changer le mot de passe', vérifiez votre email et suivez le lien pour réinitialiser votre mot de passe.",
              style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
