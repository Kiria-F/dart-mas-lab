import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/base/base_message.dart';
import 'package:mas_labs/messages.dart';
import 'package:mas_labs/shared.dart';

import 'setup.dart';

void main() async {
  print('');
  var receivePort = ReceivePort();
  var setup = Setup(receivePort.sendPort);
  var resources = <AgentInfo>{}..addAll(await Future.wait(
      [for (var settings in setup.resourceSetup) AgentInfo.fromFuture(settings.name, settings.spawn())]));
  setup.taskSetup.shuffle();
  var tasks = <AgentInfo>{}..addAll(
      await Future.wait([for (var settings in setup.taskSetup) AgentInfo.fromFuture(settings.name, settings.spawn())]));
  for (var task in tasks) {
    task.port.send(InitTaskMessage(resources: resources));
  }
  var exiting = false;
  var stdinSub = stdin.transform(utf8.decoder).transform(LineSplitter()).listen((input) {
    if (input.isEmpty) return;
    print('${'=' * input.length}\n');
    var cmd = input.split(' ').first;
    var params = input.split(' ').sublist(1);
    switch (cmd) {
      case 'quit':
        if (!exiting) {
          exiting = true;
          for (var agent in tasks.followedBy(resources)) {
            agent.port.send(DieMessage());
          }
        }

      case 'view':
        var filteredResources = params.isEmpty ? resources : resources.where((r) => params.contains(r.name));
        for (var resource in filteredResources) {
          resource.port.send(ViewSchedule());
        }

      case 'kill':
        for (var name in params) {
          for (var agent in resources.followedBy(tasks).where((a) => a.name == name)) {
            agent.port.send(DieMessage());
          }
        }
    }
  });
  receivePort.listen((message) {
    switch (message) {
      case TaskDiedMessage task:
        assert(tasks.remove(task));
        continue anonymous;

      case ResourceDiedMessage resource:
        assert(resources.remove(resource));
        continue anonymous;

      case BroadcastMessage m:
        switch (m.targets) {
          case AgentType.resource:
            for (var r in resources) {
              r.port.send(m.message);
            }
          case AgentType.task:
            for (var t in tasks) {
              t.port.send(m.message);
            }
        }

      anonymous:
      case DeadMessage _:
        if (resources.isEmpty && tasks.isEmpty) {
          print('All agents successfully died\n');
          stdinSub.cancel();
          receivePort.close();
        }
    }
  });
}
