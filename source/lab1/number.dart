import 'dart:isolate';

import 'agent.dart';
import 'agent_wrapper.dart';

typedef NumberSettings = ({dynamic value, dynamic Function(dynamic a, dynamic b) operation, SendPort calculatorPort});

class Number extends Agent {
  late final NumberSettings settings;

  Number(dynamic settings) {
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

  static Future<SendPort> spawn(NumberSettings settings) async {
    return await spawnAgent(Number.new, settings);
  }
}
