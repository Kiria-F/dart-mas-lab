import 'dart:isolate';

import 'package:mas_labs/base/base_message.dart';

class StartMessage {
  final List<SendPort> resources;

  StartMessage({required this.resources});
}

class OfferMessage extends BaseMessage {
  final int doneSeconds;

  OfferMessage({required this.doneSeconds, required super.senderPort, required super.senderName});
}
