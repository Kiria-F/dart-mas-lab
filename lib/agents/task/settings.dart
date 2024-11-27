import 'package:mas_lab/agents/base/agent.dart';
import 'package:mas_lab/agents/base/settings.dart';
import 'package:mas_lab/agents/task/agent.dart';
import 'package:mas_lab/shared.dart';

class TaskSettings extends BaseSettings {
  final TaskInfoCore info;

  TaskSettings({required super.rootPort, required super.name, required this.info});

  @override
  BaseAgent createAgent() => TaskAgent(this);
}
