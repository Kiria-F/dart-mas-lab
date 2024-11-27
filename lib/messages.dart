import 'package:mas_lab/agents/base/messages.dart';
import 'package:mas_lab/shared.dart';

class InitTaskMessage {
  final Iterable<AgentInfo> resources;

  InitTaskMessage({required this.resources});
}

class DieMessage {}

class ViewSchedule {}

enum AgentType {
  resource,
  task,
}

class BroadcastMessage {
  BaseMessage message;
  AgentType targets;

  BroadcastMessage(this.message, this.targets);
}

class ResourceBornMessage extends BaseMessage {
  ResourceBornMessage({required super.name, required super.port});
}
