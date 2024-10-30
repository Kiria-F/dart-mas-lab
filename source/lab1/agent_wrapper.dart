import 'dart:isolate';

import 'base.dart';

typedef _Setup = ({
  SendPort initSendPort,
  BaseAgent Function(BaseSettings settings) spawner,
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
  BaseSettings settings,
) async {
  var initReceivePort = ReceivePort();

  await Isolate.spawn(
    _AgentWrapper.new,
    (
      initSendPort: initReceivePort.sendPort,
      spawner: (s) => settings.owner.newInstance(Symbol(''), [s]).reflectee as BaseAgent,
      settings: settings,
    ),
  );
  return await initReceivePort.first;
}
