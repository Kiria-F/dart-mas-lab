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
  List<TaskWrap> backlog = [];
  int? insertTo;
  List<TaskWrap> schedule = [];

  ResourceAgent(ResourceSettings settings) : super(rootPort: settings.root, name: settings.name) {
    performance = settings.performance;
  }

  @override
  void listener(dynamic message) {
    if (message is RequestMessage) {
      print('Resource [ $name ] got request from task [ ${message.senderName} ]\n');
      backlog.add(TaskWrap(info: message.info, ownerPort: message.senderPort, ownerName: message.senderName));
      processBacklog();
    }
    if (message is _ProcessBacklogMessage) {
      processBacklog();
    }
    if (message is AcceptMessage) {
      assert(backlog.isNotEmpty);
      assert(message.senderPort == backlog.first.ownerPort);
      assert(insertTo != null);
      var task = backlog.removeAt(0);
      var scheduleVisualization = Tools.visualizeSchedule(
        plan: schedule
            .map((t) => (
                  name: t.ownerName,
                  seconds: (t.info.amount / performance).ceil(),
                ))
            .toList(),
      );
      schedule.insert(insertTo!, task);
      insertTo = null;
      print('Resource [ $name ] added task [ ${task.ownerName} ] to schedule. New schedule:\n$scheduleVisualization');
      port.send(_ProcessBacklogMessage());
    }
    if (message is RejectMessage) {
      print('Resource [ $name ] droped task [ ${message.senderName} ] from backlog\n');
      backlog.removeWhere((t) => t.ownerPort == message.senderPort);
    }
    if (message is KysMessage) {
      rootPort.send(PlanDoneMessage(
          name: name,
          plan: schedule
              .map(
                (e) => (name: e.ownerName, seconds: (e.info.amount / performance).ceil()),
              )
              .toList(growable: false)));
      Isolate.current.kill();
    }
  }

  int taskSeconds(TaskInfo task) {
    return (task.amount / performance).ceil();
  }

  Iterable<({int index, int seconds})> scheduleTaskSeconds() sync* {}

  int scheduleRangeSeconds(int excludeIndex) {
    return scheduleTaskSeconds().take(excludeIndex).fold(0, (a, b) => a + b.seconds);
  }

  bool processBacklog() {
    if (backlog.isEmpty) return false;
    if (insertTo != null) return false;
    var task = backlog.first;
    var bestSeconds = 0;
    var bestIndex = 0;
    var bestValue = 0.0;
    for (var insertIndex = 0; insertIndex < schedule.length + 1; insertIndex++) {
      var value = 0.0;
      var seconds = 0;
      for (var i = 0; i < insertIndex; i++) {
        var task = schedule[i];
        seconds += (task.info.amount / performance).ceil();
        value += Tools.calcResultPrice(
          price: task.info.price,
          rate: task.info.rate,
          doneSeconds: seconds,
        );
      }
      seconds += (task.info.amount / performance).ceil();
      var doneSeconds = seconds;
      value += Tools.calcResultPrice(
        price: task.info.price,
        rate: task.info.rate,
        doneSeconds: seconds,
      );
      for (var i = insertIndex; i < schedule.length; i++) {
        var task = schedule[i];
        seconds += (task.info.amount / performance).ceil();
        value += Tools.calcResultPrice(
          price: task.info.price,
          rate: task.info.rate,
          doneSeconds: seconds,
        );
      }
      if (value > bestValue) {
        bestValue = value;
        bestIndex = insertIndex;
        bestSeconds = doneSeconds;
      }
    }
    insertTo = bestIndex;
    var scheduleVisualiztion = Tools.visualizeSchedule(
      plan: schedule
          .map((t) => (
                name: t.ownerName,
                seconds: (t.info.amount / performance).ceil(),
              ))
          .toList(),
      insertion: (
        index: insertTo!,
        name: task.ownerName,
        seconds: (task.info.amount / performance).ceil(),
      ),
    );
    print('Resource [ $name ] sent an offer to task [ ${task.ownerName} ]:\n$scheduleVisualiztion');
    task.ownerPort.send(OfferMessage(senderPort: port, senderName: name, doneSeconds: bestSeconds));
    return true;
  }
}

class TaskWrap {
  final TaskInfo info;
  final SendPort ownerPort;
  final String ownerName;

  TaskWrap({required this.info, required this.ownerPort, required this.ownerName});
}

class _ProcessBacklogMessage {}
