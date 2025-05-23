import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'map_picker.dart';

class ModifierReunionScreen extends StatefulWidget {
  final DocumentSnapshot reunion;

  const ModifierReunionScreen({super.key, required this.reunion});

  @override
  _ModifierReunionScreenState createState() => _ModifierReunionScreenState();
}

class _ModifierReunionScreenState extends State<ModifierReunionScreen> {
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _lienReunionController;
  DateTime? _date;
  TimeOfDay? _heureDebut;
  TimeOfDay? _heureFin;

  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.reunion['titre']);
    _descriptionController = TextEditingController(text: widget.reunion['description']);
    _lienReunionController = TextEditingController(text: widget.reunion['lien_reunion']);

    _date = DateFormat('yyyy-MM-dd').parse(widget.reunion['date']);
    _heureDebut = _parseTime(widget.reunion['heure_debut']);
    _heureFin = _parseTime(widget.reunion['heure_fin']);
  }

  /// Convertir une chaîne d'heure Firestore (24h) en TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    // Parse 24-hour time string 'HH:mm' (e.g., '19:30')
    final DateFormat inputFormat = DateFormat('HH:mm');
    final DateTime dateTime = inputFormat.parse(timeStr);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Fonction pour sélectionner une date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _date!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
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
  void _modifierReunion() async {
    try {
      await FirebaseFirestore.instance.collection('reunions').doc(widget.reunion.id).update({
        'titre': _titreController.text,
        'description': _descriptionController.text,
        'lien_reunion': _lienReunionController.text,
        'date': DateFormat('yyyy-MM-dd').format(_date!),
        'heure_debut': DateFormat('HH:mm').format(DateTime(0, 0, 0, _heureDebut!.hour, _heureDebut!.minute)),
        'heure_fin': DateFormat('HH:mm').format(DateTime(0, 0, 0, _heureFin!.hour, _heureFin!.minute)),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réunion mise à jour avec succès !")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la modification : $e")),
      );
    }
  }

  /// Fonction pour supprimer la réunion
  void _supprimerReunion() async {
    try {
      await FirebaseFirestore.instance.collection('reunions').doc(widget.reunion.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réunion supprimée avec succès !")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }

  void _startListening() {}

  void _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (result != null && result is Map) {
      setState(() {
        // Store both address and coordinates in the controller as a single string, separated by '|' for easy parsing
        // Example: 'address|lat,lng'
        final address = result['address'] ?? '${result['lat']},${result['lng']}';
        final coords = '${result['lat']},${result['lng']}';
        _lienReunionController.text = '$address|$coords';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Modifier Réunion', style: TextStyle(color: Colors.white)),
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

              _buildTextField(_titreController, "Réunion"),
              const SizedBox(height: 12),

              _buildTextField(_descriptionController, "Description",
                suffixIcon: GestureDetector(
                  onLongPressStart: (_) async {
                    bool available = await _speechToText.initialize();
                    if (available) {
                      setState(() => _isListening = true);
                      _speechToText.listen(onResult: (result) {
                        _descriptionController.text = result.recognizedWords;
                        _descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: _descriptionController.text.length));
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
              ),
              const SizedBox(height: 12),

              _buildTextField(_lienReunionController, "Google Meet / Lieu",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map, color: Colors.deepPurple),
                  onPressed: _pickLocation,
                ),
              ),
              const SizedBox(height: 20),

              const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDateField(context),

              const SizedBox(height: 20),
              const Text("Date de début", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeField(context, true),

              const SizedBox(height: 20),
              const Text("Date de fin", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeField(context, false),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _modifierReunion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text("Enregistrer"),
                  ),
                  ElevatedButton(
                    onPressed: _supprimerReunion,
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
          suffixIcon,
      ],
    );
  }

  /// Widget pour afficher le champ de date
  Widget _buildDateField(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        ),
        Text(
          DateFormat('EEE dd, MMMM yyyy').format(_date!),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Widget pour afficher les champs d'heure
  Widget _buildTimeField(BuildContext context, bool isStartTime) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _selectTime(context, isStartTime),
          icon: const Icon(Icons.access_time, color: Colors.deepPurple),
        ),
        Text(
          isStartTime
              ? "${_heureDebut!.format(context)}"
              : "${_heureFin!.format(context)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
