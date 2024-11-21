import 'dart:isolate';

import 'package:mas_labs/agents/resource/incoming.dart';
import 'package:mas_labs/agents/task/incoming.dart';
import 'package:mas_labs/agents/task/task.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/main.dart';

class ResourceSettings extends BaseSettings {
  final double performance;

  ResourceSettings({required super.root, required super.name, required this.performance});

  @override
  BaseAgent createAgent() => ResourceAgent(this);
}

final class ResourceAgent extends BaseAgent {
  late final double performance;
  List<BacklogTask> backlog = [];
  List<PlannedTask> schedule = [];

  ResourceAgent(ResourceSettings settings) : super(root: settings.root, name: settings.name) {
    performance = settings.performance;
  }

  @override
  void listener(dynamic message) {
    if (message is RequestMessage) {
      print('[2] Resource [$name] got request for a new task [${message.name}]');
      var doneTime = schedule.fold(0.0, (a, t) => a + t.info.amount / performance);
      doneTime += message.info.amount / performance;

      backlog.add(BacklogTask(
        owner: message.sender,
        scheduleIndex: schedule.length,
        info: message.info,
        name: message.name,
      ));

      message.sender.send(OfferMessage(sender: me, doneSeconds: doneTime.ceil()));
    }
    if (message is AcceptMessage) {
      var task = backlog.firstWhere((t) => t.owner == message.sender);
      print('[4] Resource [$name] accepted task [${task.name}]');
      schedule.add(PlannedTask(info: task.info, name: task.name));
    }
    if (message is KysMessage) {
      root.send(PlanDoneMessage(
          name: name,
          plan: schedule
              .map(
                (e) => (name: e.name, seconds: (e.info.amount / performance).ceil()),
              )
              .toList(growable: false)));
      Isolate.current.kill();
    }
  }
}

class BacklogTask {
  final int scheduleIndex;
  final TaskInfo info;
  final SendPort owner;
  final String name;

  BacklogTask({required this.scheduleIndex, required this.info, required this.owner, required this.name});
}

class PlannedTask {
  final TaskInfo info;
  final String name;

  PlannedTask({required this.info, required this.name});
}
