import 'dart:developer';

import 'package:server/core/client.dart';
import 'package:server/models/command_packet.dart';

/// The Command class defines a common interface for all commands in the system.
/// It encapsulates the command logic and provides a uniform way to run the command handler for a given client and payload.
/// Each command has a name and an optional flag indicating whether authorization is required to execute the command.
/// The [run] method handles the common logic of checking authorization and sending error messages, while the [execute] method is responsible for the unique functionality of each command, which must be implemented by subclasses.
/// This design promotes code reuse and ensures that all commands adhere to the same authorization requirements without duplicating code in each command handler.
abstract class Command {
  const Command(
    this.command, {
    this.authorizationRequired = false,
  });

  final String command;
  final bool authorizationRequired;

  /// Run the command handler for the given client and payload.
  /// If [authorizationRequired] is true and the client is not authorized, an error message will be sent instead.
  /// The actual command logic should be implemented in the [execute] method, which will only be called if the client is authorized (if required).
  /// This separation allows for consistent authorization checks across all commands while keeping the command logic clean and focused.
  /// The [execute] method must be implemented by all subclasses to define the specific behavior of the command.
  /// The [run] method handles the common logic of checking authorization and sending error messages, while the [execute] method is responsible for the unique functionality of each command.
  /// This design promotes code reuse and ensures that all commands adhere to the same authorization requirements without duplicating code in each command handler.
  /// Example usage:
  /// ```dart
  /// class MyCommand extends Command {
  ///   const MyCommand() : super("mycommand", authorizationRequired: true);
  ///
  ///   @override
  ///   Future<void> execute({
  ///     required Client client,
  ///     dynamic payload,
  ///   }) async {
  ///     // Command logic here
  ///   }
  /// }
  /// ```
  Future<void> run({
    required Client client,
    dynamic payload,
  }) async {
    // Check if the client is authorized
    if (authorizationRequired && !client.isAuthorized) {
      try {
        log("Unauthorized command: $command");

        // Send an error message
        client.send(
          CommandPacket(
            command: command,
            payload: "Unauthorized",
          ),
        );
      } catch (e) {
        log("Unauthorized command error: $e");
      }
    } else {
      execute(
        client: client,
        payload: payload,
      );
    }
  }

  /// The actual command logic should be implemented in this method by subclasses.
  /// This method will only be called if the client is authorized (if required), allowing command handlers to focus solely on their specific functionality without worrying about authorization checks.
  /// Subclasses must implement this method to define the behavior of the command when executed by an authorized client.
  /// Example implementation in a subclass:
  /// ```dart
  /// class MyCommand extends Command {
  ///   const MyCommand() : super("mycommand", authorizationRequired: true);
  ///
  ///   @override
  ///   Future<void> execute({
  ///     required Client client,
  ///     dynamic payload,
  ///   }) async {
  ///     // Command logic here, e.g.:
  ///     client.send(
  ///       CommandPacket(
  ///         command: command,
  ///         payload: "Command executed successfully",
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  Future<void> execute({
    required Client client,
    dynamic payload,
  });
}
