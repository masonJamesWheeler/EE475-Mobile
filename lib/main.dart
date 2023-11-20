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
  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final connector = BleDeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final databaseService = DatabaseService(supabase: supabase);

  runApp(
    MultiProvider(
      providers: [
        Provider<FlutterReactiveBle>(create: (_) => ble),
        Provider<BleScanner>(create: (_) => scanner),
        Provider<BleDeviceConnector>(create: (_) => connector),
        Provider<supabase_provider.SupabaseClient>(create: (_) => supabase), // Add this line
        StreamProvider<BleScannerState>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
       Provider<DatabaseService>(create: (_) => databaseService),
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
        '/add-a-dog': (context) => const AddADogPage(),
      },
    );
  }
}
