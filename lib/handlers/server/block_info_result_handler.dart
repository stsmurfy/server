import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';
import 'package:server/socket_server.dart';

class BlockInfoResultHandler extends Command {
  const BlockInfoResultHandler()
      : super(
          "blockinforesult",
          authorizationRequired: true,
        );

  @override
  Future<void> execute({
    required Client client,
    dynamic payload,
  }) async {
    // Check if the payload is a map and contains the required clientId field
    if (payload is! Map<String, dynamic> || !payload.containsKey("clientId")) {
      client
        ..send(
          CommandPacket(
            command: command,
            payload: "Invalid payload",
          ),
        )
        ..close();

      return;
    }

    try {
      SocketServer.sendTo(
        payload["clientId"],
        CommandPacket(
          command: "blockinfo",
          payload: payload,
        ),
      );
    } catch (e) {
      log("BlockInfoResult error: $e");
    }
  }
}
