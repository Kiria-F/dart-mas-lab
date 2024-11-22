import 'dart:isolate';
import 'dart:math';

abstract class BaseAgent {
  final SendPort root;
  late String name;
  final ReceivePort _receivePort;
  final Random random;
  SendPort get me => _receivePort.sendPort;

  BaseAgent({required this.root, required this.name})
      : _receivePort = ReceivePort(name),
        random = Random(name.hashCode) {
    _receivePort.listen(listener);
  }

  void listener(dynamic message);
}
