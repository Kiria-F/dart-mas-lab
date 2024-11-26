import 'package:mas_labs/base/base_message.dart';

class OfferMessage extends BaseMessage {
  final int doneSeconds;

  OfferMessage({required this.doneSeconds, required super.port, required super.name});
}

class OfferIsOutdatedMessage extends BaseMessage {
  OfferIsOutdatedMessage({required super.port, required super.name});
}

class SecondsDoneChangedMessage extends BaseMessage {
  final int doneSeconds;

  SecondsDoneChangedMessage({required this.doneSeconds, required super.port, required super.name});
}

class ResourceDeadMessage extends DeadMessage {
  ResourceDeadMessage({required super.name, required super.port});
}
