import 'package:flutter/material.dart';
import '../mqtt_service.dart';

class MqttServiceSingleton {
  static final MqttServiceSingleton _instance =
      MqttServiceSingleton._internal();

  late MqttService mqttService;

  factory MqttServiceSingleton() {
    return _instance;
  }

  MqttServiceSingleton._internal() {
    mqttService = MqttService();
    mqttService.prepareMqttClient();
  }
}

class Styles {
  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    primary: Colors.blue, // Updated parameter
    textStyle: const TextStyle(
      color: Colors.white,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 20.0,
      vertical: 10.0,
    ),
  );
}
