import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/models/command_packet.dart';

abstract class Command {
  const Command(
    this.command, {
    this.authorizationRequired = false,
  });

  final String command;
  final bool authorizationRequired;

  Future<void> run({
    required Client client,
    dynamic payload,
  }) async {
    // Check if the client is authorized
    if (authorizationRequired && !client.isAuthorized) {
      try {
        log("Unauthorized command: $command");

        // Send an error message
        client.socket.add(
          CommandPacket(
            command: command,
            payload: "Unauthorized",
          ).toJson(),
        );
      } catch (e) {
        log("Unauthorized command error: $e");
      }
    } else {
      execute(
        client: client,
        payload: payload,
      );
    }
  }

  Future<void> execute({
    required Client client,
    dynamic payload,
  });
}
