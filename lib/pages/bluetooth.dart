import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:test_drive/components/device_data.dart';
import 'package:test_drive/pages/hudpage.dart';

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

  late DeviceData deviceData;
  late DiscoveredDevice _myDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late QualifiedCharacteristic _rxCharacteristic;

  final deviceNames = <String>[];
  final Uuid ebikeServiceUuid =
      Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB");
  final Uuid ebikeCharUuid = Uuid.parse("0000FFE1-0000-1000-8000-00805F9B34FB");
  final Uuid ebikeUuid = Uuid.parse("5F1A2977-C1F0-8EE5-EFD7-1EFD7B5FC029");

  final deviceInfo = <String>[];

  String _devices = "";
  String temp = "";

  void _startScan() async {
    int index = 0;
    // handles platform permissions
    bool permGranted = false;
    setState(() {
      _scanStarted = true;
      _devices = "scan started";
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
        _devices = "";
      });
      _scanStream =
          flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        if (!deviceInfo.contains(device.name)) {
          temp = "${device.name}, ${device.id}\n";
          deviceInfo.add(device.name);
          deviceInfo.add(device.id.toString());
          setState(() {
            _devices += temp;
          });
          index++;
        }
        if (device.name == 'DSD TECH') {
          setState(() {
            _myDevice = device;
            deviceData = DeviceData(device);
            _devices = deviceData.toString();
            _foundDeviceWaitingToConnect = true;
          });
        }
      });
    }
  }

  void _partyTime() {
    if (_connected) {
      flutterReactiveBle
          .writeCharacteristicWithoutResponse(_rxCharacteristic, value: [
        0x61,
      ]);
    }
  }

  void _connectToDevice() {
    _scanStream.cancel();
    Stream<ConnectionStateUpdate> currentConnectionStream = flutterReactiveBle
        .connectToAdvertisingDevice(
            id: _myDevice.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [ebikeServiceUuid, ebikeCharUuid]);
    currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          {
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: ebikeServiceUuid,
                characteristicId: ebikeCharUuid,
                deviceId: _myDevice.id);
            setState(() {
              _foundDeviceWaitingToConnect = false;
              _connected = true;
            });
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            _connected = false;
            break;
          }
        default:
      }
    });
  }

  void disconnect() {
    setState(() {});
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
                    child: Text(
                      'Instructions for Bluetooth Connection:',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    )),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      '1. Ensure you are in close proximity of e-bike.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    )),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text.rich(TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '2. Tap ',
                          ),
                          WidgetSpan(child: Icon(Icons.search)),
                          TextSpan(
                              text: ' to search for the e-bike\'s signal.'),
                        ]))),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text.rich(TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '3. When ',
                          ),
                          WidgetSpan(child: Icon(Icons.bluetooth)),
                          TextSpan(
                              text:
                                  ' is blue, tap it to connect to the e-bike.'),
                        ]))),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text.rich(TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '4. If connected,  ',
                          ),
                          WidgetSpan(child: Icon(Icons.celebration_rounded)),
                          TextSpan(text: ' will turn blue. Tap to test.'),
                        ]))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: _scanStarted
                          // True condition
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
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
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: _foundDeviceWaitingToConnect
                          // True condition
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _connectToDevice,
                              child: const Icon(Icons.bluetooth),
                            )
                          // False condition
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {},
                              child: const Icon(Icons.bluetooth),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: _connected
                          // True condition
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _partyTime,
                              child: const Icon(Icons.celebration_rounded),
                            )
                          // False condition
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {},
                              child: const Icon(Icons.celebration_rounded),
                            ),
                    ),
                  ],
                ),
                ElevatedButton(
                    child: Text('Go to Bluetooth Settings',
                        style: Theme.of(context).textTheme.labelSmall),
                    onPressed: () {
                      AppSettings.openBluetoothSettings();
                    }),
                _connected
                    ? Column(children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'CONNECTED',
                              style: Theme.of(context).textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            )),
                        ElevatedButton(
                            child: Text('Go to HUD',
                                style: Theme.of(context).textTheme.labelSmall),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HUDPage(/*deviceData: deviceData*/),
                                ),
                              );
                            })
                      ])
                    : Column(children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'NOT CONNECTED',
                              style: Theme.of(context).textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            )),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HUDPage(/*deviceData: deviceData*/),
                                ));
                          },
                          child: Text('Go to HUD',
                              style: Theme.of(context).textTheme.labelSmall),
                        )
                      ]),
              ]),
        ));
  }
}
