import 'dart:isolate';

class BaseMessage {
  final SendPort sender;

  BaseMessage({required this.sender});
}
