import 'dart:isolate';

abstract class BaseAgent {
  final ReceivePort _receivePort;
  get sendPort => _receivePort.sendPort;

  BaseAgent({String debugName = ''}) : _receivePort = ReceivePort(debugName) {
    _receivePort.listen(listener);
  }

  void listener(dynamic message);
}
