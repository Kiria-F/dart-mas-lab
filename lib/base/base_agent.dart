import 'dart:isolate';
import 'dart:math';

abstract class BaseAgent {
  final SendPort parentPort;
  late String name;
  final ReceivePort receivePort;
  final Random random;
  SendPort get port => receivePort.sendPort;

  BaseAgent({required this.parentPort, required this.name})
      : receivePort = ReceivePort(name),
        random = Random(name.hashCode) {
    receivePort.listen(listener);
  }

  void listener(dynamic message);
}
