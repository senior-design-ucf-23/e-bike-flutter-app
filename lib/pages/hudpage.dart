import 'dart:math';

import 'package:flutter/material.dart';

class HUDPage extends StatefulWidget {
  const HUDPage({super.key});

  final String title = 'Heads-Up-Display';

  @override
  State<HUDPage> createState() => _HUDPageState();
}

class _HUDPageState extends State<HUDPage> {
  int _speedometer = 0;

  void _randomizeSpeed() {
    setState(() {
      _speedometer = Random().nextInt(99);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('$_speedometer',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(
              'Press this button to randomize speed.',
            ),
            ElevatedButton(
                onPressed: () {
                  _randomizeSpeed();
                },
                child: Text('Randomize Speed')),
            Text(
              'Press this button to go home.',
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back'))
          ],
        ),
      ),
    );
  }
}
