import 'dart:developer';
import 'dart:io';

import 'package:server/models/command_packet.dart';
import 'package:uuid/uuid.dart';

/// The Client class represents a connected WebSocket client.
/// It encapsulates the WebSocket connection and provides methods for sending and closing the connection.
/// The class also maintains the client's authorization status and group membership for targeted broadcasting.
/// Example usage:
/// ```dart
/// final client = Client(socket: webSocket);
/// client.send(CommandPacket(command: "ping", payload: null));
/// client.close();
/// ```
class Client {
  Client({
    required WebSocket socket,
    this.group,
  }) : _socket = socket;

  final WebSocket _socket;
  final String id = Uuid().v4();
  String? group;
  bool isAuthorized = false;

  /// Returns a map representation of the client's information.
  /// The map includes the client's ID, group, and authorization status.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "group": group,
      "isAuthorized": isAuthorized,
    };
  }

  /// Send a command packet to the client.
  /// Handles JSON encoding and error logging internally.
  /// [CommandPacket] is the expected format for data, ensuring consistency across handlers.
  /// Errors during sending are caught and logged without throwing exceptions to the caller.
  /// Example usage:
  /// ```dart
  /// client.send(CommandPacket(command: "update", payload: {"status": "ok"}));
  /// ```
  void send(CommandPacket data) {
    try {
      _socket.add(data.toJson());
    } catch (e) {
      log("Client send error: $e");
    }
  }

  /// Close the WebSocket connection.
  /// This method should be called when the client disconnects or when the server needs to terminate the connection.
  /// Errors during closing are caught and logged without throwing exceptions to the caller.
  /// Example usage:
  /// ```dart
  /// client.close();
  /// ```
  void close() {
    _socket.close();
  }
}
