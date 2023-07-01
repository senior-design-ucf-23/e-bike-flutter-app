import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:location_permissions/location_permissions.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:speedometer/speedometer.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:test_drive/components/bt_packets.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class HUDPage extends StatefulWidget {
  final String title = 'Heads-Up-Display';
  late DiscoveredDevice myDevice;
  HUDPage({
    super.key,
    required this.myDevice,
  });

  @override
  State<HUDPage> createState() => _HUDPageState();
}

class _HUDPageState extends State<HUDPage> {
  final speed = PublishSubject<double>();
  // ________ CHANGE TO FALSE _____________
  bool _btstatus = true;
  bool _connected = false;
  String readTest = "";
  int battery = 69;

  RxPacket rx = RxPacket();
  TxPacket tx = TxPacket();

  final fbp = FlutterReactiveBle();
  late QualifiedCharacteristic characteristic;
  late DiscoveredDevice _myDevice = widget.myDevice;
  late StreamSubscription<DiscoveredDevice> _scanStream;
  final Uuid ebikeServiceUuid =
      Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB");
  final Uuid ebikeCharUuid = Uuid.parse("0000FFE1-0000-1000-8000-00805F9B34FB");
  final Uuid ebikeUuid = Uuid.parse("5F1A2977-C1F0-8EE5-EFD7-1EFD7B5FC029");
  late QualifiedCharacteristic _txCharacteristic;
  late QualifiedCharacteristic _rxCharacteristic;

