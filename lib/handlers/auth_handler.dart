import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';

class AuthHandler extends Command {
  AuthHandler() : super("auth");

  final validUsers = {
    "test": "test",
  };

  @override
  Future<void> execute({
    required Client client,
    dynamic payload,
  }) async {
    try {
      // Check if the payload is a map
      if (payload is! Map<String, dynamic>) {
        client.socket
          ..add(CommandPacket(
            command: command,
            payload: "Invalid payload",
          ).toJson())
          ..close();
      }

      // Check if the username and password are valid
      if (!validUsers.containsKey(payload["username"]) || validUsers[payload["username"]] != payload["password"]) {
        client.socket
          ..add(CommandPacket(
            command: command,
            payload: "Invalid credentials",
          ).toJson())
          ..close();

        return;
      }

      client
        ..isAuthorized = true
        ..socket.add(
          CommandPacket(
            command: command,
            payload: "Authorized",
          ).toJson(),
        );
    } catch (e) {
      log('Auth error: $e');
    }
  }
}
