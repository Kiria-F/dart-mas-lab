import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/tools.dart';

import 'setup.dart';

void main() async {
  print('');
  var receivePort = ReceivePort();
  var setup = Setup(receivePort.sendPort);
  var resources = await Future.wait([for (var settings in setup.resourceSetup) settings.spawn()]);
  setup.taskSetup.shuffle();
  var tasks = await Future.wait([for (var settings in setup.taskSetup) settings.spawn()]);
  for (var task in tasks) {
    task.send(KickTaskMessage(resources: resources));
    sleep(Duration(milliseconds: 10));
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
      var v = Tools.visualizeSchedule(plan: message.plan);
      if (plansDone == resources.length) {
        receivePort.close();
      }
      print('Plan for resource [ ${message.name} ]:\n$v');
    }
  });
}

class TaskDoneMessage {}

class PlanDoneMessage {
  final String name;
  final List<({String name, int seconds})> plan;

  PlanDoneMessage({required this.name, required this.plan});
}

class KickTaskMessage {
  final List<SendPort> resources;

  KickTaskMessage({required this.resources});
}
