import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:mas_lab/agents/base/messages.dart';
import 'package:mas_lab/agents/resource/messages.dart';
import 'package:mas_lab/agents/resource/settings.dart';
import 'package:mas_lab/agents/task/messages.dart';
import 'package:mas_lab/agents/task/settings.dart';
import 'package:mas_lab/messages.dart';
import 'package:mas_lab/shared.dart';

import 'setup.dart';

void main() async {
  print('');
  var receivePort = ReceivePort();
  var setup = Setup(receivePort.sendPort);
  var resources = <AgentInfo>{}..addAll(await Future.wait([for (var settings in setup.resourceSetup) AgentInfo.fromFuture(settings.name, settings.spawn())]));
  setup.taskSetup.shuffle();
  var tasks = <AgentInfo>{}..addAll(await Future.wait([for (var settings in setup.taskSetup) AgentInfo.fromFuture(settings.name, settings.spawn())]));
  for (var task in tasks) {
    task.port.send(InitTaskMessage(resources: resources));
  }
  var exiting = false;
  var stdinSub = stdin.transform(utf8.decoder).transform(LineSplitter()).listen((input) async {
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

      case 'bring':
        switch (params) {
          case ['Resource' || 'resource', var name, var performanceStr]:
            var performance = double.tryParse(performanceStr);
            if (performance == null) break;
            var resource = AgentInfo(name, await ResourceSettings(rootPort: receivePort.sendPort, name: name, performance: performance).spawn());
            receivePort.sendPort.send(BroadcastMessage(ResourceBornMessage(name: resource.name, port: resource.port), AgentType.task));
            resources.add(resource);

          case ['Task' || 'task', var name, var amountStr, var priceStr, var rateStr]:
            var amount = int.tryParse(amountStr);
            var price = int.tryParse(priceStr);
            var rate = double.tryParse(rateStr);
            if (amount == null || price == null || rate == null) break;
            var task = AgentInfo(
                name, await TaskSettings(rootPort: receivePort.sendPort, name: name, info: TaskInfoCore(amount: amount, price: price, rate: rate)).spawn());
            tasks.add(task);
            task.port.send(InitTaskMessage(resources: resources));

          case _:
            print('Incorrect command, acceptable variants:\n- bring resource <name> <performance>\n- bring task <name> <amount> <price> <rate>\n');
        }
      case _:
        print('Incorrect command, acceptable variants:\nbring, view, kill, qiut\n');
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
