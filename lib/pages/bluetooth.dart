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

  String _btstatus = "hello";

  void _startScan() async {
    // handles platform permissions
    bool permGranted = false;
    setState(() {
      _scanStarted = true;
      _btstatus = "scan started";
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
      setState(() {
        _btstatus = "searching...";
      });
      _scanStream = flutterReactiveBle
          .scanForDevices(withServices: [serviceUuid]).listen((device) {
        // Change this string to what you defined in Zephyr
        if (device.name == 'TEST') {
          setState(() {
            _btstatus = "device found";
            _myDevice = device;
            _foundDeviceWaitingToConnect = true;
          });
        }
      });
    }
  }

  void _partyTime() {
    if (_connected) {
      flutterReactiveBle
          .writeCharacteristicWithResponse(_rxCharacteristic, value: [
        0xff,
      ]);
    }
  }

  void _connectToDevice() {
    // We're done scanning, we can cancel it
    _scanStream.cancel();
    // Let's listen to our connection so we can make updates on a state change
    Stream<ConnectionStateUpdate> currentConnectionStream = flutterReactiveBle
        .connectToAdvertisingDevice(
            id: _myDevice.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [serviceUuid, characteristicUuid]);
    currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        // We're connected and good to go!
        case DeviceConnectionState.connected:
          {
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: event.deviceId);
            setState(() {
              _foundDeviceWaitingToConnect = false;
              _connected = true;
            });
            break;
          }
        // Can add various state state updates on disconnect
        case DeviceConnectionState.disconnected:
          {
            break;
          }
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String _status = "NOT CONNECTED";

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
                  'Here is the Bluetooth Connection status as well as pairing instructions.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                )),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Welcome to the Bluetooth Connection Page',
                    style: Theme.of(context).textTheme.bodyMedium)),
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
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  '$_btstatus',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                )),
          ])),
      persistentFooterButtons: [
        _scanStarted
            // True condition
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () {},
                child: const Icon(Icons.search),
              )
            // False condition
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: _startScan,
                child: const Icon(Icons.search),
              ),
        _foundDeviceWaitingToConnect
            // True condition
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: _connectToDevice,
                child: const Icon(Icons.bluetooth),
              )
            // False condition
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () {},
                child: const Icon(Icons.bluetooth),
              ),
        _connected
            // True condition
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: _partyTime,
                child: const Icon(Icons.celebration_rounded),
              )
            // False condition
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () {},
                child: const Icon(Icons.celebration_rounded),
              ),
      ],
    );
  }
}
