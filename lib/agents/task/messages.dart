import 'package:mas_labs/agents/task/agent.dart';
import 'package:mas_labs/base/base_message.dart';

class RequestOfferMessage extends BaseMessage {
  final TaskInfoMini info;

  RequestOfferMessage({required this.info, required super.port, required super.name});
}

class AcceptOfferMessage extends BaseMessage {
  AcceptOfferMessage({required super.port, required super.name});
}

class RejectOfferMessage extends BaseMessage {
  RejectOfferMessage({required super.port, required super.name});
}

class TaskDeadMessage extends DeadMessage {
  TaskDeadMessage({required super.name, required super.port});
}
