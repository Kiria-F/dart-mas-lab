import 'dart:isolate';

import 'package:mas_labs/base/base_agent.dart';

typedef AgentInitializationMessage = ({BaseSettings settings, SendPort sendPort});

abstract class BaseSettings {
  final SendPort rootPort;
  final String name;

  BaseSettings({required this.rootPort, required this.name});
  BaseAgent createAgent();

  Future<SendPort> spawn() async {
    var tempReceivePort = ReceivePort();
    Isolate.spawn(
      (AgentInitializationMessage message) {
        message.sendPort.send(message.settings.createAgent().port);
      },
      (settings: this, sendPort: tempReceivePort.sendPort),
    );
    return await tempReceivePort.first;
  }
}
