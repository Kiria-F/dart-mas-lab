import 'dart:isolate';

class KickTaskMessage {
  final Iterable<SendPort> resources;

  KickTaskMessage({required this.resources});
}

class DieMessage {}

class ViewSchedule {}
