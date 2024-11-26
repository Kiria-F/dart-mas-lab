import 'package:mas_labs/agents/task/task_agent.dart';
import 'package:mas_labs/base/base_message.dart';

class RequestOfferMessage extends BaseMessage {
  final TaskInfoMini info;

  RequestOfferMessage({required this.info, required super.senderPort, required super.senderName});
}

class AcceptOfferMessage extends BaseMessage {
  AcceptOfferMessage({required super.senderPort, required super.senderName});
}

class RejectOfferMessage extends BaseMessage {
  RejectOfferMessage({required super.senderPort, required super.senderName});
}

class TaskDeadMessage extends BaseMessage {
  TaskDeadMessage({required super.senderName, required super.senderPort});
}
