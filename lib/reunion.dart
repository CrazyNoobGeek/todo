import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'map_picker.dart';
import 'notification_helper.dart';

class ReunionScreen extends StatefulWidget {
  const ReunionScreen({super.key});

  @override
  _ReunionScreenState createState() => _ReunionScreenState();
}

class _ReunionScreenState extends State<ReunionScreen> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationOrLinkController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  /// Fonction pour afficher un sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Fonction pour afficher un sélecteur d'heure
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = pickedTime;
        } else {
          _selectedEndTime = pickedTime;
        }
      });
    }
  }

  /// Fonction pour enregistrer les données dans Firestore
  Future<void> _ajouterReunion() async {
    if (_titreController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationOrLinkController.text.isEmpty ||
        _selectedDate == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null) {
      _showMessage("Veuillez remplir tous les champs.");
      return;
    }

    try {
      final docRef = await FirebaseFirestore.instance.collection('reunions').add({
        'titre': _titreController.text,
        'description': _descriptionController.text,
        'lien_reunion': _locationOrLinkController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'heure_debut': _selectedStartTime != null ? _selectedStartTime!.format(context) : '',
        'heure_fin': _selectedEndTime != null ? _selectedEndTime!.format(context) : '',
        'statut': 'En cours',
        'cree_le': Timestamp.now(),
      });
      // Add notification to Firestore (2h before, start, end)
      DateTime startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );
      DateTime endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'meeting',
        'title': 'Réunion à venir',
        'body': 'La réunion "${_titreController.text}" commence dans 2 heures.',
        'timestamp': Timestamp.fromDate(startDateTime.subtract(const Duration(hours: 2))),
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'meeting',
        'title': 'Début Réunion',
        'body': 'La réunion "${_titreController.text}" commence maintenant.',
        'timestamp': Timestamp.fromDate(startDateTime),
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'meeting',
        'title': 'Fin Réunion',
        'body': 'La réunion "${_titreController.text}" est terminée. Veuillez mettre à jour le statut.',
        'timestamp': Timestamp.fromDate(endDateTime),
      });
      // Schedule local notifications
      await NotificationHelper.scheduleMultipleNotifications(
        id: docRef.hashCode,
        title: 'Rappel Réunion',
        body: 'La réunion "${_titreController.text}"',
        startTime: startDateTime,
        endTime: endDateTime,
        status: 'En cours',
      );
      _showMessage("Réunion ajoutée avec succès !");
      _clearFields();
    } catch (e) {
      _showMessage("Erreur lors de l'ajout de la réunion : $e");
    }
  }

  /// Fonction pour afficher un message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Fonction pour vider les champs après soumission
  void _clearFields() {
    _titreController.clear();
    _descriptionController.clear();
    _locationOrLinkController.clear();
    setState(() {
      _selectedDate = null;
      _selectedStartTime = null;
      _selectedEndTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter Réunion', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF491B6D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajouter Réunion",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildTextField(_titreController, "Réunion"),
              const SizedBox(height: 12),

              _buildDescriptionField(_descriptionController, "Description"),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_locationOrLinkController, "Lien de la réunion (Google Meet, Zoom, etc.) ou choisir un lieu"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Color(0xFF491B6D)),
                    tooltip: 'Choisir un lieu sur la carte',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPickerScreen()),
                      );
                      if (result != null && result is Map) {
                        setState(() {
                          _locationOrLinkController.text = result['address'] ?? '${result['lat']},${result['lng']}';
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sélection de la date
              const Text("Date de la réunion", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDateField(context),

              const SizedBox(height: 20),

              // Date de début
              const Text("Date de début", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeField(context, isStart: true),

              const SizedBox(height: 20),

              // Date de fin
              const Text("Date de fin", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeField(context, isStart: false),

              const SizedBox(height: 30),

              // Bouton Ajouter Réunion
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _ajouterReunion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Ajouter Réunion",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget pour les champs de texte
  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Widget pour le champ de description avec micro
  Widget _buildDescriptionField(TextEditingController controller, String hint) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        GestureDetector(
          onLongPressStart: (_) async {
            var available = await _speechToText.initialize();
            if (available) {
              setState(() => _isListening = true);
              await _speechToText.listen(
                onResult: (result) {
                  controller.text = result.recognizedWords;
                  controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                },
              );
            }
          },
          onLongPressEnd: (_) async {
            await _speechToText.stop();
            setState(() => _isListening = false);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget pour sélectionner la date
  Widget _buildDateField(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        ),
        Text(
          _selectedDate != null
              ? DateFormat('EEE dd, MMMM, yyyy').format(_selectedDate!)
              : "Fri 25, September, 2025",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Widget pour sélectionner l'heure de début et de fin
  Widget _buildTimeField(BuildContext context, {required bool isStart}) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _selectTime(context, isStart),
          icon: const Icon(Icons.access_time, color: Colors.deepPurple),
        ),
        Text(
          isStart && _selectedStartTime != null
              ? _selectedStartTime!.format(context)
              : !isStart && _selectedEndTime != null
                  ? _selectedEndTime!.format(context)
                  : "09:30",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
