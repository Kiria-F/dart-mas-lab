import 'dart:isolate';

class InitTaskMessage {
  final Iterable<SendPort> resources;

  InitTaskMessage({required this.resources});
}

class DieMessage {}

class ViewSchedule {}
