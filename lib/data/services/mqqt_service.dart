import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/waste_status_model.dart';

/// MQTT service for real-time communication with ESP32
///
/// This service:
/// - Connects to MQTT broker
/// - Subscribes to waste status topic
/// - Emits WasteStatusModel updates as a stream
class MqttService {
  late final MqttServerClient _client;
  final StreamController<WasteStatusModel> _controller =
  StreamController.broadcast();

  /// Stream of waste status updates (real-time)
  Stream<WasteStatusModel> get wasteStatusStream => _controller.stream;

  /// MQTT configuration (adjust as per your broker)
  static const String _broker = 'test.mosquitto.org';
  static const int _port = 1883;
  static const String _clientId = 'westo_flutter_client';
  static const String _topic = 'westo/waste/status';

  /// Connect to MQTT broker
  Future<void> connect() async {
    _client = MqttServerClient(_broker, _clientId);
    _client.port = _port;
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);

    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e) {
      _client.disconnect();
      rethrow;
    }

    _client.updates?.listen(_onMessage);
  }

  /// Subscribe after successful connection
  void _onConnected() {
    _client.subscribe(_topic, MqttQos.atLeastOnce);
  }

  void _onDisconnected() {
    // Can be used for reconnection logic later
  }

  /// Handle incoming MQTT messages
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    final recMessage = events.first.payload as MqttPublishMessage;
    final payload =
    MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

    final Map<String, dynamic> jsonMap = json.decode(payload);

    final model = WasteStatusModel.fromJson(jsonMap);

    _controller.add(model);
  }

  /// Disconnect and clean resources
  void disconnect() {
    _controller.close();
    _client.disconnect();
  }
}
