import 'dart:isolate';
import 'dart:mirrors';

import 'agent_wrapper.dart';

abstract class BaseSettings {
  ClassMirror get owner;

  Future<SendPort> spawn() async {
    return await spawnAgent(
      (settings) => owner.newInstance(Symbol(''), [settings]).reflectee,
      this,
    );
  }
}

abstract class BaseAgent {
  void listener(dynamic message);
}
