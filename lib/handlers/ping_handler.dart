import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';

/// The PingHandler class handles the ping command.
/// When a client sends a ping command, this handler responds with a pong message.
/// This is useful for checking the connectivity and latency between the client and the server.
class PingHandler extends Command {
  const PingHandler() : super("ping");

  @override
  Future<void> execute({
    required Client client,
    dynamic payload,
  }) async {
    try {
      client.send(
        CommandPacket(
          command: command,
          payload: "Pong",
        ),
      );
    } catch (e) {
      log('Ping error: $e');
    }
  }
}
