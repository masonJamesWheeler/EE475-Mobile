// Import necessary packages
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import '../ble/ble_scanner.dart';
import '../ble/ble_device_connector.dart';
import '../ble/ble_status_monitor.dart';
import '../ble/ble_device_interactor.dart';
import '../ui/device_detail/device_detail_screen.dart';

// Define the UUIDs for the service and characteristic
const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

// Define the StartWalkPage widget
class StartWalkPage extends StatefulWidget {
  final String dogId;

  const StartWalkPage({Key? key, required this.dogId}) : super(key: key);

  @override
  _StartWalkPageState createState() => _StartWalkPageState();
}

// Define the state for the StartWalkPage widget
class _StartWalkPageState extends State<StartWalkPage> {
  // Declare variables
  DiscoveredDevice? selectedDevice;
  String? currentReading;
  bool isConnected = false;
  final TextEditingController _multiplierController = TextEditingController();
  double multiplierValue = 1.0; // Initial multiplier value

  // Globals
  late FlutterReactiveBle _ble;
  late BleScanner _ble_scanner;
  late BleDeviceConnector _ble_device_connector;
  late BleStatusMonitor _ble_status_monitor;
  late BleDeviceInteractor _ble_device_interactor;
  late StreamSubscription<BleStatus?> _ble_status_subscription;

  @override
  void initState() {
    super.initState();

    // Initialize the BLE field here
    _ble = Provider.of<FlutterReactiveBle>(context, listen: false);
    _ble_scanner = Provider.of<BleScanner>(context, listen: false);
    _ble_device_connector =
        Provider.of<BleDeviceConnector>(context, listen: false);
    _ble_status_monitor = Provider.of<BleStatusMonitor>(context, listen: false);
    _ble_device_interactor =
        Provider.of<BleDeviceInteractor>(context, listen: false);
  }

  @override
  void dispose() {
    _ble.deinitialize();
    super.dispose();
  }

  // Connect to the selected device and navigate to the detail screen
  Future<void> onSelectDevice(DiscoveredDevice device) async {
    try {
      // Connect to the device
      await _ble_device_connector.connect(device.id);

      // Navigate to the DeviceDetailScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeviceDetailScreen(device: device),
        ),
      );
    } catch (e) {
      // Handle any errors that occur during connect
      print('Error connecting to device: $e');
    }
  }


  // Start the walk
  void onStartWalk() {
    // Implement the logic to start the walk
  }

  @override
  Widget build(BuildContext context) {
    final bleScannerState = Provider.of<BleScannerState?>(context) ??
        const BleScannerState(discoveredDevices: [], scanIsInProgress: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Start Walk')),
      body: Center(
        child: isConnected ? buildConnectedView() : buildDeviceListView(),
      ),
    );
  }

  // Build the UI for the connected view
  Widget buildConnectedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Current Reading: $currentReading lbs'),
        Slider(
          value: multiplierValue,
          min: 0.5,
          max: 1.5,
          divisions: 10,
          label: multiplierValue.toStringAsFixed(1),
          onChanged: (double value) {
            setState(() {
              multiplierValue = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: onStartWalk,
          child: const Text('Start Walk'),
        ),
      ],
    );
  }

  // Build the UI for the device list view
  Widget buildDeviceListView() {
    // Stream controller to manage the list of discovered devices
    StreamController<List<DiscoveredDevice>> deviceListController =
        StreamController();

    // Start scanning for devices and add them to the stream controller
    _ble
        .scanForDevices(withServices: [])
        .where((device) => device.name == "Dog Collar")
        .listen((device) {
          deviceListController.add([device]); // Add each device as a new list
        });

    return StreamBuilder<List<DiscoveredDevice>>(
      stream: deviceListController.stream, // Use the custom stream controller
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: const Text(
                  "No Smart Collars nearby, make sure the collar is powered on and in range."));
        }

        final smartCollars = snapshot.data!;

        return Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stop Walk'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: smartCollars.length,
                itemBuilder: (context, index) {
                  final device = smartCollars[index];
                  return ListTile(
                    title: Text(device.name ?? 'Unknown device'),
                    subtitle: Text(device.id),
                    trailing: selectedDevice?.id == device.id
                        ? Icon(Icons.check)
                        : null,
                    onTap: () => onSelectDevice(device),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
