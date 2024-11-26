import 'package:mas_labs/base/base_message.dart';

class ResourceUpdatedMessage extends BaseMessage {
  ResourceUpdatedMessage({required super.name, required super.port});
}

class OfferMessage extends BaseMessage {
  final int doneSeconds;

  OfferMessage({required this.doneSeconds, required super.port, required super.name});
}

class OfferAcceptAbortedMessage extends BaseMessage {
  OfferAcceptAbortedMessage({required super.port, required super.name});
}

class OfferChangedMessage extends BaseMessage {
  final int doneSeconds;

  OfferChangedMessage({required this.doneSeconds, required super.port, required super.name});
}

class ResourceDiedMessage extends DeadMessage {
  ResourceDiedMessage({required super.name, required super.port});
}
