import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  final String title = 'Bluetooth Connection';

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;

  late DiscoveredDevice _myDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late QualifiedCharacteristic _rxCharacteristic;

  final Uuid serviceUuid = Uuid.parse("75C276C3-8F97-20BC-A143-B354244886D4");
  final Uuid characteristicUuid =
      Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");

  void _startScan() async {
    // handles platform permissions
    bool permGranted = false;
    setState(() {
      _scanStarted = true;
    });
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) permGranted = true;
    } else if (Platform.isIOS) {
      permGranted = true;
    }

    // main scanning logic
    if (permGranted) {
      _scanStream = flutterReactiveBle
          .scanForDevices(withServices: [serviceUuid]).listen((device) {
        // Change this string to what you defined in Zephyr
        if (device.name == 'TEST') {
          setState(() {
            _myDevice = device;
            _foundDeviceWaitingToConnect = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title,
                style: Theme.of(context).textTheme.titleLarge)),
        body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Welcome to the Bluetooth Connection Page',
                      style: Theme.of(context).textTheme.bodyMedium)),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Here will be Bluetooth Connection Status as well as pairing instructions.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  )),
              ElevatedButton(
                  child: Text('Go to Bluetooth Settings',
                      style: Theme.of(context).textTheme.labelSmall),
                  onPressed: () {
                    AppSettings.openBluetoothSettings();
                  }),
              ElevatedButton(
                  child: Text('Back to Main Page',
                      style: Theme.of(context).textTheme.labelSmall),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ])));
  }
}