  late Color dialogSelectColor;

  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };

  @override
  void initState() {
    super.initState();
    dialogSelectColor =
        Color.fromARGB(255, 149, 243, 33); //const Color(0xFFA239CA);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);

    //_startScan();
    //print("scan started");
    String toSplit1 = "speed:100,battery:50,throttle:0";
    String toSplit2 = "speed:50,battery:50,throttle:100";

    print(toSplit1.split(','));
    print(toSplit2.split(','));

    _connectToDevice();
    print("finished connect function");
  }

  int findColon(String s) {
    var index = 0;
    while (index != s.length - 1) {
      if (s[index] == ':') {
        return index;
      }
      index++;
    }
    return 0;
  }

  void translatePacket(String info) {
    var infoSplit = info.split(',');
    String name = 'default';
    String value = 'og';
    for (String s in infoSplit) {
      print(s);
      /*var colonPos = findColon(s);
      print('colon position: $colonPos');
      temp = s.substring(0, colonPos);*/
      var sSplit = s.split(':');
      print(sSplit);
      name = sSplit[0];
      value = sSplit[1];
      switch (name) {
        case 'speed':
          //temp = s.substring(colonPos + 1);
          // display speed

          print("speed:");
          print(value);
          setState(() {
            speed.add(double.parse(value));
          });
          break;
        case 'battery':
          //temp = s.substring(colonPos + 1);
          // display battery

          print("battery:");
          print(value);
          setState(() {
            battery = int.parse(value);
          });
          break;
        case 'input':
          //temp = s.substring(colonPos + 1);
          // display battery

          print("input:");
          print(value);
          break;
        case 'default':
          print(value);
          print('default');
          break;
        default:
          print(value);
          print('error: invalid switch value');
          break;
      }
    }
  }

  // write lights and mode update
  void writeUpdate() {
    if (_btstatus) {
      /*_ble.writeCharacteristicWithoutResponse(characteristic, value: [
        0x61,
      ]);*/
    }
  }

  void _receiveUpdate() {}

  void _startScan() {
    print("in scan");
    /*// handles platform permissions
    bool permGranted = false;
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) permGranted = true;
    } else if (Platform.isIOS) {
      permGranted = true;
    }*/

    print("after permissions");

    // main scanning logic
    //if (permGranted) {
    //print("in grant if");
    _scanStream = fbp.scanForDevices(withServices: []).listen((device) {
      print("after scan start");
      if (device.name == 'DSD TECH') {
        print("found device");
        setState(() {
          _myDevice = device;
        });
      }
    });
    //}
  }

  void _connectToDevice() {
    // _scanStream.cancel();
    Stream<ConnectionStateUpdate> currentConnectionStream = fbp
        .connectToAdvertisingDevice(
            id: _myDevice.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [ebikeServiceUuid, ebikeCharUuid]);
    print("in connect, connected");
    print(_myDevice.id);
    currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          {
            print("setting tx char");
            _txCharacteristic = QualifiedCharacteristic(
                serviceId: ebikeServiceUuid,
                characteristicId: ebikeCharUuid,
                deviceId: _myDevice.id);
            setState(() {
              _connected = true;
            });
            _partyTime2();
            print("receiving");
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

  void _partyTime2() {
    print("in party");
    var temp = "";
    if (Platform.isAndroid) {
      _rxCharacteristic = QualifiedCharacteristic(
          serviceId: ebikeServiceUuid,
          characteristicId: ebikeCharUuid,
          deviceId: _myDevice.id);
    } else if (Platform.isIOS) {
      _rxCharacteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse('ffe0'),
          characteristicId: Uuid.parse('ffe1'),
          deviceId: _myDevice.id);
    }

    print("after plat-spec");

    if (_connected) {
      print("in party if");
      fbp.subscribeToCharacteristic(_rxCharacteristic).listen((data) {
        print("in listen");
        for (int d in data) {
          temp += String.fromCharCode(d);
        }
        setState(() {
          readTest = "";
          readTest = temp;
          translatePacket(temp);
          temp = "";
        });
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: OrientationBuilder(builder: (context, orientation) {
          return _btstatus
              ? GridView.count(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                  children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Column(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Light color: ',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              )),
                          ColorIndicator(
                              width: 40,
                              height: 40,
                              borderRadius: 2,
                              hasBorder: true,
                              borderColor: Colors.black,
                              color: dialogSelectColor,
                              elevation: 1,
                              onSelectFocus: false,
                              onSelect: () async {
                                // Wait for the dialog to return color selection result.
                                final Color newColor =
                                    await showColorPickerDialog(
                                  // The dialog needs a context, we pass it in.
                                  context,
                                  // We use the dialogSelectColor, as its starting color.
                                  dialogSelectColor,
                                  title: Text('Light Color',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  width: 40,
                                  height: 40,
                                  spacing: 0,
                                  runSpacing: 0,
                                  borderRadius: 0,
                                  wheelDiameter: 140,
                                  enableOpacity: true,
                                  showColorCode: false,
                                  colorCodeHasColor: true,
                                  pickersEnabled: <ColorPickerType, bool>{
                                    ColorPickerType.wheel: true,
                                    ColorPickerType.primary: false,
                                    ColorPickerType.accent: false,
                                  },
                                  copyPasteBehavior:
                                      const ColorPickerCopyPasteBehavior(
                                    copyButton: false,
                                    pasteButton: false,
                                    longPressMenu: true,
                                  ),
                                  actionButtons: const ColorPickerActionButtons(
                                    okButton: true,
                                    closeButton: true,
                                    dialogActionButtons: false,
                                  ),
                                  transitionBuilder: (BuildContext context,
                                      Animation<double> a1,
                                      Animation<double> a2,
                                      Widget widget) {
                                    final double curvedValue = Curves
                                            .easeInOutBack
                                            .transform(a1.value) -
                                        1.0;
                                    return Transform(
                                      transform: Matrix4.translationValues(
                                          0.0, curvedValue * 200, 0.0),
                                      child: Opacity(
                                        opacity: a1.value,
                                        child: widget,
                                      ),
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                  constraints: const BoxConstraints(
                                      minHeight: 480,
                                      minWidth: 320,
                                      maxWidth: 320),
                                );
                                setState(() {
                                  dialogSelectColor = newColor;
                                });
                              }),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              'Update Lights',
                              style: Theme.of(context).textTheme.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              'Randomize Charge',
                              style: Theme.of(context).textTheme.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          _connected
                              ? ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Connected',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Not Connected',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        ]),
                      ),
                      Padding(
                          padding: EdgeInsets.all(35.0),
                          child: Wrap(
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                SpeedOMeter(
                                  start: 0,
                                  end: 20,
                                  highlightStart: 0.0,
                                  highlightEnd: 20.0,
                                  themeData: Theme.of(context),
                                  eventObservable: speed,
                                ),
                                Text('Speed',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge)
                              ])),
                      Padding(
                          padding: EdgeInsets.all(35.0),
                          child: Wrap(
                              runAlignment: WrapAlignment.center,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              direction: Axis.vertical,
                              children: <Widget>[
                                BatteryIndicator(
                                  batteryFromPhone: true,
                                  size: 70,
                                  style: BatteryIndicatorStyle.skeumorphism,
                                ),
                                Text(
                                  'Phone', //'$_phone',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 25),
                                BatteryIndicator(
                                  batteryFromPhone: false,
                                  batteryLevel: battery,
                                  size: 70,
                                  style: BatteryIndicatorStyle.skeumorphism,
                                ),
                                Text(
                                  'E-Bike',
                                  style: Theme.of(context).textTheme.titleLarge,
                                )
                              ])),
                    ])
              : GridView.count(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                  children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(35.0),
                          child: Text(
                            'Bluetooth not connected. Visit the "Bluetooth Connection" page and connect to e-bike first.',
                          )),
                    ]);
        }));
  }
}
