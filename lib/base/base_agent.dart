import 'dart:isolate';

abstract class BaseAgent {
  final SendPort root;
  late String name;
  final ReceivePort _receivePort;
  SendPort get me => _receivePort.sendPort;

  BaseAgent({required this.root, required this.name}) : _receivePort = ReceivePort(name) {
    _receivePort.listen(listener);
  }

  void listener(dynamic message);
}
