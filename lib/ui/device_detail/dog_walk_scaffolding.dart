import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../ble/ble_device_connector.dart';
import 'device_log_tab.dart';
import 'package:provider/provider.dart';

import '../../pages/dog_walk.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;
  final String dog_id;
  final String dog_name;

  const DeviceDetailScreen({required this.device, required this.dog_id, required this.dog_name, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
        builder: (_, deviceConnector, __) => _DeviceDetail(
          device: device,
          dog_id: dog_id,
          dog_name: dog_name,
          disconnect: deviceConnector.disconnect,
        ),
      );
}


class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({
    required this.device,
    required this.dog_id,
    required this.dog_name,
    required this.disconnect,
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice device;
  final String dog_id;
  final String dog_name;
  final void Function(String deviceId) disconnect;
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          disconnect(device.id);
          return true;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(device.name.isNotEmpty ? device.name : "Unnamed"),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.bluetooth_connected,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.find_in_page_sharp,
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                DeviceInteractionTab(
                  device: device,
                  dog_id: dog_id,
                  dog_name: dog_name,
                ),
                const DeviceLogTab(),
              ],
            ),
          ),
        ),
      );
}
