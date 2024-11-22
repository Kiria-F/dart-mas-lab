import 'package:mas_labs/agents/task/task.dart';
import 'package:mas_labs/base/base_message.dart';

class RequestMessage extends BaseMessage {
  final TaskInfo info;

  RequestMessage({required this.info, required super.senderPort, required super.senderName});
}

class AcceptMessage extends BaseMessage {
  AcceptMessage({required super.senderPort, required super.senderName});
}

class RejectMessage extends BaseMessage {
  RejectMessage({required super.senderPort, required super.senderName});
}

class KysMessage {}
