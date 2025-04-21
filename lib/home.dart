import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'choix.dart';
import 'modifier_reunion.dart';
import 'detaille.dart';
import 'calander.dart';
import 'connexion.dart';
import 'compte.dart';
import 'notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _currentDate; 
  late String _formattedDate; 
  late String _currentTime; 

  int _notifCount = 0;

  @override
  void initState() {
    super.initState();
    _updateDateTime(); 
    _listenNotifCount();
  }

  void _listenNotifCount() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('timestamp', isGreaterThan: Timestamp.now())
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _notifCount = snapshot.docs.length;
      });
    });
  }

  void _updateDateTime() {
    DateTime now = DateTime.now();
    _currentDate = DateFormat('MMM dd, yyyy').format(now); 
    _formattedDate = DateFormat('yyyy-MM-dd').format(now);
    _currentTime = DateFormat('hh:mm a').format(now);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('hh:mm a').format(DateTime.now()); 
        });
        _updateDateTime(); 
      }
    });
  }

  
  Widget _buildEventCard({
    required String title, 
    required String subtitle, 
    required String time, 
    required Color bgColor, 
    required String status,
    required Color statusColor, 
    required VoidCallback onTap, 
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Ombre légère
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black54, size: 16), // Icône d'heure
                const SizedBox(width: 5),
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CompteScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChoixScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF491B6D),
        title: const Text('Accueil', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Déconnexion',
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              // Navigate to login/register screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ConnexionScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
         
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF491B6D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _currentDate, 
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentTime, 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

          
              const Row(
                children: [
                  Icon(Icons.notifications, color: Colors.black), // Icône de notification
                  SizedBox(width: 8),
                  Text("Réunion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),

              _buildReunionList(), 

              const SizedBox(height: 20),

           
              const Row(
                children: [
                  Icon(Icons.checklist, color: Colors.black), // Icône de checklist
                  SizedBox(width: 8),
                  Text("To Do Liste", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),

              _buildTacheList(), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, 
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF491B6D),
        unselectedItemColor: Colors.black54, 
        elevation: 10,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home ), label: ""), 
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ""), 
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40), label: ""), 
          const BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""), // Calendrier
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_notifCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notifCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "",
          ),
        ],
      ),
    );
  }


  Widget _buildReunionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reunions') 
          .where('date', isEqualTo: _formattedDate) 
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("Aucune réunion aujourd'hui.", style: TextStyle(color: Colors.black54)),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            return _buildEventCard(
              title: doc['titre'], 
              subtitle: doc['lien_reunion'],
              time: "${doc['heure_debut']} - ${doc['heure_fin']}", 
              bgColor: Colors.amber.shade200, 
              status: doc['statut'],
              statusColor: Colors.red, 
              onTap: () {
                print(doc.data());
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailleScreen(meeting: doc)),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// Fonction pour afficher la liste des tâches du jour
  Widget _buildTacheList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('taches') // Accède à la collection "taches" dans Firestore
          .where('date_debut', isEqualTo: _formattedDate) // Filtre par date actuelle
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("Aucune tâche aujourd'hui.", style: TextStyle(color: Colors.black54)),
          );
        }

        // Crée une carte pour chaque tâche
        return Column(
          children: snapshot.data!.docs.map((doc) {
            return _buildEventCard(
              title: doc['titre'], 
              subtitle: doc['categorie'],
              time: "${doc['heure_debut']} - ${doc['heure_fin']}", 
              bgColor: Colors.grey.shade300, 
              status: doc['statut'], 
              statusColor: Colors.orange, // Couleur du statut
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailleScreen(task: doc)),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
