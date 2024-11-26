import 'dart:isolate';

class BaseMessage {
  final SendPort senderPort;
  final String senderName;

  BaseMessage({required this.senderPort, required this.senderName});
}

class DeadMessage extends BaseMessage {
  DeadMessage({required super.senderName, required super.senderPort});
}
