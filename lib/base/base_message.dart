import 'dart:isolate';

class BaseMessage {
  final SendPort senderPort;
  final String senderName;

  BaseMessage({required this.senderPort, required this.senderName});
}
