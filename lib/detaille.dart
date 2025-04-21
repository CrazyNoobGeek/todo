import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final String? lienOrLocation = task['lien_reunion'] as String?;
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
                  // Description scrollable zone
                  Container(
                    constraints: const BoxConstraints(maxHeight: 40), // ~2 lines
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          "Description : "+(task['description'] ?? ''),
                          maxLines: null, // allow as many as needed in scroll
                          overflow: TextOverflow.visible,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (lienOrLocation != null && lienOrLocation.isNotEmpty)
                    InkWell(
                      onTap: () async {
                        if (_isLocation(lienOrLocation)) {
                          final Uri mapUri = _getMapUri(lienOrLocation);
                          if (await canLaunchUrl(mapUri)) {
                            await launchUrl(mapUri);
                          }
                        } else if (await canLaunchUrl(Uri.parse(lienOrLocation))) {
                          await launchUrl(Uri.parse(lienOrLocation), mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(_isLocation(lienOrLocation) ? Icons.location_on : Icons.link, color: Colors.blue),
                          const SizedBox(width: 8),
                          Flexible(child: Text(lienOrLocation, style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
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

  // Helper to check if the string is a location (coordinates or address)
  bool _isLocation(String value) {
    // Simple check: if value contains a comma and both parts are numbers, treat as coordinates
    final parts = value.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) return true;
    }
    // Or if it looks like an address (contains street/locality/country keywords)
    if (value.contains('Rue') || value.contains('Street') || value.contains('Avenue') || value.contains('Blvd') || value.contains('Algiers') || value.contains('Paris')) {
      return true;
    }
    return false;
  }

  // Helper to create a Google Maps URI from a location string
  Uri _getMapUri(String value) {
    final parts = value.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        return Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      }
    }
    // Otherwise, treat as address
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(value)}');
  }
}
