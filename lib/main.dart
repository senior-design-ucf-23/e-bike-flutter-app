import 'package:flutter/material.dart';
import 'package:test_drive/pages/landingpage.dart';
import 'package:test_drive/pages/warning.dart';
import 'pages/newpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const ColorScheme normalColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 91, 81, 77),
      onPrimary: Color.fromARGB(255, 255, 236, 236),
      secondary: Color(0xFFBBBBBB),
      onSecondary: Color(0xFFEAEAEA),
      error: Color(0xFFF32424),
      onError: Color(0xFFF32424),
      background: Color.fromARGB(255, 255, 220, 133),
      onBackground: Color.fromARGB(255, 91, 81, 77),
      surface: Color(0xFF54B435),
      onSurface: Color(0xFF54B435),
    );
    const TextTheme normalTextTheme = TextTheme(
      displaySmall: TextStyle(color: Colors.red),
      displayMedium: TextStyle(color: Colors.red),
      displayLarge: TextStyle(color: Colors.red),
      titleLarge: TextStyle(color: Color.fromARGB(255, 255, 236, 235)),
      titleMedium: TextStyle(
        color: Color.fromARGB(255, 91, 81, 77),
        fontSize: 25.0,
      ),
      titleSmall: TextStyle(color: Colors.red),
      bodyLarge: TextStyle(
        color: Color.fromARGB(255, 242, 214, 203),
        fontSize: 15.0,
        height: 1.0,
      ),
      bodyMedium: TextStyle(
        color: Color.fromARGB(255, 91, 81, 77),
        fontSize: 15.0,
        height: 1.0,
      ),
      bodySmall: TextStyle(color: Colors.red),
      labelLarge: TextStyle(color: Colors.red),
      labelMedium: TextStyle(color: Colors.red),
      labelSmall:
          TextStyle(color: Color.fromARGB(255, 255, 236, 235), fontSize: 11.0),
    );
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: normalColorScheme.primary,
        accentColor: normalColorScheme.error,
        colorScheme: normalColorScheme,
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 220, 133),
        textTheme: normalTextTheme,
      ),
      home: const WarningPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = 'Flutter Demo Home Page';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title:
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Welcome to Group 12\'s E-Bike Application!',
                    style: Theme.of(context).textTheme.bodyMedium)),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Please do NOT use the application when riding.\nPress the button below to confirm you are not actively riding.\n(WE WILL KNOW)',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                )),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LandingPage()));
                },
                child: Text('I AM NOT RIDING',
                    style: Theme.of(context).textTheme.labelSmall)),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: _resetCounter,
              child: Text('Reset Counter',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const NewPage()));
                },
                child: Text('New Page',
                    style: Theme.of(context).textTheme.labelSmall)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
