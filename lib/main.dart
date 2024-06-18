import 'package:flutter/material.dart';
import 'mqtt_service.dart';
import 'package:provider/provider.dart';
import 'theme.dart'; // Import the ThemeNotifier
import 'VideoStream/VideoStreaming.dart'; // Import the VideoStream widget

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeNotifier.currentTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: themeNotifier.isDarkMode
                ? const TextTheme(
                    bodyMedium: TextStyle(color: Colors.white),
                    headlineMedium: TextStyle(color: Colors.white),
                    headlineSmall: TextStyle(color: Colors.white),
                  )
                : const TextTheme(
                    bodyMedium: TextStyle(color: Colors.black),
                    headlineMedium: TextStyle(color: Colors.black),
                    headlineSmall: TextStyle(color: Colors.black),
                  ),
          ),
          home: const MyHomePage(title: 'ROBOTIC ARM'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MqttService mqttService;
  final List<String> topics = ['servo1', 'servo2', 'servo3', 'servo4'];
  final Map<String, int> counterMap = {
    'servo1': 0,
    'servo2': 90,
    'servo3': 180,
    'servo4': 70,
  };
  int allServosValue = 0;
  bool _isConnected = false;
  String _url = ""; // Initialize URL with an empty string

  @override
  void initState() {
    super.initState();
    mqttService = MqttService(onMessageReceived: _onMessageReceived);
    mqttService.prepareMqttClient();
  }

  void _onMessageReceived(String msg) {
    setState(() {
      var parts = msg.split(':');
      if (parts.length == 2) {
        var topic = parts[0];
        var value = int.tryParse(parts[1]);
        if (value != null && counterMap.containsKey(topic)) {
          counterMap[topic] = value;
        }
      } else {
        _url = msg; // Update URL if message contains the URL
        if (_isConnected) {
          _connect();
        }
      }
    });
  }

  void _incrementAllServosValue() {
    setState(() {
      allServosValue = (allServosValue + 5).clamp(0, 100);
    });
  }

  void _decrementAllServosValue() {
    setState(() {
      allServosValue = (allServosValue - 5).clamp(0, 100);
    });
  }

  void _incrementCounter(String topic) {
    if (counterMap[topic]! < 180) {
      setState(() {
        counterMap[topic] = (counterMap[topic]! + allServosValue).clamp(0, 180);
      });
      _publishCounterValue(topic);
    }
  }

  void _decrementCounter(String topic) {
    if (counterMap[topic]! > 0) {
      setState(() {
        counterMap[topic] = (counterMap[topic]! - allServosValue).clamp(0, 180);
      });
      _publishCounterValue(topic);
    }
  }

  void _publishCounterValue(String topic) {
    mqttService.publishMessage(topic, counterMap[topic]!.toString());
    print('Published counter value: ${counterMap[topic]}');
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        _connect();
      } else {
        _disconnect();
      }
    });
  }

  void _connect() {
    // Implement the WebSocket connection logic
  }

  void _disconnect() {
    // Implement the WebSocket disconnection logic
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.inversePrimary;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  _isConnected ? Icons.videocam_off : Icons.videocam,
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: _toggleConnection,
                padding: EdgeInsets.all(8), // Reduce the padding
                constraints: BoxConstraints(), // Remove constraints
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22, // Reduce the font size
                  fontWeight: FontWeight.bold,
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: themeNotifier.toggleTheme,
                padding: EdgeInsets.all(8), // Reduce the padding
                constraints: BoxConstraints(), // Remove constraints
              ),
            ),
          ],
        ),
        toolbarHeight: 50, // Reduce the toolbar height
      ),
      body: Column(
        children: [
          Expanded(
            child: VideoStream(
              url: _url,
              isConnected: _isConnected,
              onConnect: _connect,
              onDisconnect: _disconnect,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  onPressed: _decrementAllServosValue,
                  tooltip: 'Decrement All',
                  backgroundColor: buttonColor,
                  child: const Icon(Icons.remove),
                  //mini: true,
                ),
                Column(
                  children: [
                    Text(
                      'Step Angle',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 19),
                    ),
                    Text(
                      '$allServosValue',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontSize: 26),
                    ),
                  ],
                ),
                FloatingActionButton(
                  onPressed: _incrementAllServosValue,
                  tooltip: 'Increment All',
                  backgroundColor: buttonColor,
                  child: const Icon(Icons.add),
                  //mini: true,
                ),
              ],
            ),
          ),
          for (final topic in topics)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () => _decrementCounter(topic),
                    tooltip: 'Decrement',
                    backgroundColor: buttonColor,
                    child: const Icon(Icons.remove),
                    //mini: true,
                  ),
                  Column(
                    children: [
                      Text(
                        'Servo ${topics.indexOf(topic) + 1}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 20),
                      ),
                      Text(
                        '${counterMap[topic]}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 26),
                      ),
                    ],
                  ),
                  FloatingActionButton(
                    onPressed: () => _incrementCounter(topic),
                    tooltip: 'Increment',
                    backgroundColor: buttonColor,
                    child: const Icon(Icons.add),
                    //mini: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
