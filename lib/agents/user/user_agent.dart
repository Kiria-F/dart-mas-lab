import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/agents/user/messages.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/setup.dart';

class UserSettings extends BaseSettings {
  BaseAgent? _userAgent;
  UserSettings({required super.parentPort}) : super(name: 'User');

  @override
  BaseAgent createAgent() {
    if (_userAgent == null) {
      _userAgent = UserAgent(this);
      (_userAgent as UserAgent).start();
    }
    return _userAgent ??= UserAgent(this);
  }
}

class UserAgent extends BaseAgent {
  var resources = <SendPort>{};
  var tasks = <SendPort>{};

  UserAgent(UserSettings settings) : super(parentPort: settings.parentPort, name: settings.name);

  Future<void> start() async {
    // stdin.transform(utf8.decoder).transform(LineSplitter()).listen((String input) {
    //   print('bruh');
    //   if (input == 'quit') {
    //     for (var task in tasks) {
    //       task.send(DieMessage());
    //     }
    //     for (var resource in resources) {
    //       resource.send(DieMessage());
    //     }
    //     // stdin.listen((_) {}).cancel();
    //     print('ok?');
    //   }
    // });
    var setup = Setup(receivePort.sendPort);
    // setup.taskSetup.shuffle();
    for (var settings in setup.resourceSetup) {
      var t = await settings.spawn();
      resources.add(t);
    }
    var t = await Future.wait([for (var settings in setup.resourceSetup) settings.spawn()]);
    resources.addAll(t);
    tasks.addAll(await Future.wait([for (var settings in setup.taskSetup) settings.spawn()]));
    for (var task in tasks) {
      task.send(KickTaskMessage(resources: resources));
      sleep(Duration(milliseconds: 10));
    }
  }

  @override
  void listener(message) {
    if (message is DieMessage) {
      print('user dying');
      for (var task in tasks) {
        task.send(DieMessage());
      }
      for (var resource in resources) {
        resource.send(DieMessage());
      }
    }
    if (message is ResourceDeadMessage || message is TaskDeadMessage) {
      if (message is ResourceDeadMessage) {
        resources.remove(message.senderPort);
        print('RESOURCE DEAD ${message.senderName}');
      }
      if (message is TaskDeadMessage) {
        tasks.remove(message.senderPort);
      }
      if (resources.isEmpty && tasks.isEmpty) {
        receivePort.close();
        // Isolate.current.kill();
        parentPort.send(DieMessage());
      }
    }
  }
}
