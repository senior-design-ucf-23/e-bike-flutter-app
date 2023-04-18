import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_drive/pages/bluetooth.dart';
import 'package:test_drive/pages/hudpage.dart';
import 'newpage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  final String title = 'Home Page';

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title,
                style: Theme.of(context).textTheme.titleLarge)),
        body: OrientationBuilder(builder: (context, orientation) {
          return GridView.count(
              crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: ElevatedButton(
                      child: Text(
                        'Bluetooth Connection',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BluetoothPage()));
                      }),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: ElevatedButton(
                      child: Text(
                        'Heads Up Display Mode',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HUDPage()));
                      }),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: ElevatedButton(
                      child: Text(
                        'Party Time',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => NewPage()));
                      }),
                ),
              ]);
        }));
  }
}
