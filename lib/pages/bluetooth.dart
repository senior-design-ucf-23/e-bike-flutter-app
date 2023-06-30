import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_drive/pages/hudpage.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:test_drive/components/bt_packets.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  final String title = 'Bluetooth Connection';

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  // instantiations
  FlutterBluePlus fbp = FlutterBluePlus.instance;
  TxPacket tx = TxPacket();
  RxPacket rx = RxPacket();

  // late variables, non-nullables initialized later
  late StreamSubscription<List<ScanResult>> discovers;
  late ScanResult dsdDevice;
  late List<BluetoothService> dsdServices;
  late BluetoothService dsdService;
  late List<BluetoothCharacteristic> dsdChars;
  late BluetoothCharacteristic dsdChar;

  // final variables
  final String ebikeServiceUuid = "0000FFE0-0000-1000-8000-00805F9B34FB";
  final String ebikeCharsUuid = "0000FFE1-0000-1000-8000-00805F9B34FB";
  final String ebikeUuid = "5F1A2977-C1F0-8EE5-EFD7-1EFD7B5FC029";

  // normal variables
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;
  String _btTestButton = "Hello there!";

  // connects to found device
  void _connectToDevice() async {
    await dsdDevice.device.connect();
    _connected = true;
  }

  // starts scan, finds device, and sets info to late variables
  void _startScan() async {
    setState(() {
      _btTestButton = "";
    });

    print("in scan");

    // Start scanning
    fbp.startScan(timeout: Duration(milliseconds: 100));
    print("first scan");
    fbp.stopScan();
    print("stopped first");
    fbp.startScan(timeout: Duration(seconds: 4));
    print("second scan");
    _scanStarted = true;

    // Listen to scan results
    discovers = fbp.scanResults.listen((results) {
      print("in result listener");
      for (ScanResult r in results) {
        //print('${r.device.name} found! rssi: ${r.rssi}');
        if (r.device.name == "DSD TECH") {
          print('${r.device.name} found!');
          _foundDeviceWaitingToConnect = true;
          dsdDevice = r;
          //selectService(await dsdDevice.device.discoverServices());
          //-- if above works, uncomment this --
          //selectCharacteristic(dsdService.characteristics);
        }
        setState(() {
          print("in set state");
          _btTestButton += "${r.device.name}, ${r.device.id.id}";
        });
      }
      print("after for loop");
    });

    // Stop scanning
    fbp.stopScan();
    print("second scan stopped");

    /*
    fbp.startScan(timeout: Duration(seconds: 4));

    var subscription = fbp.scanResults.listen((results) {
      for (ScanResult r in results) {
        setState(() {
          _btTestButton =
              '$_btTestButton\n ${r.device.name}, ${r.device.id.id}';
        });
        if (r.device.name == "DSD TECH") {
          print('${r.device.name} found!');
          _foundDeviceWaitingToConnect = true;
          dsdDevice = r;
          //selectService(await dsdDevice.device.discoverServices());
          //-- if above works, uncomment this --
          //selectCharacteristic(dsdService.characteristics);
        }
      }
    });

    fbp.stopScan();*/
  }

  @override
  void dispose() {
    super.dispose();
    fbp.stopScan();
  }

  // stops scan of devices
  void stopScan() {
    setState(() {
      fbp.stopScan();
      _scanStarted = false;
      print("scan stopped");
    });
  }

  // if bt module service uuid is in list, will find and set
  void selectService(List<BluetoothService> services) {
    for (BluetoothService s in services) {
      print(s.uuid);
      if (s.uuid == Guid(ebikeServiceUuid)) {
        dsdService = s;
      }
    }
  }

  // if bt module characteristic uuid is in list, will find and set
  void selectCharacteristic(List<BluetoothCharacteristic> chars) {
    for (BluetoothCharacteristic c in chars) {
      print(c.uuid);
      if (c.uuid == Guid(ebikeCharsUuid)) {
        dsdChar = c;
      }
    }
  }

  // write to bt module characteristic
  // currently writes just ascii value for 'a' for LED toggling
  void _partyTime() async {
    dsdChars = dsdService.characteristics;
    for (BluetoothCharacteristic c in dsdChars) {
      if (c.uuid == Guid(ebikeCharsUuid)) {
        await c.write([0x61]);
      }
    }
  }

  // reads bt module characteristic (there's only one)
  // currently reads the first value sent, turns into string,
  // and sets it to the value of the button pressed
  // ** there should only be one value sent as of now anyway **
  void _partyTime2() async {
    dsdChars = dsdService.characteristics;
    for (BluetoothCharacteristic c in dsdChars) {
      if (c.uuid == Guid(ebikeCharsUuid)) {
        List<int> read = await c.read();
        _btTestButton = read[0].toString();
        print(read);
      }
    }
  }

  // __________________ SAMPLE CBCENTRALMANAGER CHECKING CODE _________________

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/bluetooth');

  static const MethodChannel methodChannel =
      MethodChannel('method.flutter.io/bluetooth');

  String _bluetoothStatus = 'Bluetooth status: ';

  String _bleState = 'not';

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _getBluetoothState();
    _centralManagerDidUpdateState();
  }

  void _onEvent(Object? event) {
    setState(() {
      _bluetoothStatus = "Bluetooth status: ${event == 'on' ? 'on' : 'off'}";
    });
  }

  void _onError(Object error) {
    setState(() {
      _bluetoothStatus = 'Battery status: unknown.';
    });
  }

  Future<void> _getBluetoothState() async {
    String bluetoothState;
    try {
      final String? result =
          await methodChannel.invokeMethod('getBluetoothState');
      bluetoothState = '$result%.';
    } on PlatformException {
      bluetoothState = 'Failed to get battery level.';
    }
    setState(() {
      _bleState = bluetoothState;
    });
  }

  Future<void> _centralManagerDidUpdateState() async {
    String cbState;
    try {
      final String? result =
          await methodChannel.invokeMethod('centralManagerDidUpdateState');
      cbState = '$result%.';
    } on PlatformException {
      cbState = 'Failed to get battery level.';
    }
    setState(() {
      _bleState = cbState;
    });
  }

  // __________________________________________________________________________

  /* Old bluetooth code, if new works, delete all this

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
  */

  @override

  /* placeholder initState; inits lights to yellow and mode to 0
  void initState() {
    super.initState();
    tx.bikeMode = 0;
    tx.lightsAlpha = 0xFF;
    tx.lightsBlue = 0x00;
    tx.lightsGreen = 0xFF;
    tx.lightsRed = 0xFF;
  }*/

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
                              onPressed: stopScan,
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // foreground
                      ),
                      onPressed: stopScan,
                      child: const Icon(Icons.stop),
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
                ElevatedButton(
                  onPressed: _partyTime2,
                  child: Text('Read Test',
                      style: Theme.of(context).textTheme.labelSmall),
                ),
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
                Padding(
                    padding: EdgeInsets.all(35.0),
                    child: Text(
                      '$_btTestButton',
                    )),
                Padding(
                    padding: EdgeInsets.all(35.0),
                    child: Text(
                      '$_bluetoothStatus',
                    )),
                Padding(
                    padding: EdgeInsets.all(35.0),
                    child: Text(
                      '$_bleState',
                    )),
              ]),
        ));
  }
}
