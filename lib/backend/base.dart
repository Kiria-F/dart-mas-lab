import 'dart:isolate';
import 'dart:mirrors';

import 'agent_wrapper.dart';

abstract class Settings {
  ClassMirror get owner;

  Future<SendPort> spawn() async {
    return await spawnAgent(this);
  }
}

abstract class Agent {
  void listener(dynamic message);
}
