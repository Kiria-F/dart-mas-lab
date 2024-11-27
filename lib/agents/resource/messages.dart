import 'package:mas_lab/agents/base/messages.dart';

class ResourceUpdatedMessage extends BaseMessage {
  ResourceUpdatedMessage({required super.name, required super.port});
}

class OfferMessage extends BaseMessage {
  final int doneSeconds;

  OfferMessage({required this.doneSeconds, required super.port, required super.name});
}

class OfferIrrelevantMessage extends BaseMessage {
  OfferIrrelevantMessage({required super.port, required super.name});
}

class ScheduleChangedMessage extends BaseMessage {
  final int doneSeconds;

  ScheduleChangedMessage({required this.doneSeconds, required super.port, required super.name});
}

class ResourceDiedMessage extends DeadMessage {
  ResourceDiedMessage({required super.name, required super.port});
}
