import 'package:mas_lab/agents/base/agent.dart';
import 'package:mas_lab/agents/base/settings.dart';
import 'package:mas_lab/agents/resource/agent.dart';

class ResourceSettings extends BaseSettings {
  final double performance;

  ResourceSettings({required super.rootPort, required super.name, required this.performance});

  @override
  BaseAgent createAgent() => ResourceAgent(this);
}
