import 'dart:isolate';

class KickTaskMessage {
  final Set<SendPort> resources;

  KickTaskMessage({required this.resources});
}

class DieMessage {}
