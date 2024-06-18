import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../mqtt_service.dart'; // Import the MQTT service

class VideoStream extends StatefulWidget {
  const VideoStream({
    Key? key,
    required this.url,
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
  }) : super(key: key);

  final String url;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    if (widget.isConnected) {
      connect();
    }
  }

  @override
  void didUpdateWidget(VideoStream oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isConnected != widget.isConnected) {
      if (widget.isConnected) {
        connect();
      } else {
        disconnect();
      }
    }
  }

  void connect() {
    disconnect(); // Ensure any existing connection is closed before starting a new one
    setState(() {
      try {
        _channel =
            WebSocketChannel.connect(Uri.parse('ws://${widget.url}:5000'));
      } catch (e) {
        print('Error parsing port number: $e');
        _channel =
            WebSocketChannel.connect(Uri.parse('ws://192.168.43.55:5000'));
      }
    });
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }

  @override
  void dispose() {
    disconnect(); // Ensure the connection is closed when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            widget.isConnected && _channel != null
                ? StreamBuilder(
                    stream: _channel!.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        return const Center(
                          child: Text("Connection Closed!"),
                        );
                      }

                      return Image.memory(
                        Uint8List.fromList(
                          base64Decode(snapshot.data.toString()),
                        ),
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                      );
                    },
                  )
                : const Text("Initiate Connection"),
          ],
        ),
      ),
    );
  }
}
