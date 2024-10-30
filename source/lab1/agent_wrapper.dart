import 'dart:isolate';

import 'base.dart';

typedef _Setup = ({
  SendPort initSendPort,
  BaseAgent Function(dynamic settings) spawner,
  dynamic settings,
});

class _AgentWrapper {
  ReceivePort receivePort = ReceivePort();
  late BaseAgent agent;

  _AgentWrapper(_Setup setup) {
    agent = setup.spawner(setup.settings);
    setup.initSendPort.send(receivePort.sendPort);
    receivePort.listen(listener);
  }

  void listener(dynamic message) {
    agent.listener(message);
  }
}

Future<SendPort> spawnAgent(
  BaseAgent Function(dynamic settings) spawner,
  dynamic settings,
) async {
  var initReceivePort = ReceivePort();

  await Isolate.spawn(
    _AgentWrapper.new,
    (
      initSendPort: initReceivePort.sendPort,
      spawner: spawner,
      settings: settings,
    ),
  );
  return await initReceivePort.first;
}
