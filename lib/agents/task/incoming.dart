import 'dart:isolate';

import 'package:mas_labs/base/base_message.dart';

class StartMessage extends BaseMessage {
  final List<SendPort> resources;

  StartMessage({required this.resources, required super.sender});
}

class OfferMessage extends BaseMessage {
  final int doneSeconds;

  OfferMessage({required this.doneSeconds, required super.sender});
}
