import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import '../ble/ble_scanner.dart';
import '../ble/ble_device_connector.dart';

class StartWalkPage extends StatefulWidget {
  final String dogId;

  const StartWalkPage({Key? key, required this.dogId}) : super(key: key);

  @override
  _StartWalkPageState createState() => _StartWalkPageState();
}

class _StartWalkPageState extends State<StartWalkPage> {
  DiscoveredDevice? selectedDevice;
  String? currentReading;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    checkConnectedDevice();
    Provider.of<BleScanner>(context, listen: false).startScan([]);
  }

  @override
  void dispose() {
    Provider.of<BleScanner>(context, listen: false).stopScan();
    super.dispose();
  }

  void checkConnectedDevice() {
    // Check if already connected to a device and update the state accordingly
    // This could involve checking a service or characteristic that your BLE device provides
  }

  void onSelectDevice(DiscoveredDevice device) {
    setState(() {
      selectedDevice = device;
    });
    final connector = Provider.of<BleDeviceConnector>(context, listen: false);
    connector.connect(device.id);
    // After connecting, set isConnected to true and start receiving data
  }

  void onStartWalk() {
    // Implement the logic to start the walk
  }

  @override
  Widget build(BuildContext context) {
    final bleScannerState = Provider.of<BleScannerState?>(context) ?? const BleScannerState(discoveredDevices: [], scanIsInProgress: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Start Walk')),
      body: Center(
        child: isConnected
            ? buildConnectedView()
            : buildDeviceListView(bleScannerState),
      ),
    );
  }

  Widget buildConnectedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Current Reading: $currentReading lbs'),
        ElevatedButton(
          onPressed: onStartWalk,
          child: const Text('Start Walk'),
        ),
      ],
    );
  }

  Widget buildDeviceListView(BleScannerState bleScannerState) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Stop Walk'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: bleScannerState.discoveredDevices.length,
            itemBuilder: (context, index) {
              final device = bleScannerState.discoveredDevices[index];
              return ListTile(
                title: Text(device.name ?? 'Unknown device'),
                subtitle: Text(device.id),
                trailing: selectedDevice?.id == device.id ? Icon(Icons.check) : null,
                onTap: () => onSelectDevice(device),
              );
            },
          ),
        ),
      ],
    );
  }
}
