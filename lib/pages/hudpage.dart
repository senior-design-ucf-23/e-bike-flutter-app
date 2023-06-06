import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:speedometer/speedometer.dart';

class HUDPage extends StatefulWidget {
  const HUDPage({super.key});

  final String title = 'Heads-Up-Display';

  @override
  State<HUDPage> createState() => _HUDPageState();
}

class _HUDPageState extends State<HUDPage> {
  final speed = PublishSubject<double>();
  final charge = PublishSubject<double>();

  void _randomizeSpeed() {
    setState(() {
      speed.add(90);
    });
  }

  void _randomizeCharge() {
    setState(() {
      charge.add(Random().nextInt(100).toDouble());
    });
  }

  void _yaAuntie() {
    setState(() {
      speed.add(69);
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: OrientationBuilder(builder: (context, orientation) {
          return GridView.count(
              crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(children: <Widget>[
                    ElevatedButton(
                      onPressed: () => _randomizeSpeed(),
                      child: Text(
                        'Randomize Speed',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _randomizeCharge(),
                      child: Text(
                        'Randomize Charge',
                        style: Theme.of(context).textTheme.labelSmall,
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
                              style: Theme.of(context).textTheme.bodyLarge)
                        ])),
                Padding(
                    padding: EdgeInsets.all(35.0),
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          SpeedOMeter(
                            start: 0,
                            end: 100,
                            highlightStart: 0.0,
                            highlightEnd: 100.0,
                            themeData: ThemeData(
                                primaryColor: Colors.green,
                                accentColor: Colors.red),
                            eventObservable: charge,
                          ),
                          Text(
                            'Charge',
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        ])),
              ]);
        }));
  }
}
