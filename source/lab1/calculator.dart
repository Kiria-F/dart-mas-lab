import 'dart:mirrors';

import 'base.dart';

class C8rSettings extends BaseSettings {
  @override
  ClassMirror get owner => reflectClass(C8rAgent);

  final dynamic initialValue;

  C8rSettings({this.initialValue = 0});
}

class C8rAgent extends BaseAgent {
  dynamic accumulator = 0;

  C8rAgent(C8rSettings settings) {
    accumulator = settings.initialValue;
  }

  @override
  void listener(dynamic message) {
    if (message is ({dynamic value, dynamic Function(dynamic a, dynamic b) operation})) {
      accumulator = message.operation(accumulator, message.value);
      print(accumulator);
    }
  }
}
