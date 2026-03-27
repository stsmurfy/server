import 'dart:convert';

class CommandPacket {
  CommandPacket({
    required this.command,
    this.payload,
  });

  final String command;
  final dynamic payload;

  factory CommandPacket.fromMap(Map<String, dynamic> map) {
    return CommandPacket(
      command: map['cmd'] ?? '',
      payload: map['payload'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cmd': command,
      'payload': payload,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
