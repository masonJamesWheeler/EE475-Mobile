// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import '../../ble/ble_device_connector.dart';
// import '../../ble/ble_device_interactor.dart';
// import 'package:functional_data/functional_data.dart';
// import 'package:provider/provider.dart';
// import '../ble/ble_scanner.dart';
// import '../main.dart';

// import '../ui/device_detail/characteristic_interaction_dialog.dart';
// import '../ui/device_detail/device_interaction_tab.dart';

// class StartWalkPage extends StatelessWidget {
//   final String dogId;
//   StartWalkPage({required this.dogId});

//   @override
//   Widget build(BuildContext context) {
//     final bleScanner = Provider.of<BleScanner>(context);
//     final deviceConnector = Provider.of<BleDeviceConnector>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Start Walk'),
//       ),
//       body: Consumer<ConnectionStateUpdate>(
//         builder: (context, connectionStateUpdate, _) {
//           if (connectionStateUpdate.connectionState ==
//               DeviceConnectionState.connected) {
//             // If connected, show DeviceInteractionTab
//             return DeviceInteractionTab(device: connectionStateUpdate.deviceId);
//           } else {
//             // If not connected, show message and list of devices
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     "You are not yet connected to a collar, please check if the collar is on and in range",
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Expanded(
//                   child: StreamBuilder<BleScannerState>(
//                     stream: bleScanner.state,
//                     initialData: BleScannerState(
//                       discoveredDevices: [],
//                       scanIsInProgress: false,
//                     ),
//                     builder: (context, snapshot) {
//                       if (snapshot.data?.scanIsInProgress ?? false) {
//                         return Center(child: CircularProgressIndicator());
//                       }

//                       return ListView(
//                         children: snapshot.data?.discoveredDevices
//                             ?.map((device) => ListTile(
//                                   title: Text(device.name),
//                                   subtitle: Text(device.id),
//                                   onTap: () async {
//                                     await deviceConnector.connect(device.id);
//                                   },
//                                 ))
//                             ?.toList() ??
//                             [],
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => bleScanner.startScan(),
//         child: Icon(Icons.search),
//       ),
//     );
//   }
// }

// class DeviceInteractionTab extends StatelessWidget {
//   const DeviceInteractionTab({
//     required this.device,
//     Key? key,
//   }) : super(key: key);

//   final DiscoveredDevice device;

//   @override
//   Widget build(BuildContext context) =>
//       Consumer3<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor>(
//         builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
//                 __) =>
//             _DeviceInteractionTab(
//           viewModel: DeviceInteractionViewModel(
//             deviceId: device.id,
//             connectableStatus: device.connectable,
//             connectionStatus: connectionStateUpdate.connectionState,
//             deviceConnector: deviceConnector,
//             discoverServices: () =>
//                 serviceDiscoverer.discoverServices(device.id),
//           ),
//         ),
//       );
// }

// @immutable
// @FunctionalData()
// class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
//   const DeviceInteractionViewModel({
//     required this.deviceId,
//     required this.connectableStatus,
//     required this.connectionStatus,
//     required this.deviceConnector,
//     required this.discoverServices,
//   });

//   final String deviceId;
//   final Connectable connectableStatus;
//   final DeviceConnectionState connectionStatus;
//   final BleDeviceConnector deviceConnector;

//   @CustomEquality(Ignore())
//   final Future<List<Service>> Function() discoverServices;

//   bool get deviceConnected =>
//       connectionStatus == DeviceConnectionState.connected;

//   void connect() {
//     deviceConnector.connect(deviceId);
//   }

//   void disconnect() {
//     deviceConnector.disconnect(deviceId);
//   }
// }

// class _DeviceInteractionTab extends StatefulWidget {
//   const _DeviceInteractionTab({
//     required this.viewModel,
//     Key? key,
//   }) : super(key: key);

//   final DeviceInteractionViewModel viewModel;

//   @override
//   _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
// }

// class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
//   late List<Service> discoveredServices;

//   @override
//   void initState() {
//     discoveredServices = [];
//     super.initState();
//   }

//   Future<void> discoverServices() async {
//     final result = await widget.viewModel.discoverServices();
//     setState(() {
//       discoveredServices = result;
//     });
//   }

//   @override
//   Widget build(BuildContext context) => CustomScrollView(
//         slivers: [
//           SliverList(
//             delegate: SliverChildListDelegate.fixed(
//               [
//                 Padding(
//                   padding: const EdgeInsetsDirectional.only(
//                       top: 8.0, bottom: 16.0, start: 16.0),
//                   child: Text(
//                     "ID: ${widget.viewModel.deviceId}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsetsDirectional.only(start: 16.0),
//                   child: Text(
//                     "Connectable: ${widget.viewModel.connectableStatus}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsetsDirectional.only(start: 16.0),
//                   child: Text(
//                     "Connection: ${widget.viewModel.connectionStatus}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: <Widget>[
//                       ElevatedButton(
//                         onPressed: !widget.viewModel.deviceConnected
//                             ? widget.viewModel.connect
//                             : null,
//                         child: const Text("Connect"),
//                       ),
//                       ElevatedButton(
//                         onPressed: widget.viewModel.deviceConnected
//                             ? widget.viewModel.disconnect
//                             : null,
//                         child: const Text("Disconnect"),
//                       ),
//                       ElevatedButton(
//                         onPressed: widget.viewModel.deviceConnected
//                             ? discoverServices
//                             : null,
//                         child: const Text("Discover Services"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (widget.viewModel.deviceConnected)
//                   _ServiceDiscoveryList(
//                     deviceId: widget.viewModel.deviceId,
//                     discoveredServices: discoveredServices,
//                   ),
//               ],
//             ),
//           ),
//         ],
//       );
// }

// class _ServiceDiscoveryList extends StatefulWidget {
//   const _ServiceDiscoveryList({
//     required this.deviceId,
//     required this.discoveredServices,
//     Key? key,
//   }) : super(key: key);

//   final String deviceId;
//   final List<Service> discoveredServices;
  
//   @override
//   _ServiceDiscoveryListState createState() => _ServiceDiscoveryListState();
// }

// class _ServiceDiscoveryListState extends State<_ServiceDiscoveryList> {
//   late final List<int> _expandedItems;
  
//   @override
//   void initState() {
//     _expandedItems = [];
//     super.initState();
//   }

//   String _characteristicSummary(Characteristic c) {
//     final props = <String>[];
//     if (c.isReadable) {
//       props.add("read");
//     }
//     if (c.isWritableWithoutResponse) {
//       props.add("write without response");
//     }
//     if (c.isWritableWithResponse) {
//       props.add("write with response");
//     }
//     if (c.isNotifiable) {
//       props.add("notify");
//     }
//     if (c.isIndicatable) {
//       props.add("indicate");
//     }

//     return props.join("\n");
//   }

// Widget _characteristicTile(Characteristic characteristic) => ListTile(
//   onTap: () {
//     readCharacteristic(characteristic);
//     showDialog<void>(
//       context: context,
//       builder: (context) => CharacteristicInteractionDialog(characteristic: characteristic),
//     );
//   },
//   title: Text(
//     '${characteristic.id}\n(${_characteristicSummary(characteristic)})',
//     style: const TextStyle(fontSize: 14),
//   ),
// );



//   List<ExpansionPanel> buildPanels() {
//     // This is the line that we want
//     if (widget.discoveredServices[0].characteristics != null) {
//       readCharacteristic(widget.discoveredServices[0].characteristics[0]);
//     }
//     final panels = <ExpansionPanel>[];
//     widget.discoveredServices.asMap().forEach(
//           (index, service) => panels.add(
//             ExpansionPanel(
//               body: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsetsDirectional.only(start: 16.0),
//                     child: Text(
//                       'Characteristics',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: service.characteristics
//                         .map(_characteristicTile)
//                         .toList(),
//                   ),
//                 ],
//               ),
//               headerBuilder: (context, isExpanded) => ListTile(
//                 title: Text(
//                   '${service.id}',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ),
//               isExpanded: _expandedItems.contains(index),
//             ),
//           ),
//         );

//     return panels;
//   }

//   @override
//   Widget build(BuildContext context) => widget.discoveredServices.isEmpty
//       ? const SizedBox()
//       : SafeArea(
//           top: false,
//           child: Padding(
//             padding: const EdgeInsetsDirectional.only(
//               top: 20.0,
//               start: 20.0,
//               end: 20.0,
//             ),
//             child: ExpansionPanelList(
//               expansionCallback: (int index, bool isExpanded) {
//                 setState(() {
//                   if (isExpanded) {
//                     _expandedItems.remove(index);
//                     print("Panel $index collapsed");
//                   } else {
//                     _expandedItems.add(index);
//                     print("Panel $index expanded");
//                   }
//                 });
//               },
//               children: buildPanels(),
//             ),
//           ),
//         );

//         // Add a new field to hold the read value
//   List<int>? characteristicValue;

//   // Async method to read the characteristic
//   Future<void> readCharacteristic(Characteristic characteristic) async {
//     try {
//       final value = await characteristic.read();
//       setState(() {
//         characteristicValue = value;
//       });
//       print("Read value: $value");
//     } catch (e) {
//       print("Error reading characteristic: $e");
//     }
//   }
// }

