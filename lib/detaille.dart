import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'modifier.dart';

class DetailleScreen extends StatelessWidget {
  final DocumentSnapshot task;

  const DetailleScreen({super.key, required this.task});

  /// Fonction pour mettre à jour le statut de la tâche
  void _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('taches').doc(task.id).update({
        'statut': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Statut mis à jour en \"$newStatus\"."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la mise à jour du statut: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Tâche'),
        backgroundColor: const Color(0xFF491B6D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la tâche
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['titre'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task['categorie'],
                    style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Description : ${task['description']}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text("${task['heure_debut']} - ${task['heure_fin']}"),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: task['statut'] == "Non débutée"
                              ? Colors.red
                              : task['statut'] == "En cours"
                                  ? Colors.orange
                                  : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task['statut'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Boutons pour changer le statut
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateStatus(context, "Non débutée"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Non débutée"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateStatus(context, "En cours"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("En cours"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateStatus(context, "Terminée"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Terminée"),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton pour modifier la tâche
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ModifierScreen(task: task)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF491B6D)),
                child: const Text("Modifier", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
