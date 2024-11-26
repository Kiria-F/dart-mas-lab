import 'package:mas_labs/base/base_message.dart';
import 'package:mas_labs/shared.dart';

class RequestOfferMessage extends BaseMessage {
  final TaskInfoCore info;

  RequestOfferMessage({required this.info, required super.port, required super.name});
}

class AcceptOfferMessage extends BaseMessage {
  AcceptOfferMessage({required super.port, required super.name});
}

class RejectOfferMessage extends BaseMessage {
  RejectOfferMessage({required super.port, required super.name});
}

class TaskDiedMessage extends DeadMessage {
  TaskDiedMessage({required super.name, required super.port});
}
