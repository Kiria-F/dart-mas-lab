import 'dart:isolate';
import 'dart:mirrors';

import 'base.dart';

class NumberSettings extends Settings {
  @override
  ClassMirror get owner => reflectClass(NumberAgent);

  final dynamic value;
  final dynamic Function(dynamic a, dynamic b) operation;
  final SendPort calculatorPort;

  NumberSettings({required this.value, required this.operation, required this.calculatorPort});
}

class NumberAgent extends Agent {
  late final NumberSettings settings;

  NumberAgent(dynamic settings) {
    if (settings is! NumberSettings) {
      throw TypeError();
    } else {
      this.settings = settings;
    }
  }

  @override
  void listener(dynamic message) {
    if (message is String) {
      if (message == 'run') {
        settings.calculatorPort.send((
          value: settings.value,
          operation: settings.operation,
        ));
      }
    }
  }
}
