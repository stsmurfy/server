import 'package:server/core/client.dart';

abstract class Command {
  Command(this._command);

  final String _command;

  execute({
    required Client client,
    dynamic payload,
  });

  String get command {
    return _command;
  }
}
