import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import "../database_service.dart";

final dbService = DatabaseService();

class AddADogPage extends StatefulWidget {
  const AddADogPage({Key? key}) : super(key: key);

  @override
  _AddADogPageState createState() => _AddADogPageState();
}

class _AddADogPageState extends State<AddADogPage> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();
  XFile? _imageFile; // For storing the selected image
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitData() {
    var uuid = Uuid();
    String dogId = uuid.v4(); // Generates a unique ID for each dog
    String name = _nameController.text.trim();
    String breed = _breedController.text.trim();
    int weight = int.parse(_weightController.text.trim());
    String imageID = dogId + '.jpg';

    // Check if the image file is null
    if (_imageFile == null) {
      dbService.addDog(name: name, breed: breed, weight: weight);
    } else {
      dbService.addDogWithImage(
        name: name,
        breed: breed,
        weight: weight,
        imageFile: File(_imageFile!.path),
      );
    }
    
    Navigator.pop(
        context); // Pop the current page off the navigation stack after submission
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  String? _validateBreed(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a breed';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a weight';
    }
    final weight = int.tryParse(value);
    if (weight == null || weight < 0 || weight > 200) {
      return 'Please enter a weight between 0 and 200 lbs';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Dog')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (_imageFile != null) Image.file(File(_imageFile!.path)),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Dog\'s Name'),
                keyboardType: TextInputType.text,
                validator: _validateName,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
                keyboardType: TextInputType.text,
                validator: _validateBreed,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                validator: _validateWeight,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitData,
        child: const Icon(Icons.save),
        tooltip: 'Save Dog',
      ),
    );
  }
}
