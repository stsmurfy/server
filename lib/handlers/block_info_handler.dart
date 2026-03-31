import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/core/command.dart';
import 'package:server/models/command_packet.dart';

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
    try {
      client.socket.add(
        CommandPacket(
          command: command,
          payload: {
            "state": "n/a",
          },
        ).toJson(),
      );
    } catch (e) {
      log("BlockInfo error: $e");
    }
  }
}
