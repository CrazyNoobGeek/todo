import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'modifier.dart';
import 'modifier_reunion.dart';

class DetailleScreen extends StatelessWidget {
  final DocumentSnapshot? meeting;
  final DocumentSnapshot? task;

  const DetailleScreen({super.key, this.meeting, this.task});

  void _updateStatus(BuildContext context, String newStatus) async {
    if (task == null) return;
    try {
      await FirebaseFirestore.instance.collection('taches').doc(task!.id).update({
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

  Widget _buildStatusButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _updateStatus(context, 'Non débutée'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Non débutée'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _updateStatus(context, 'En cours'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('En cours'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _updateStatus(context, 'Terminée'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Terminée'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModifierScreen(task: task!),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Modifier'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (meeting == null && task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails'), style: TextStyle(color: Colors.white)), 
        body: const Center(child: Text('Aucune donnée à afficher.')),
      );
    }
    final dynamic data = meeting ?? task;
    final bool isMeeting = meeting != null;
    final String title = data['titre'] ?? 'Non renseigné';
    final String? lienOrLocation = isMeeting ? data['lien_reunion'] as String? : null;
    final String description = data['description'] ?? 'Non renseigné';
    final String heureDebut = data['heure_debut'] ?? 'Non renseigné';
    final String heureFin = data['heure_fin'] ?? 'Non renseigné';
    final String statut = data['statut'] ?? 'Non renseigné';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(isMeeting ? 'Détails Réunion' : 'Détails Tâche'),
        backgroundColor: const Color(0xFF491B6D),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => isMeeting
                      ? ModifierReunionScreen(reunion: meeting!)
                      : ModifierScreen(task: task!),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(isMeeting ? Icons.groups : Icons.task, color: Color(0xFF491B6D)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text('$heureDebut - $heureFin', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isMeeting && lienOrLocation != null && lienOrLocation.isNotEmpty)
                        Builder(
                          builder: (context) {
                            // Parse the stored value: 'address|lat,lng' or just address
                            String displayText = lienOrLocation;
                            String? coords;
                            if (lienOrLocation.contains('|')) {
                              final parts = lienOrLocation.split('|');
                              displayText = parts[0];
                              coords = parts.length > 1 ? parts[1] : null;
                            }
                            return InkWell(
                              onTap: () async {
                                Uri? uri;
                                // If it looks like a Google Meet link, try to open in app
                                bool isGoogleMeet = false;
                                if (displayText.contains('meet.google.com') || (coords == null && lienOrLocation.contains('meet.google.com'))) {
                                  isGoogleMeet = true;
                                  // Try to use the Google Meet app scheme
                                  final meetCode = RegExp(r"meet.google.com/([a-zA-Z0-9-]+)").firstMatch(displayText)?.group(1)
                                    ?? RegExp(r"meet.google.com/([a-zA-Z0-9-]+)").firstMatch(lienOrLocation)?.group(1);
                                  if (meetCode != null) {
                                    // Always try to launch the web URL, let Android intent resolver offer the Google Meet app if available
                                    final appUri = Uri.parse('https://meet.google.com/$meetCode');
                                    if (await canLaunchUrl(appUri)) {
                                      await launchUrl(appUri, mode: LaunchMode.externalApplication);
                                      return;
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Impossible d\'ouvrir ce lien Google Meet.')),
                                      );
                                      return;
                                    }
                                  }
                                }
                                if (!isGoogleMeet && coords != null && coords.contains(',')) {
                                  uri = _getMapUri(coords);
                                } else if (!isGoogleMeet && _isLocation(lienOrLocation)) {
                                  uri = _getMapUri(lienOrLocation);
                                } else if (!isGoogleMeet) {
                                  uri = Uri.tryParse(lienOrLocation);
                                  if (uri != null && uri.scheme.isEmpty) {
                                    uri = Uri.parse('https://' + lienOrLocation);
                                  }
                                }
                                if (uri != null && await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Impossible d\'ouvrir ce lien.')),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Icon((coords != null || _isLocation(lienOrLocation)) ? Icons.location_on : Icons.link, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      displayText,
                                      style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (isMeeting && (lienOrLocation == null || lienOrLocation.isEmpty))
                        Row(
                          children: [
                            Icon(Icons.location_off, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('Lieu/Lien non renseigné', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Expanded(child: Text(description)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.flag, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('Statut: $statut', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (!isMeeting) ...[
                const SizedBox(height: 20),
                _buildStatusButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isLocation(String value) {
    final parts = value.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) return true;
    }
    if (value.contains('Rue') || value.contains('Street') || value.contains('Avenue') || value.contains('Blvd') || value.contains('Algiers') || value.contains('Paris')) {
      return true;
    }
    return false;
  }

  Uri _getMapUri(String value) {
    final parts = value.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        return Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      }
    }
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(value)}');
  }
}
