import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';
import 'package:server/socket_server.dart';

/// The ListHandler class handles the list command.
/// When a client sends a list command, this handler responds with a list of connected clients.
/// The response includes each client's ID, group, and authorization status.
class ListHandler extends Command {
  const ListHandler()
      : super(
          "list",
          authorizationRequired: true,
        );

  @override
  Future<void> execute({
    required Client client,
    dynamic payload,
  }) async {
    try {
      client.send(
        CommandPacket(
          command: command,
          payload: SocketServer.clients.map((c) => c.toMap()).toList(),
        ),
      );
    } catch (e) {
      log('List error: $e');
    }
  }
}
