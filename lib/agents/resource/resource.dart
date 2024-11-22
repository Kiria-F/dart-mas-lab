import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/agents/resource/incoming.dart';
import 'package:mas_labs/agents/task/incoming.dart';
import 'package:mas_labs/agents/task/task.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/main.dart';
import 'package:mas_labs/tools.dart';

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
    sleep(Duration(milliseconds: random.nextInt(500) + 250));
    if (message is RequestMessage) {
      print('[2] Resource [$name] got request for a new task [${message.name}]. Offer sent:');
      var bestValueIndex = 0;
      var bestValue = 0.0;
      late int bestValueDoneSeconds;
      for (var insertIndex = 0; insertIndex < schedule.length + 1; insertIndex++) {
        var value = 0.0;
        var timer = 0;
        for (var i = 0; i < insertIndex; i++) {
          var task = schedule[i];
          timer += (task.info.amount / performance).ceil();
          value += Tools.calcResultPrice(
            price: task.info.price,
            rate: task.info.rate,
            doneSeconds: timer,
          );
        }
        timer += (message.info.amount / performance).ceil();
        var doneSeconds = timer;
        value += Tools.calcResultPrice(
          price: message.info.price,
          rate: message.info.rate,
          doneSeconds: timer,
        );
        for (var i = insertIndex; i < schedule.length; i++) {
          var task = schedule[i];
          timer += (task.info.amount / performance).ceil();
          value += Tools.calcResultPrice(
            price: task.info.price,
            rate: task.info.rate,
            doneSeconds: timer,
          );
        }
        if (value > bestValue) {
          bestValue = value;
          bestValueIndex = insertIndex;
          bestValueDoneSeconds = doneSeconds;
        }
      }
      Tools.printSchedule(
        plan: schedule
            .map((t) => (
                  name: t.name,
                  seconds: (t.info.amount / performance).ceil(),
                ))
            .toList(),
        insertion: (
          index: bestValueIndex,
          name: message.name,
          seconds: (message.info.amount / performance).ceil(),
        ),
      );
      backlog.add(BacklogTask(
        owner: message.sender,
        scheduleIndex: bestValueIndex,
        info: message.info,
        name: message.name,
      ));
      message.sender.send(OfferMessage(sender: me, doneSeconds: bestValueDoneSeconds));
    }
    if (message is AcceptMessage) {
      var task = backlog.firstWhere((t) => t.owner == message.sender);
      print('[4] Resource [$name] accepted task [${task.name}]. Accepted offer:');
      Tools.printSchedule(
        plan: schedule
            .map((t) => (
                  name: t.name,
                  seconds: (t.info.amount / performance).ceil(),
                ))
            .toList(),
        insertion: (
          index: task.scheduleIndex,
          name: task.name,
          seconds: (task.info.amount / performance).ceil(),
        ),
      );
      schedule.insert(task.scheduleIndex, PlannedTask(info: task.info, name: task.name));
    }
    if (message is RejectMessage) {
      backlog.removeWhere((t) => t.owner == message.sender);
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
