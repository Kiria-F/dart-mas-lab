import 'dart:isolate';

import 'package:mas_labs/shared.dart';

class BaseMessage extends AgentInfo {
  BaseMessage({required String name, required SendPort port}) : super(name, port);
}

class DeadMessage extends BaseMessage {
  DeadMessage({required super.name, required super.port});
}
