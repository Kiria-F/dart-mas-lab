import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/agents/task/task_agent.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/main.dart';
import 'package:mas_labs/tools.dart';

class ResourceSettings extends BaseSettings {
  final double performance;

  ResourceSettings({required super.parentPort, required super.name, required this.performance});

  @override
  BaseAgent createAgent() => ResourceAgent(this);
}

final class ResourceAgent extends BaseAgent {
  late final double performance;
  Map<SendPort, BacklogTask> backlog = {};
  List<TaskInfo> schedule = [];

  ResourceAgent(ResourceSettings settings) : super(parentPort: settings.parentPort, name: settings.name) {
    performance = settings.performance;
  }

  @override
  void listener(dynamic message) {
    if (message is RequestOfferMessage) {
      var task = TaskInfo.fromTaskInfoMini(message.info, message.senderPort, message.senderName);
      var bestValueIndex = 0;
      var bestValue = 0.0;
      var bestSeconds = 0;
      for (var insertIndex = 0; insertIndex < schedule.length + 1; insertIndex++) {
        var render = renderSchedule((index: insertIndex, info: task));
        var value = render.fold(0.0, (v, r) => v + r.value);
        if (value > bestValue) {
          bestValue = value;
          bestSeconds = render.take(insertIndex + 1).fold(0, (s, r) => s + r.seconds);
        }
      }
      var v = Tools.visualizeSchedule(
        plan: schedule
            .map((t) => (
                  name: t.name,
                  seconds: (t.amount / performance).ceil(),
                ))
            .toList(),
        insertion: (
          index: bestValueIndex,
          name: message.senderName,
          seconds: (message.info.amount / performance).ceil(),
        ),
      );
      print('Resource [ $name ] got request for a new task [ ${message.senderName} ]. Offer sent:\n$v');
      backlog[message.senderPort] = BacklogTask.fromTaskInfo(task, bestValueIndex);
      message.senderPort.send(OfferMessage(senderPort: port, senderName: name, doneSeconds: bestSeconds));
    }
    if (message is AcceptOfferMessage) {
      var backlogTask = backlog[message.senderPort];
      if (backlogTask == null) {
        message.senderPort.send(OfferIsOutdatedMessage(senderPort: port, senderName: name));
      } else {
        backlog.remove(backlogTask.info.port);
        schedule.insert(backlogTask.scheduleIndex, backlogTask.info);
        var v = Tools.visualizeSchedule(
          plan: schedule
              .map((t) => (
                    name: t.name,
                    seconds: (t.amount / performance).ceil(),
                  ))
              .toList(),
        );
        print('Resource [ $name ] accepted task [ ${backlogTask.info.name} ]. New schedule:\n$v');
        for (var i = backlogTask.scheduleIndex + 1; i < schedule.length; i++) {
          schedule[i];
        }
      }
    }
    if (message is RejectOfferMessage) {
      backlog.remove(message.senderPort);
    }
    if (message is DieMessage) {
      print('Resource [ $name ] died\n');
      receivePort.close();
    }
  }

  Iterable<RenderedTask> renderSchedule(({TaskInfo info, int index})? insertion) sync* {
    var seconds = 0;
    if (insertion == null) {
      for (var task in schedule) {
        seconds += (task.amount / performance).ceil();
        yield RenderedTask.fromTaskInfo(task, seconds, Tools.calcValue(task, seconds));
      }
    } else {
      for (var i = 0; i < insertion.index; i++) {
        var task = schedule[i];
        seconds += (task.amount / performance).ceil();
        yield RenderedTask.fromTaskInfo(task, seconds, Tools.calcValue(task, seconds));
      }
      seconds += (insertion.info.amount / performance).ceil();
      yield RenderedTask.fromTaskInfo(insertion.info, seconds, Tools.calcValue(insertion.info, seconds));
      for (var i = insertion.index; i < schedule.length; i++) {
        var task = schedule[i];
        seconds += (task.amount / performance).ceil();
        yield RenderedTask.fromTaskInfo(task, seconds, Tools.calcValue(task, seconds));
      }
    }
  }
}

class TaskInfo extends TaskInfoMini {
  final SendPort port;
  final String name;

  TaskInfo.fromTaskInfoMini(super.info, this.port, this.name) : super.fromAnother();

  TaskInfo.fromAnother(TaskInfo super.info)
      : port = info.port,
        name = info.name,
        super.fromAnother();
}

class BacklogTask {
  final TaskInfo info;
  final int scheduleIndex;

  BacklogTask.fromTaskInfo(this.info, this.scheduleIndex);
}

class RenderedTask {
  final TaskInfo info;
  final int seconds;
  final double value;

  RenderedTask.fromTaskInfo(this.info, this.seconds, this.value);
}
