import 'package:ee475_mobile/ble/ble_device_interactor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../ble/ble_scanner.dart';
import 'package:provider/provider.dart';
import '../ble/ble_logger.dart';
import 'widgets.dart';
import './device_detail/dog_walk_scaffolding.dart';

class DeviceListScreen extends StatelessWidget {
  final String dogId;
  final String dogName;

  const DeviceListScreen({
    Key? key,
    required this.dogId,
    required this.dogName,
  }) : super(key: key);
  
  
  @override
  Widget build(BuildContext context) {
    final bleScanner = Provider.of<BleScanner>(context, listen: false);
    final bleLogger = Provider.of<BleLogger>(context, listen: false);

    return _DeviceList(
      startScan: bleScanner.startScan,
      stopScan: bleScanner.stopScan,
      verboseLogging: bleLogger.verboseLogging,
      dogId: dogId,
      dogName: dogName,
    );
  }
}

class _DeviceList extends StatefulWidget {
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final bool verboseLogging;
  final String dogId;
  final String dogName;

  const _DeviceList({
    Key? key,
    required this.startScan,
    required this.stopScan,
    required this.verboseLogging,
    required this.dogId,
    required this.dogName,
  }) : super(key: key);

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
// In _DeviceListState
@override
void initState() {
  super.initState();
  widget.startScan([]); // Start scanning immediately
  WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
}

  @override
  void dispose() {
    widget.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleInteractor = Provider.of<BleDeviceInteractor>(context, listen: false);
    final scannerState = Provider.of<BleScannerState>(context);

    // Function to find services for a device
    void discoverServices(String deviceId) async {
      final services = await bleInteractor.discoverServices(deviceId);
      print('Discovered services: $services');
    }
    
    // Filter the discovered devices based on their names
    final filteredDevices = scannerState.discoveredDevices
        .where((device) => device.name.contains('Dog Collar'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for devices'),
      ),
      body: Column(
        children: [
                  Flexible(
            child: scannerState.discoveredDevices.isEmpty
                ? const Center(child: Text('No devices found. Make sure the device is on and in range.'))
                : ListView.builder(
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];
                      return ListTile(
                        title: Text(device.name.isNotEmpty ? device.name : "Unnamed"),
                        subtitle: Text("${device.id}\nRSSI: ${device.rssi}\n${device.connectable}"),
                        leading: const BluetoothIcon(),
                          onTap: () async {
                          widget.stopScan();
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeviceDetailScreen(
                                device: device,
                                dog_id: widget.dogId,
                                dog_name: widget.dogName,
                              ),
                            ),
                          ).then((_) => setState(() {})); // Add this line
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
