import 'package:mas_lab/agents/base/messages.dart';
import 'package:mas_lab/shared.dart';

class RequestOfferMessage extends BaseMessage {
  final TaskInfoCore info;

  RequestOfferMessage({required this.info, required super.port, required super.name});
}

class AcceptOfferMessage extends BaseMessage {
  AcceptOfferMessage({required super.port, required super.name});
}

class RevokeAgreementMessage extends BaseMessage {
  RevokeAgreementMessage({required super.port, required super.name});
}

class TaskDiedMessage extends DeadMessage {
  TaskDiedMessage({required super.name, required super.port});
}
