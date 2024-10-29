import 'dart:isolate';

import 'agent.dart';
import 'agent_wrapper.dart';

typedef CalculatorSettings = ({dynamic initialValue});

class Calculator extends Agent {
  dynamic accumulator = 0;

  Calculator(dynamic settings) {
    accumulator = settings.initialValue;
  }

  @override
  void listener(dynamic message) {
    if (message is ({dynamic value, dynamic Function(dynamic a, dynamic b) operation})) {
      accumulator = message.operation(accumulator, message.value);
      print(accumulator);
    }
  }

  static Future<SendPort> spawn(CalculatorSettings settings) async {
    return await spawnAgent(Calculator.new, settings);
  }
}
