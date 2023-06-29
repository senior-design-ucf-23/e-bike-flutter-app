import 'package:flutter/material.dart';
import 'package:test_drive/pages/bluetooth.dart';
import 'package:test_drive/pages/landingpage.dart';

class WarningPage extends StatefulWidget {
  const WarningPage({super.key});

  final String title = 'New Page';

  @override
  State<WarningPage> createState() => _WarningPageState();
}

class _WarningPageState extends State<WarningPage> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Color.fromARGB(255, 91, 81, 77),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'WARNING',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    )),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Using this application while operating the e-bike is strongly disadvised.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'While it is not illegal, it puts not only yourself in danger, but also those around you.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'If currently operating e-bike, please come to a complete stop before continuing.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Thank you for your cooperation.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.background),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LandingPage()));
                    },
                    child: Text('I AM NOT RIDING')),
              ]),
        ),
      )),
    );
  }
}
