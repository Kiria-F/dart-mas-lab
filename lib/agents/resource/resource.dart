import 'dart:mirrors';

import '/system/base_agent.dart';
import '/system/base_settings.dart';
import 'incoming.dart';

class ResourceSettings extends BaseSettings {
  final double performance;

  ResourceSettings({required this.performance});

  @override
  ClassMirror get owner => reflectClass(ResourceAgent);
}

class ResourceAgent extends Agent {
  late final double performance;

  ResourceAgent(ResourceSettings settings) {
    performance = settings.performance;
  }

  @override
  void listener(dynamic message) {
    if (message is TaskInfoMessage) {}
  }
}
