import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';

class PingHandler extends Command {
  const PingHandler() : super("ping");

  @override
  Future<void> execute({
    required Client client,
    dynamic payload,
  }) async {
    try {
      client.socket.add(
        CommandPacket(
          command: command,
          payload: "Pong",
        ).toJson(),
      );
    } catch (e) {
      log('Ping error: $e');
    }
  }
}
