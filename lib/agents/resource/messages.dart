import 'package:mas_labs/base/base_message.dart';

class OfferMessage extends BaseMessage {
  final int doneSeconds;

  OfferMessage({required this.doneSeconds, required super.port, required super.name});
}

class OfferIsOutdatedMessage extends BaseMessage {
  OfferIsOutdatedMessage({required super.port, required super.name});
}

class OfferChangedMessage extends BaseMessage {
  final int doneSeconds;

  OfferChangedMessage({required this.doneSeconds, required super.port, required super.name});
}

class ResourceDeadMessage extends DeadMessage {
  ResourceDeadMessage({required super.name, required super.port});
}
