import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';
import 'package:server/socket_server.dart';

class BlockInfoHandler extends Command {
  const BlockInfoHandler()
      : super(
          "blockinfo",
          authorizationRequired: true,
        );

  @override
  Future<void> execute({
    required Client client,
    dynamic payload,
  }) async {
    // Check if the payload is a map and contains the required serverId field
    if (payload is! Map<String, dynamic> || !payload.containsKey("serverId")) {
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
        payload["serverId"],
        CommandPacket(
          command: command,
          payload: {
            "clientId": client.id,
          },
        ),
      );
    } catch (e) {
      log("BlockInfo error: $e");
    }
  }
}
