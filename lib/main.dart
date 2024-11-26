import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';

import 'setup.dart';

void main() async {
  print('');
  var receivePort = ReceivePort();
  var setup = Setup(receivePort.sendPort);
  var resources = <SendPort>{}..addAll(await Future.wait([for (var settings in setup.resourceSetup) settings.spawn()]));
  setup.taskSetup.shuffle();
  var tasks = <SendPort>{}..addAll(await Future.wait([for (var settings in setup.taskSetup) settings.spawn()]));
  for (var task in tasks) {
    task.send(KickTaskMessage(resources: resources));
    sleep(Duration(milliseconds: 10));
  }
  receivePort.listen((message) {
    if (message is TaskDeadMessage) {
      assert(tasks.remove(message.senderPort));
      if (tasks.isEmpty) {
        for (var resource in resources) {
          resource.send(DieMessage());
        }
      }
    }
    if (message is ResourceDeadMessage) {
      assert(resources.remove(message.senderPort));
    }
    if (tasks.isEmpty && resources.isEmpty) {
      print('All dead');
      receivePort.close();
    }
  });
}

class KickTaskMessage {
  final Set<SendPort> resources;

  KickTaskMessage({required this.resources});
}

class DieMessage {}
