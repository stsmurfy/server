import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:server/core/client.dart';
import 'package:server/handlers/auth_handler.dart';
import 'package:server/handlers/ping_handler.dart';
import 'package:server/models/command_packet.dart';

class SocketServer {
  static final handlers = [
    PingHandler(),
    AuthHandler(),
  ];
  static final clients = <Client>[];

  static start() async {
    final env = DotEnv(includePlatformEnvironment: false)..load();

    try {
      late final HttpServer server;

      if (env['ssl_certificate'] != null && env['ssl_private_key'] != null) {
        log("Starting secure server...");

        server = await HttpServer.bindSecure(
          env['address'] ?? '0.0.0.0',
          int.parse(env['port'] ?? '8181'),
          SecurityContext()
            ..useCertificateChain(env['ssl_certificate'] ?? '')
            ..usePrivateKey(env['ssl_private_key'] ?? ''),
        );
      } else {
        log("Starting insecure server...");

        server = await HttpServer.bind(
          env['address'] ?? '0.0.0.0',
          int.parse(env['port'] ?? '8181'),
        );
      }

      log('WebSocket server started on port ${server.port}');

      server.listen((request) {
        try {
          if (WebSocketTransformer.isUpgradeRequest(request)) {
            WebSocketTransformer.upgrade(request).then((socket) {
              log('Client connected.');

              final client = Client(socket: socket);

              clients.add(client);

              socket.listen(
                (message) async {
                  try {
                    final decoded = jsonDecode(message);
                    final cmd = CommandPacket.fromMap(decoded);

                    for (final handler in handlers) {
                      if (handler.command == cmd.command) {
                        int tries = 0;

                        log('Command found: ${handler.command}');

                        do {
                          try {
                            await handler.execute(
                              client: client,
                              payload: cmd.payload,
                            );
                            tries = 0;
                          } catch (e) {
                            if (++tries > 3) {
                              log('Too many attempts. Skipping...');
                              break;
                            }
                            log('Executing error. Trying again... ($tries)');
                          }
                        } while (tries > 0);
                        break;
                      }
                    }
                  } catch (e, stack) {
                    log('Message handling error: $e\n$stack');
                  }
                },
                onDone: () {
                  log('Client disconnected.');
                  clients.remove(client);
                },
                onError: (e) {
                  log('Client socket error: $e');
                  clients.remove(client);
                },
                cancelOnError: false,
              );
            }).catchError((e) {
              log('WebSocket upgrade failed: $e');
            });
          }
        } catch (e) {
          log('Server listen exception: $e');
        }
      }, onError: (e) {
        log('Server error: $e');
      });
    } catch (e) {
      log('Global exception: $e');
    }
  }

  static broadcast(dynamic data, {Client? except, String? group}) {
    final receivers = group != null ? clients.where((c) => c.group == group) : clients;

    for (var c in receivers) {
      if (c != except) {
        try {
          c.socket.add(data);
        } catch (e) {
          log('Broadcast error: $e');
        }
      }
    }
  }
}
