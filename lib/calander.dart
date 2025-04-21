import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'detaille.dart';
import 'modifier_reunion.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late String _formattedDate;
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _fetchEvents();
  }

  /// Fonction pour récupérer les réunions et tâches de la base de données
  void _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var reunionsSnapshot = await FirebaseFirestore.instance.collection('reunions').get();
      var tachesSnapshot = await FirebaseFirestore.instance.collection('taches').get();

      Map<DateTime, List<dynamic>> loadedEvents = {};

      for (var doc in reunionsSnapshot.docs) {
        DateTime date = DateFormat('yyyy-MM-dd').parse(doc['date']);
        if (loadedEvents[date] == null) {
          loadedEvents[date] = [];
        }
        loadedEvents[date]!.add({
          'type': 'Réunion',
          'titre': doc['titre'],
          'lien_reunion': doc['lien_reunion'],
          'heure_debut': doc['heure_debut'],
          'heure_fin': doc['heure_fin'],
          'statut': doc['statut'],
          'doc': doc,
        });
      }

      for (var doc in tachesSnapshot.docs) {
        DateTime date = DateFormat('yyyy-MM-dd').parse(doc['date_debut']);
        if (loadedEvents[date] == null) {
          loadedEvents[date] = [];
        }
        loadedEvents[date]!.add({
          'type': 'Tâche',
          'titre': doc['titre'],
          'categorie': doc['categorie'],
          'heure_debut': doc['heure_debut'],
          'heure_fin': doc['heure_fin'],
          'statut': doc['statut'],
          'doc': doc,
        });
      }

      setState(() {
        _events = loadedEvents;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors de la récupération des événements : $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fonction pour afficher les cartes d'événements
  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () {
        if (event['type'] == 'Réunion') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ModifierReunionScreen(reunion: event['doc'])),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailleScreen(task: event['doc'])),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: event['type'] == 'Réunion' ? Colors.amber.shade200 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(event['type'] == 'Réunion' ? event['lien_reunion'] : event['categorie'],
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black54, size: 16),
                const SizedBox(width: 5),
                Text("${event['heure_debut']} - ${event['heure_fin']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: event['statut'] == "Non débutée"
                        ? Colors.red
                        : event['statut'] == "En cours"
                            ? Colors.orange
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['statut'],
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

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _events.entries
        .where((entry) => DateFormat('yyyy-MM-dd').format(entry.key) == DateFormat('yyyy-MM-dd').format(_selectedDate))
        .expand((entry) => entry.value)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des Tâches et Réunions'),
        backgroundColor: const Color(0xFF491B6D),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
              });
              _fetchEvents();
            },
            eventLoader: (day) {
              return _events.entries
                  .where((entry) => DateFormat('yyyy-MM-dd').format(entry.key) == DateFormat('yyyy-MM-dd').format(day))
                  .expand((entry) => entry.value)
                  .toList();
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (selectedEvents.isNotEmpty)
                    ? ListView(
                        children: selectedEvents.map((event) => _buildEventCard(event)).toList(),
                      )
                    : const Center(
                        child: Text("Aucun événement pour cette date."),
                      ),
          ),
        ],
      ),
    );
  }
}
