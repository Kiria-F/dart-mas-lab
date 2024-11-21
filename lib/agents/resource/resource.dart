import 'package:mas_labs/agents/task/task.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';

class ResourceSettings extends BaseSettings {
  final double performance;

  ResourceSettings({required this.performance});

  @override
  BaseAgent createAgent() => ResourceAgent(this);
}

final class ResourceAgent extends BaseAgent {
  late final double performance;

  ResourceAgent(ResourceSettings settings) {
    performance = settings.performance;
  }

  @override
  void listener(dynamic message) {
    if (message is TaskInfo) {
      print('Got task:\n- cost: ${message.cost}\n- ${message.seconds}');
    }
  }
}
