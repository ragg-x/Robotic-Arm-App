import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../mqtt_service.dart'; // Import the MQTT service

class WebSocket {
  // ------------------------- Members ------------------------- //
  late String url;
  late MqttService mqttService; // Instance of MqttService
  WebSocketChannel? _channel;
  StreamController<bool> streamController = StreamController<bool>.broadcast();

  // ---------------------- Getter Setters --------------------- //
  String get getUrl => url;

  set setUrl(String url) {
    this.url = url;
  }

  Stream<dynamic> get stream {
    if (_channel != null) {
      return _channel!.stream;
    } else {
      throw WebSocketChannelException("The connection was not established!");
    }
  }

  // --------------------- Constructor ---------------------- //
  WebSocket(this.mqttService) {
    // Subscribe to the 'ip' topic and listen for changes
    mqttService.onMessageReceived = (message) {
      updateUrl(message);
    };
    mqttService.prepareMqttClient();
  }

  // ---------------------- Functions ----------------------- //

  /// Updates the WebSocket URL
  void updateUrl(String newUrl) {
    url = newUrl;
    print('WebSocket URL updated: $url');
  }

  /// Connects the current application to a websocket
  void connect() {
    if (_channel == null) {
      print("ws://" + url + ':5000');

      _channel = WebSocketChannel.connect(Uri.parse("ws://" + url + ':5000'));
      print("WebSocket connection established.");
    } else {
      print("WebSocket is already connected.");
    }
  }

  /// Disconnects the current application from a websocket
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway).then((_) {
        print("WebSocket connection closed.");
        _channel = null;
      }).catchError((error) {
        print("Error closing WebSocket connection: $error");
      });
    } else {
      print("WebSocket is already disconnected.");
    }
  }
}
