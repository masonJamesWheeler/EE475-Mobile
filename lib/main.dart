/// This file contains the main entry point of the application and the root widget [MyApp].
/// It imports necessary packages and initializes the Supabase client, FlutterReactiveBle,
/// and other services. The [MyApp] widget is responsible for setting up the application's
/// theme and defining the routes for different pages.
import 'package:ee475_mobile/ble/ble_device_interactor.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_provider;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'database_service.dart';

import 'ble/ble_logger.dart';
import 'ble/ble_device_connector.dart';
import 'ble/ble_scanner.dart';
import 'ble/ble_status_monitor.dart';

import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/account_page.dart';
import 'pages/add_a_dog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await supabase_provider.Supabase.initialize(
    url: 'https://zisysdvhxncmwqwsiuyo.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inppc3lzZHZoeG5jbXdxd3NpdXlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU5NTQ3NDEsImV4cCI6MjAxMTUzMDc0MX0.OSpXd1SR1PYx-nt2LsFcFYQpRovCZCFjJF1oJlMWbAY',
  );

  final supabase = supabase_provider.Supabase.instance.client;
  // Bluetooth related initializations
  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final connector = BleDeviceConnector(ble: ble, logMessage: bleLogger.addToLog);
  final deviceInteractor = BleDeviceInteractor(bleDiscoverServices: ble.getDiscoveredServices, logMessage: bleLogger.addToLog);
  final authState = AuthState(); // Create an instance of AuthState


  runApp(
    MultiProvider(
      providers: [
        Provider<FlutterReactiveBle>(create: (_) => ble),
        Provider<BleLogger>(create: (_) => bleLogger),
        Provider<BleScanner>(create: (_) => scanner),
        Provider<BleDeviceConnector>(create: (_) => connector),
        Provider<BleStatusMonitor>(create: (_) => monitor),
        Provider<BleDeviceInteractor>(create: (_) => deviceInteractor),
        StreamProvider<BleScannerState?>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),        
        ),
        ChangeNotifierProvider(create: (_) => authState),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(supabase: supabase, authState: authState),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/account': (context) => const AccountPage(),
      },
    );
  }
}
