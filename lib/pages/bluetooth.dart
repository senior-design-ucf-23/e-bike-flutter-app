import 'package:flutter/material.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  final String title = 'Bluetooth Connection';

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
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
                  child: Text('Back to Main Page',
                      style: Theme.of(context).textTheme.labelSmall),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ])));
  }
}
