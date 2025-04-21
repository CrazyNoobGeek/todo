import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'notification_helper.dart';

class TacheScreen extends StatefulWidget {
  const TacheScreen({super.key});

  @override
  _TacheScreenState createState() => _TacheScreenState();
}

class _TacheScreenState extends State<TacheScreen> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  TimeOfDay? _selectedStartTime;
  DateTime? _selectedStartDate;
  TimeOfDay? _selectedEndTime;
  DateTime? _selectedEndDate;

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

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _selectedStartDate = pickedDate;
        } else {
          _selectedEndDate = pickedDate;
        }
      });
    }
  }

  Future<void> _ajouterTache() async {
    if (_titreController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _categorieController.text.isEmpty ||
        _selectedStartDate == null ||
        _selectedStartTime == null ||
        _selectedEndDate == null ||
        _selectedEndTime == null) {
      _showMessage("Veuillez remplir tous les champs.");
      return;
    }

    try {
      final docRef = await FirebaseFirestore.instance.collection('taches').add({
        'titre': _titreController.text,
        'description': _descriptionController.text,
        'categorie': _categorieController.text,
        'date_debut': DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
        'heure_debut': DateFormat('HH:mm').format(DateTime(0, 0, 0, _selectedStartTime!.hour, _selectedStartTime!.minute)),
        'date_fin': DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
        'heure_fin': DateFormat('HH:mm').format(DateTime(0, 0, 0, _selectedEndTime!.hour, _selectedEndTime!.minute)),
        'statut': 'En cours',
        'cree_le': Timestamp.now(),
      });
      // Add notification to Firestore (2h before, start, end)
      DateTime startDateTime = DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );
      DateTime endDateTime = DateTime(
        _selectedEndDate!.year,
        _selectedEndDate!.month,
        _selectedEndDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'task',
        'title': 'Tâche à venir',
        'body': 'La tâche "${_titreController.text}" commence dans 2 heures.',
        'timestamp': Timestamp.fromDate(startDateTime.subtract(const Duration(hours: 2))),
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'task',
        'title': 'Début Tâche',
        'body': 'La tâche "${_titreController.text}" commence maintenant.',
        'timestamp': Timestamp.fromDate(startDateTime),
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'task',
        'title': 'Fin Tâche',
        'body': 'La tâche "${_titreController.text}" est terminée. Veuillez mettre à jour le statut.',
        'timestamp': Timestamp.fromDate(endDateTime),
      });
      // Schedule local notifications
      await NotificationHelper.scheduleMultipleNotifications(
        id: docRef.hashCode,
        title: 'Rappel Tâche',
        body: 'La tâche "${_titreController.text}"',
        startTime: startDateTime,
        endTime: endDateTime,
        status: 'En cours',
      );
      _showMessage("Tâche ajoutée avec succès !");
      _clearFields();
    } catch (e) {
      _showMessage("Erreur lors de l'ajout de la tâche : $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearFields() {
    _titreController.clear();
    _descriptionController.clear();
    _categorieController.clear();
    setState(() {
      _selectedStartTime = null;
      _selectedStartDate = null;
      _selectedEndTime = null;
      _selectedEndDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter Tache', style: TextStyle(color: Colors.white)),
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
                "Ajouter Tache",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(_titreController, "Tache"),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, "Description"),
              const SizedBox(height: 12),
              _buildTextField(_categorieController, "Catégorie"),
              const SizedBox(height: 20),
              const Text("Date de début",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDateTimeRow(context, isStart: true),
              const SizedBox(height: 20),
              const Text("Date de fin",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDateTimeRow(context, isStart: false),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _ajouterTache,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Ajouter Tache",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: hint == "Description" ? 2 : 1,
            maxLines: hint == "Description" ? 5 : 1,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (hint == "Description")
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

  Widget _buildDateTimeRow(BuildContext context, {required bool isStart}) {
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
        const Spacer(),
        IconButton(
          onPressed: () => _selectDate(context, isStart),
          icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        ),
        Text(
          isStart && _selectedStartDate != null
              ? DateFormat('EEE dd, MMMM, yyyy').format(_selectedStartDate!)
              : !isStart && _selectedEndDate != null
                  ? DateFormat('EEE dd, MMMM, yyyy').format(_selectedEndDate!)
                  : "${DateTime.now()}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
