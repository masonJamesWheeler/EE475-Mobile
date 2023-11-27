import 'package:ee475_mobile/ble/ble_logger.dart';
import 'package:ee475_mobile/ble/ble_scanner.dart';
import 'package:flutter/material.dart';
import '../database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_provider;
import '../ui/connect_to_collar.dart';


var walksDisplay = [];

class DogDetailsPage extends StatefulWidget {
  final Map<String, dynamic> dogData;

  const DogDetailsPage({Key? key, required this.dogData}) : super(key: key);

  @override
  _DogDetailsPageState createState() => _DogDetailsPageState();
}

class _DogDetailsPageState extends State<DogDetailsPage> {
  List<Map<String, dynamic>> walks = [];

  @override
  void initState() {
    super.initState();
    _loadWalks();
  }

void _startWalk() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DeviceListScreen(dogId: widget.dogData['dog_id'], dogName: widget.dogData['name'])),
    );
  }

  // Load walks from Supabase
  Future<void> _loadWalks() async {
    final supabaseClient = Provider.of<supabase_provider.SupabaseClient>(context, listen: false);

    final response = await supabaseClient
      .from('walks')
      .select()
      .eq('dog_id', widget.dogData['dog_id'])
      .execute();

    if (response.data != null && response.data is List) {
      final walksData = List<Map<String, dynamic>>.from(
        response.data.map((item) => item as Map<String, dynamic>))
        ..sort((a, b) => a['date'].compareTo(b['date']));
    
      setState(() {
        walks = walksData;
      });
    }
  }

  Future<String> _getDogImageURL() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    return await dbService.fetchDogImageURL(widget.dogData['dog_id'] + '.jpg');
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
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDogProfile(),
                  SizedBox(height: 20),
                  _buildStatistics(),
                  SizedBox(height: 20),
                  _buildWalksList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startWalk,
        label: Text('Start Walk with ${widget.dogData['name']}'),
        icon: Icon(Icons.directions_walk),
      ),
    );
  }

Widget _buildDogProfile() {
  return Card(
    elevation: 4,
    child: ListTile(
      leading: FutureBuilder<String>(
        future: _getDogImageURL(), // Ensure this is the correct image ID
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Adjust the radius here
              child: Image.network(snapshot.data!, fit: BoxFit.cover, width: 50, height: 50), // Adjust size accordingly
            );
          } else {
            // Placeholder in case of no image or error
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(Icons.pets, color: Colors.white),
            );
          }
        },
      ),
      title: Text(widget.dogData['name'], style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(widget.dogData['breed']),
    ),
  );
}


  Widget _buildStatistics() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Average Pull Strength (Lbs)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildChart(), // Implement this method to create a chart
          ],
        ),
      ),
    );
  }

  Widget _buildWalksList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: walksDisplay.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: ListTile(
            title: Text('Walk on ${walksDisplay[index]['date']}'),
            subtitle: Text('Avg. Pull: ${walksDisplay[index]['avg_pull']}'),
            trailing: Text('${walksDisplay[index]['num_pulls']} Pulls'),
          ),
        );
      },
    );
  }

Widget _buildChart() {
  if (walks.isEmpty || walks.any((walk) => walk['avg_pull'] == null || walk['avg_pull'].isNaN)) {
    return Center(child: Text('No chart data available'));
  }

  List<FlSpot> spots = [];
  Map<int, String> dateLabels = {};

  // Sort walks by date
  List<Map<String, dynamic>> sortedWalks = List.from(walks)
    ..sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

  for (var i = 0; i < sortedWalks.length; i++) {
    var walk = sortedWalks[i];
    try {
      DateTime date = DateTime.parse(walk['date']);
      spots.add(FlSpot(i.toDouble(), walk['avg_pull'].toDouble()));
      dateLabels[i] = DateFormat('MM-dd').format(date);
    } catch (e) {
      // Handle the exception by not adding the spot, or by adding a default value
      print('Error parsing date: ${walk['date']}');
    }
    


  }

  // Set maxX to cover the desired range on the x-axis
  double maxX = dateLabels.keys.length.toDouble();

  return SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        maxX: maxX,
        lineTouchData: LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String label = dateLabels[value.toInt()] ?? '';
                return Text(label);
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
              reservedSize: 28,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide top titles
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right titles
          ),
        ),

        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    ),
  );
}
}

