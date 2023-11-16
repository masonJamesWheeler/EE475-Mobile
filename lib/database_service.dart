import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  // Function to fetch dogs from the database
  Future<List<Map<String, dynamic>>> fetchDogs() async {
    // Check if the user is logged in
    if (supabase.auth.currentUser == null) {
      return [];
    }
    // Get the user_id
    String ownerID = supabase.auth.currentUser!.id;
    // Search through the database for dogs with the same owner_id
    final response =
        await supabase.from('dogs').select().eq('owner_id', ownerID);

    // Check if the response contains data and is a list
    if (response != null && response is List) {
      // Map each element to Map<String, dynamic> and return
      return List<Map<String, dynamic>>.from(
          response.map((item) => item as Map<String, dynamic>));
    } else {
      // Handle the scenario where data is not available or not in the expected format
      print('Data not found or format is not as expected');
      return [];
    }
  }

  // Function to find out how many walks have been logged total for a given dog
  Future<int> fetchTotalWalks(String dogID) async {
    // Check if the user is logged in
    if (supabase.auth.currentUser == null) {
      return 0;
    }
    // Search through the database for walks with the same dog_id
    final response = await supabase.from('walks').select().eq('dog_id', dogID);

    // Check if the response contains data and is a list
    if (response != null && response is List) {
      // Return the length of the list
      return response.length;
    } else {
      // Handle the scenario where data is not available or not in the expected format
      print('Data not found or format is not as expected');
      return 0;
    }
  }

  // Function to fetch walks from the database
  Future<List<Map<String, dynamic>>> fetchWalks(String dogID) async {
    // Check if the user is logged in
    if (supabase.auth.currentUser == null) {
      return [];
    }
    // Search through the database for walks with the same dog_id
    final response = await supabase.from('walks').select().eq('dog_id', dogID);

    // Check if the response contains data and is a list
    if (response != null && response is List) {
      // Map each element to Map<String, dynamic> and return
      return List<Map<String, dynamic>>.from(
          response.map((item) => item as Map<String, dynamic>));
    } else {
      // Handle the scenario where data is not available or not in the expected format
      print('Data not found or format is not as expected');
      return [];
    }
  }

  // Function to retrieve the image of a dog from Supabase Storage
  Future<String> fetchDogImageURL(String imageID) async {
    // Check if the user is logged in
    if (supabase.auth.currentUser == null) {
      return '';
    }
    // Retrieve the image as a signed URL
    final response = await supabase.storage.from('Images').createSignedUrl(
          imageID,
          // This URL will expire in 1 hour
          // You can adjust this value according to your needs
          3600,
        );

    return response;
  }

  Future<void> addDogWithImage({
    required String name,
    required String breed,
    required int weight,
    required File imageFile,
  }) async {
    // Check if a user is logged in
    if (supabase.auth.currentUser == null) {
      throw Exception('You must be logged in to add a dog.');
    }

    var uuid = Uuid();
    String dogId = uuid.v4(); // Generates a unique ID for each dog
    String ownerID = supabase.auth.currentUser!.id;
    String imageID = dogId + '.jpg';

    // Insert the new dog into the database
    await supabase.from('dogs').upsert({
      'dog_id': dogId,
      'name': name,
      'breed': breed,
      'weight': weight,
      'owner_id': ownerID,
    }).execute();

    // Upload the image to Supabase Storage
    await supabase.storage.from('Images').upload(imageID, imageFile);
  }

  // Function to add a dog without an image
  Future<void> addDog({
    required String name,
    required String breed,
    required int weight,
  }) async {
    // Check if a user is logged in
    if (supabase.auth.currentUser == null) {
      throw Exception('You must be logged in to add a dog.');
    }

    var uuid = Uuid();
    String dogId = uuid.v4(); // Generates a unique ID for each dog
    String ownerID = supabase.auth.currentUser!.id;

    // Insert the new dog into the database
    await supabase.from('dogs').upsert({
      'dog_id': dogId,
      'name': name,
      'breed': breed,
      'weight': weight,
      'owner_id': ownerID,
    }).execute();
  }
}

  
