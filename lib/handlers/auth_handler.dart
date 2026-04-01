import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';

/// The AuthHandler class handles the authentication command.
/// It checks if the provided username and password are valid and sets the client's authorization status accordingly.
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
        client
          ..send(
            CommandPacket(
              command: command,
              payload: "Invalid payload",
            ),
          )
          ..close();
      }

      // Check if the username and password are valid
      if (!validUsers.containsKey(payload["username"]) || validUsers[payload["username"]] != payload["password"]) {
        client
          ..send(
            CommandPacket(
              command: command,
              payload: "Invalid credentials",
            ),
          )
          ..close();

        return;
      }

      client
        ..isAuthorized = true
        ..send(
          CommandPacket(
            command: command,
            payload: "Authorized",
          ),
        );
    } catch (e) {
      log('Auth error: $e');
    }
  }
}
