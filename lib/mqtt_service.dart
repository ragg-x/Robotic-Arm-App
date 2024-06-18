import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  Function(String)? onMessageReceived;
  String _latestIpMessage = '';

  MqttService({this.onMessageReceived});

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
  }

  Future<void> _connectClient() async {
    try {
      print('client connecting....');
      await client.connect('raghav9003', 'Raghav@9003');
    } on Exception catch (e) {
      print('client exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('client connected');
      _subscribeToTopics(); // Subscribe after connection is established
    } else {
      print(
          'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void _setupMqttClient() {
    client = MqttServerClient.withPort(
        '1b2a6ee3090842609cad24a049d86c2b.s1.eu.hivemq.cloud', 'ARM', 8883);
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
  }

  void _subscribeToTopics() {
    _subscribeToTopic('ip');
  }

  void _subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      var message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Message received on $topicName: $message');
      if (onMessageReceived != null) {
        onMessageReceived!(message);
      }
    });
  }

  void publishMessage(String topic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);

      print('Publishing message "$message" to topic $topic');
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('ERROR: Client is not connected. Cannot publish message.');
    }
  }

  String get latestIpMessage => _latestIpMessage;

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
  }

  void _onConnected() {
    print('OnConnected client callback - Client connection was successful');
  }
}
