import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ModifierScreen extends StatefulWidget {
  final DocumentSnapshot task;

  const ModifierScreen({super.key, required this.task});

  @override
  _ModifierScreenState createState() => _ModifierScreenState();
}

class _ModifierScreenState extends State<ModifierScreen> {
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _categorieController;
  DateTime? _dateDebut;
  TimeOfDay? _heureDebut;
  DateTime? _dateFin;
  TimeOfDay? _heureFin;
  
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.task['titre']);
    _descriptionController = TextEditingController(text: widget.task['description']);
    _categorieController = TextEditingController(text: widget.task['categorie']);

    // Convertir les valeurs Firestore en objets DateTime et TimeOfDay
    _dateDebut = DateFormat('yyyy-MM-dd').parse(widget.task['date_debut']);
    _heureDebut = _parseTime(widget.task['heure_debut']);
    _dateFin = DateFormat('yyyy-MM-dd').parse(widget.task['date_fin']);
    _heureFin = _parseTime(widget.task['heure_fin']);
  }

  /// Convertir une chaîne d'heure Firestore (24h 'HH:mm') en objet TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    // Parse 24-hour time string 'HH:mm' (e.g., '19:30')
    final DateFormat inputFormat = DateFormat('HH:mm');
    final DateTime dateTime = inputFormat.parse(timeStr);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Fonction pour sélectionner la date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _dateDebut! : _dateFin!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _dateDebut = pickedDate;
        } else {
          _dateFin = pickedDate;
        }
      });
    }
  }

  /// Fonction pour sélectionner l'heure
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _heureDebut! : _heureFin!,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _heureDebut = pickedTime;
        } else {
          _heureFin = pickedTime;
        }
      });
    }
  }

  /// Fonction pour enregistrer les modifications dans Firestore
  void _modifierTache() async {
    try {
      await FirebaseFirestore.instance.collection('taches').doc(widget.task.id).update({
        'titre': _titreController.text,
        'description': _descriptionController.text,
        'categorie': _categorieController.text,
        'date_debut': DateFormat('yyyy-MM-dd').format(_dateDebut!),
        'heure_debut': DateFormat('HH:mm').format(DateTime(0, 0, 0, _heureDebut!.hour, _heureDebut!.minute)),
        'date_fin': DateFormat('yyyy-MM-dd').format(_dateFin!),
        'heure_fin': DateFormat('HH:mm').format(DateTime(0, 0, 0, _heureFin!.hour, _heureFin!.minute)),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tâche mise à jour avec succès !")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la modification : $e")),
      );
    }
  }

  /// Fonction pour supprimer la tâche
  void _supprimerTache() async {
    try {
      await FirebaseFirestore.instance.collection('taches').doc(widget.task.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tâche supprimée avec succès !")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Modifier Tâche', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF491B6D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              _buildTextField(_titreController, "Tâche"),
              const SizedBox(height: 12),

              _buildTextField(_descriptionController, "Description",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.deepPurple),
                  onPressed: _startListening,
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(_categorieController, "Catégorie"),
              const SizedBox(height: 20),

              const Text("Date de début", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDateTimeFields(context, true),

              const SizedBox(height: 20),
              const Text("Date de fin", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDateTimeFields(context, false),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _modifierTache,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text("Enregistrer"),
                  ),
                  ElevatedButton(
                    onPressed: _supprimerTache,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text("Supprimer"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget pour les champs de texte
  Widget _buildTextField(TextEditingController controller, String hint, {Widget? suffixIcon}) {
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
        if (suffixIcon != null)
          GestureDetector(
            onLongPressStart: (_) async {
              bool available = await _speechToText.initialize();
              if (available) {
                setState(() => _isListening = true);
                _speechToText.listen(onResult: (result) {
                  controller.text = result.recognizedWords;
                  controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                });
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

  /// Widget pour afficher les champs de date et d'heure
  Widget _buildDateTimeFields(BuildContext context, bool isStartDate) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _selectTime(context, isStartDate),
          icon: const Icon(Icons.access_time, color: Colors.deepPurple),
        ),
        Text(
          isStartDate
              ? "${_heureDebut!.format(context)}"
              : "${_heureFin!.format(context)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () => _selectDate(context, isStartDate),
          icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        ),
        Text(
          isStartDate
              ? DateFormat('EEE dd, MMMM yyyy').format(_dateDebut!)
              : DateFormat('EEE dd, MMMM yyyy').format(_dateFin!),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _startListening() {}
}
