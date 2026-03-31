import 'dart:io';

class Client {
  Client({
    required this.socket,
    this.group,
  });

  final WebSocket socket;
  String? group;
  bool isAuthorized = false;
}
