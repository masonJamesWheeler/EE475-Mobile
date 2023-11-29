import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../ble/ble_device_connector.dart';
import '../ble/ble_device_interactor.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

part '../ui/device_detail/device_interaction_tab.g.dart';

class DeviceInteractionTab extends StatelessWidget {
  const DeviceInteractionTab({
    required this.device,
    required this.dog_id,    // The reason we are passing this down is for the database
    required this.dog_name,  // The reason we are passing this down is for the database
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice device;
  final String dog_id;      // The reason we are passing this down is for the database
  final String dog_name;    // The reason we are passing this down is for the database


  @override
  Widget build(BuildContext context) =>
      Consumer3<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                __) =>
            _DeviceInteractionTab(
          viewModel: DeviceInteractionViewModel(
            deviceId: device.id,
            connectableStatus: device.connectable,
            connectionStatus: connectionStateUpdate.connectionState,
            deviceConnector: deviceConnector,
            discoverServices: () =>
                serviceDiscoverer.discoverServices(device.id),
            dog_id: dog_id,
            dog_name: dog_name,
          ),
        ),
      );
}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
    required this.dog_id,
    required this.dog_name,
  });

  final String deviceId;
  final Connectable connectableStatus;
  final DeviceConnectionState connectionStatus;
  final BleDeviceConnector deviceConnector;
  final String dog_id;
  final String dog_name;

  @CustomEquality(Ignore())
  final Future<List<Service>> Function() discoverServices;

  bool get deviceConnected => connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class _DeviceInteractionTab extends StatefulWidget {
  const _DeviceInteractionTab({
    required this.viewModel,
    Key? key,
  }) : super(key: key);

  final DeviceInteractionViewModel viewModel;

  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
  int pullCount = 0;
  double currentReading = 0.0;
  double avgPull = 0.0;
  double threshold = 100000.0;
  int totalReadings = 0;
  bool isWalking = false;
  bool isPulling = false;
  bool isInitializing = true;
  String initializationProgress = "";
  Timer? sensorReadTimer;
  
  Characteristic? currentCharacteristic;
  StreamController<String> sensorDataStreamController = StreamController();
  StreamSubscription<String>? sensorDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.connect();
  }

  Future<void> startWalk() async {
    if (widget.viewModel.deviceConnected) {
      final services = await widget.viewModel.discoverServices();
      if (services.isNotEmpty && services[0].characteristics.isNotEmpty) {
        currentCharacteristic = services[0].characteristics[0];
        sensorReadTimer = Timer.periodic(Duration(milliseconds: 500), (Timer t) => readCharacteristic());
        print("Reaching here");
        startSensorDataStream();
        setState(() => isWalking = true);
      } else {
        print("No services or characteristics available");
      }
    } else {
      print("Device not connected");
    }
  }

  Future<void> stopWalk() async {
    sensorReadTimer?.cancel();
    sensorDataStreamSubscription?.cancel();
    sensorDataStreamController.add("No data");
    setState(() => isWalking = false);
  }

  Future<void> readCharacteristic() async {
    if (currentCharacteristic == null) return;
    try {
      final value = await currentCharacteristic!.read();
      totalReadings++;
      sensorDataStreamController.add(value.toString());
    } catch (e) {
      print("Error reading characteristic: $e");
    }
  }

  void startSensorDataStream() {
    sensorDataStreamSubscription = sensorDataStreamController.stream.listen((sensorValue) {
      // Parse the string to get the byte array
      var bytes = parseStringToBytes(sensorValue);

      // Convert the byte array to an integer
      var intValue = _bytesToInt(bytes);
      print(intValue);
        isInitializing = sensorValue.contains("1953066569");
        if (isInitializing) {
          initializationProgress = sensorValue;
        } else {
          setState(() {
          currentReading = intValue.toDouble();
          });
          updatePulls(currentReading);
          updateAveragePull(currentReading);
        }
      });
  }

  void updateAveragePull(double reading) {
    setState(() {
    });
    avgPull += ((reading - avgPull) / totalReadings);
  }

  void updatePulls(double reading) {
    setState(() {
    if (reading > threshold && !isPulling) {
      pullCount++;
      isPulling = true;
    } else if (reading < threshold) {
      isPulling = false;
    }
    });
  }

  int _bytesToInt(List<int> bytes) {
  // Convert List<int> to Uint8List
  var uint8list = Uint8List.fromList(bytes);
  
  // Create a ByteData view from the Uint8List
  var byteData = ByteData.view(uint8list.buffer);

  // Get the integer value with the correct endianness
  return byteData.getInt32(0, Endian.little);
}

List<int> parseStringToBytes(String str) {
  // Remove the brackets and spaces
  var cleanedStr = str.replaceAll(RegExp(r'[\[\] ]'), '');

  // Split the string by commas
  var parts = cleanedStr.split(',');

  // Convert each part to an integer and return the list
  return parts.map(int.parse).toList();
}

  @override
  void dispose() {
    sensorReadTimer?.cancel();
    sensorDataStreamSubscription?.cancel();
    sensorDataStreamController.close();
    super.dispose();
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.viewModel.deviceConnected
          ? "Connected to ${widget.viewModel.dog_name}'s Collar"
          : "Connecting..."),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.viewModel.deviceConnected && isInitializing)
            Column(
              children: [
                SizedBox(height: 20),
                Text(initializationProgress),
              ],
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: isWalking ? stopWalk : startWalk,
                  child: Text(isWalking ? 'Stop Walk' : 'Start Walk'),
                ),
                SizedBox(height: 20),
                Text("Current Reading: $currentReading"),
                Text("Total Pull: $avgPull"),
                Text("Pulls over Threshold: $pullCount"),
              ],
            ),
        ],
      ),
    ),
  );
}
}

