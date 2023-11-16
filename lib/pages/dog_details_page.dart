import '../main.dart';
import '../database_service.dart';
import 'package:flutter/material.dart';

final dbService = DatabaseService();

class DogDetailsPage extends StatefulWidget {
  final Map<String, dynamic> dogData;

  const DogDetailsPage({Key? key, required this.dogData}) : super(key: key);

  @override
  _DogDetailsPageState createState() => _DogDetailsPageState();
}

class _DogDetailsPageState extends State<DogDetailsPage> {
  List<Map<String, dynamic>> walks = [];

  @override
  initState() {
    super.initState();
    // Find the walks for this dog
    walks = dbService.fetchWalks(widget.dogData['dog_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${widget.dogData['name']}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (walks.isEmpty)
              Text('No walks logged yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: walks.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Walk ${index + 1}'),
                    subtitle: Text(walks[index]['date']),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
