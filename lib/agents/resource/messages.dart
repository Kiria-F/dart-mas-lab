import 'package:mas_labs/base/base_message.dart';

class OfferMessage extends BaseMessage {
  final int doneSeconds;

  OfferMessage({required this.doneSeconds, required super.senderPort, required super.senderName});
}

class OfferIsOutdatedMessage extends BaseMessage {
  OfferIsOutdatedMessage({required super.senderPort, required super.senderName});
}

class SecondsDoneChangedMessage extends BaseMessage {
  final int doneSeconds;

  SecondsDoneChangedMessage({required this.doneSeconds, required super.senderPort, required super.senderName});
}

class ResourceDeadMessage extends BaseMessage {
  ResourceDeadMessage({required super.senderName, required super.senderPort});
}
