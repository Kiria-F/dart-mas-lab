import 'dart:isolate';

import 'package:mas_labs/agents/resource/incoming.dart';
import 'package:mas_labs/agents/task/incoming.dart';

import 'setup.dart';

void main() async {
  var receivePort = ReceivePort();
  var resources = await Future.wait([for (var settings in resourceSetup(receivePort.sendPort)) settings.spawn()]);
  var tasks = await Future.wait([for (var settings in taskSetup(receivePort.sendPort).reversed) settings.spawn()]);
  for (var task in tasks) {
    task.send(StartMessage(resources: resources, sender: receivePort.sendPort));
  }
  var tasksDone = 0;
  var plansDone = 0;
  receivePort.listen((message) {
    if (message is TaskDoneMessage) {
      tasksDone++;
      if (tasksDone == tasks.length) {
        for (var resource in resources) {
          resource.send(KysMessage());
        }
      }
    }
    if (message is PlanDoneMessage) {
      plansDone++;
      StringBuffer render = StringBuffer();
      for (var task in message.plan) {
        var seconds = task.seconds;
        while (seconds > 0) {
          render.write(task.name[0]);
          seconds -= 5;
        }
      }
      print('\nPlan for resource [${message.name}]:\n${render.toString()}\n');
      if (plansDone == resources.length) {
        receivePort.close();
      }
    }
  });
}

class TaskDoneMessage {}

class PlanDoneMessage {
  final String name;
  final List<({String name, int seconds})> plan;

  PlanDoneMessage({required this.name, required this.plan});
}
