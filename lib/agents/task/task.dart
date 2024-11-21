import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';

class TaskInfo {
  final double cost;
  final int seconds;

  TaskInfo({required this.cost, required this.seconds});
}

class TaskSettings extends BaseSettings {
  final double cost;
  final int seconds;

  TaskSettings(this.cost, this.seconds);

  @override
  BaseAgent createAgent() => TaskAgent(this);
}

class TaskAgent extends BaseAgent {
  late final TaskInfo info;

  TaskAgent(TaskSettings settings) {
    info = TaskInfo(cost: settings.cost, seconds: settings.seconds);
  }
  @override
  void listener(dynamic message) {}
}
