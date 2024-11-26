import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/messages.dart';
import 'package:mas_labs/shared.dart';

class ResourceSettings extends BaseSettings {
  final double performance;

  ResourceSettings({required super.rootPort, required super.name, required this.performance});

  @override
  BaseAgent createAgent() => ResourceAgent(this);
}

final class ResourceAgent extends BaseAgent {
  late final double performance;
  Map<SendPort, BacklogTask> backlog = {};
  List<TaskInfo> schedule = [];

  ResourceAgent(ResourceSettings settings) : super(rootPort: settings.rootPort, name: settings.name) {
    performance = settings.performance;
  }

  @override
  void listener(dynamic message) {
    switch (message) {
      case RequestOfferMessage request:
        var task = TaskInfo.fromCore(request.info, request.port, request.name);
        var bestValueIndex = 0;
        var bestValue = 0.0;
        var bestSeconds = 0;
        late Iterable<RenderedTask> bestRender;
        for (var insertIndex = 0; insertIndex < schedule.length + (schedule.contains(task) ? 0 : 1); insertIndex++) {
          var render = _renderSchedule(insertion: (index: insertIndex, info: task));
          var insertion = render.singleWhere((t) => t.inserted);
          var value = render.fold(0.0, (v, r) => v + r.value);
          if (value > bestValue) {
            bestValueIndex = insertIndex;
            bestValue = value;
            bestSeconds = insertion.secondsTotal;
            bestRender = render;
          }
        }
        var v = _visualizeSchedule(bestRender);
        print('Resource [ $name ] got request for task [ ${message.name} ]. Offer sent:\n$v\n');
        backlog[message.port] = BacklogTask.fromTaskInfo(task, bestValueIndex);
        message.port.send(OfferMessage(port: port, name: name, doneSeconds: bestSeconds));

      case AcceptOfferMessage task:
        var insertingTask = backlog[task.port];
        if (insertingTask == null || insertingTask.scheduleIndex > schedule.length) {
          task.port.send(OfferAcceptAbortedMessage(port: port, name: name));
          break;
        }
        backlog.remove(insertingTask.info.port);
        schedule.remove(insertingTask.info);
        schedule.insert(insertingTask.scheduleIndex, insertingTask.info);
        var render = _renderSchedule();
        var v = _visualizeSchedule(render);
        print('Resource [ $name ] accepted task [ ${insertingTask.info.name} ]. New schedule:\n$v\n');
        backlog.removeWhere((_, task) => task.scheduleIndex > insertingTask.scheduleIndex);
        for (var i = insertingTask.scheduleIndex + 1; i < schedule.length; i++) {
          schedule[i].port.send(OfferChangedMessage(doneSeconds: render[i].secondsTotal, port: port, name: name));
        }

      case RejectOfferMessage task:
        schedule.removeWhere((t) => t.port == task.port);
        var render = _renderSchedule();
        for (var task in render) {
          task.info.port.send(OfferChangedMessage(doneSeconds: task.secondsTotal, port: port, name: name));
        }

      case TaskDiedMessage task:
        var index = schedule.indexWhere((e) => e.port == task.port);
        if (index >= 0) {
          schedule.removeAt(index);
          var render = _renderSchedule();
          for (var i = index; i < schedule.length; i++) {
            schedule[i].port.send(OfferChangedMessage(doneSeconds: render[i].secondsTotal, port: port, name: name));
          }
          backlog.removeWhere((k, v) => v.scheduleIndex > index);
          rootPort.send(BroadcastMessage(ResourceUpdatedMessage(name: name, port: port), AgentType.task));
        }

      case ViewSchedule _:
        var v = _visualizeSchedule(_renderSchedule());
        print('Resource\'s [ $name ] schedule:\n$v\n');

      case DieMessage _:
        print('Resource [ $name ] died\n');
        rootPort.send(ResourceDiedMessage(name: name, port: port));
        rootPort.send(BroadcastMessage(ResourceDiedMessage(name: name, port: port), AgentType.task));
        receivePort.close();
    }
  }

  List<RenderedTask> _renderSchedule({({TaskInfo info, int index})? insertion}) {
    var preRender = schedule.map((e) => RenderedTask.fromTaskInfo(e, 0, 0, 0, false));
    if (insertion != null) {
      preRender = preRender.where((e) => e.info != insertion.info);
    }
    var render = preRender.toList();
    if (insertion != null) {
      render.insert(insertion.index, RenderedTask.fromTaskInfo(insertion.info, 0, 0, 0, true));
    }
    var secondsTotal = 0;
    for (var task in render) {
      task.seconds = (task.info.amount / performance).ceil();
      secondsTotal += task.seconds;
      task.secondsTotal = secondsTotal;
      task.value = _calcValue(task.info, secondsTotal);
    }
    return render;
  }

  static double _calcValue(TaskInfoCore task, int doneSeconds) {
    assert(0 < task.rate && task.rate < 1);
    var decreaser = 1 - task.rate;
    var resultPrice = task.price.toDouble();
    for (var i = 0; i < doneSeconds; i++) {
      resultPrice *= decreaser;
    }
    return resultPrice;
  }

  static String _visualizeSchedule(Iterable<RenderedTask> renderedSchedule) {
    double wrapper = 5;
    var insertionDone = false;
    StringBuffer planRender = StringBuffer('[ ');
    StringBuffer anchorRender = StringBuffer('  ');
    StringBuffer insertionRender = StringBuffer('  ');

    for (var task in renderedSchedule) {
      if (task.inserted) {
        assert(!insertionDone);
        planRender.write(' ');
        anchorRender.write('^');
        insertionRender.write(task.info.name[0] * (task.seconds / wrapper).ceil());
        insertionDone = true;
      } else {
        var size = (task.seconds / wrapper).ceil();
        planRender.write(task.info.name[0] * size);
        if (!insertionDone) {
          anchorRender.write(' ' * size);
          insertionRender.write(' ' * size);
        }
      }
    }
    planRender.write(' ]');
    var render = StringBuffer();
    render.write(planRender);
    if (insertionDone) {
      render.writeln();
      render.writeln(anchorRender);
      render.write(insertionRender);
    }
    return render.toString();
  }
}

class BacklogTask {
  final TaskInfo info;
  final int scheduleIndex;

  BacklogTask.fromTaskInfo(this.info, this.scheduleIndex);
}

class RenderedTask {
  final TaskInfo info;
  int seconds;
  int secondsTotal;
  double value;
  final bool inserted;

  RenderedTask.fromTaskInfo(this.info, this.seconds, this.secondsTotal, this.value, this.inserted);
}
