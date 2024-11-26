import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/base/base_message.dart';
import 'package:mas_labs/messages.dart';

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
  var exiting = false;
  var stdinSub = stdin.transform(utf8.decoder).transform(LineSplitter()).listen((input) {
    print('${'-' * input.length}\n');
    if (input == 'quit') {
      if (!exiting) {
        exiting = true;
        for (var agent in tasks.followedBy(resources)) {
          agent.send(DieMessage());
        }
      }
    }
    if (input == 'view') {
      for (var resource in resources) {
        resource.send(ViewSchedule());
      }
    }
  });
  receivePort.listen((message) {
    if (message is DeadMessage) {
      if (message is TaskDeadMessage) {
        assert(tasks.remove(message.senderPort));
      }
      if (message is ResourceDeadMessage) {
        assert(resources.remove(message.senderPort));
      }
      if (resources.isEmpty && tasks.isEmpty) {
        print('All died');
        stdinSub.cancel();
        receivePort.close();
      }
    }
  });
}
