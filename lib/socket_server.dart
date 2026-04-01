import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:server/core/client.dart';
import 'package:server/handlers/auth_handler.dart';
import 'package:server/handlers/block_info_handler.dart';
import 'package:server/handlers/ping_handler.dart';
import 'package:server/models/command_packet.dart';

/// A WebSocket server for handling client connections and message processing.
/// Supports both secure (wss) and insecure (ws) modes based on environment variables.
/// Handles client connections, message processing, and disconnections with robust error handling.
/// Broadcasts messages to all clients or specific groups with error handling for individual client failures.
/// Environment variables:
/// - `ssl_certificate`: Path to SSL certificate for secure mode.
/// - `ssl_private_key`: Path to SSL private key for secure mode.
/// - `address`: Server address (default: '0.0.0.0').
/// - `port`: Server port (default: '8181').
/// Example usage:
/// ```dart
/// void main() {
///   SocketServer.start();
/// }
/// ```
class SocketServer {
  static final handlers = [
    PingHandler(),
    AuthHandler(),
    BlockInfoHandler(),
  ];
  static final clients = <Client>[];

  /// Starts the WebSocket server and listens for incoming connections.
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
                            await handler.run(
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

  /// Broadcasts a message to all clients or specific groups with error handling for individual client failures.
  /// Parameters:
  /// - `data`: The command packet to broadcast.
  /// - `except`: An optional client to exclude from the broadcast.
  /// - `group`: An optional group name to target specific clients. If null, broadcasts to all clients.
  /// Handles errors for each client individually to ensure that a failure with one client does not affect others.
  /// Logs any errors encountered during the broadcast process for debugging purposes.
  /// Example usage:
  /// ```dart
  /// SocketServer.broadcast(
  ///   CommandPacket(command: 'update', payload: {'data': 'new data'}),
  ///   except: someClient,
  ///   group: 'group1',
  /// );
  /// ```
  static broadcast(CommandPacket data, {Client? except, String? group}) {
    final receivers = group != null ? clients.where((c) => c.group == group) : clients;

    for (var c in receivers) {
      if (c != except) {
        try {
          c.send(data);
        } catch (e) {
          log("Broadcast error: $e");
        }
      }
    }
  }
}
