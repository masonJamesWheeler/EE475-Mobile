import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../database_service.dart';

class AddADogPage extends StatefulWidget {
  const AddADogPage({Key? key}) : super(key: key);

  @override
  _AddADogPageState createState() => _AddADogPageState();
}

class _AddADogPageState extends State<AddADogPage> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  XFile? _imageFile; // For storing the selected image
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitData() {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    
    var uuid = Uuid();
    String dogId = uuid.v4(); // Generates a unique ID for each dog
    String name = _nameController.text.trim();
    String breed = _breedController.text.trim();
    int weight = int.parse(_weightController.text.trim());
    String imageID = dogId + '.jpg';

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

    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  String? _validateName(String? value) {
    // Validation logic for name
    return null;
  }

  String? _validateBreed(String? value) {
    // Validation logic for breed
    return null;
  }

  String? _validateWeight(String? value) {
    // Validation logic for weight
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
