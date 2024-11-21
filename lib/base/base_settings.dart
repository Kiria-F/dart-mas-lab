import 'dart:isolate';

import 'package:mas_labs/base/base_agent.dart';

typedef AgentInitializationMessage = ({BaseSettings settings, SendPort sendPort});

abstract class BaseSettings {
  final SendPort root;
  final String name;

  BaseSettings({required this.root, required this.name});
  BaseAgent createAgent();

  Future<SendPort> spawn() async {
    var tempReceivePort = ReceivePort();
    Isolate.spawn(
      (AgentInitializationMessage message) {
        message.sendPort.send(message.settings.createAgent().me);
      },
      (settings: this, sendPort: tempReceivePort.sendPort),
    );
    return await tempReceivePort.first;
  }
}
