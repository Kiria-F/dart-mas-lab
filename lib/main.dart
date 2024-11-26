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
  var resources = <AgentInfo>{}..addAll(await Future.wait(
      [for (var settings in setup.resourceSetup) AgentInfo.fromFuture(settings.name, settings.spawn())]));
  setup.taskSetup.shuffle();
  var tasks = <AgentInfo>{}..addAll(
      await Future.wait([for (var settings in setup.taskSetup) AgentInfo.fromFuture(settings.name, settings.spawn())]));
  for (var task in tasks) {
    task.port.send(InitTaskMessage(resources: resources.map((e) => e.port)));
    sleep(Duration(milliseconds: 10));
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
    }
  });
  receivePort.listen((message) {
    switch (message) {
      case TaskDeadMessage task:
        assert(tasks.remove(task));
        continue anonymous;
      case ResourceDeadMessage resource:
        assert(resources.remove(resource));
        continue anonymous;
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

class AgentInfo {
  SendPort port;
  String name;

  AgentInfo(this.name, this.port);

  static Future<AgentInfo> fromFuture(String name, Future<SendPort> port) async {
    return AgentInfo(name, await port);
  }

  @override
  bool operator ==(Object other) {
    if (other is AgentInfo) {
      if (port == other.port && name == other.name) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(port, name);
}
