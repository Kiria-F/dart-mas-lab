import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/setup.dart';

void main() async {
  print('');
  var receivePort = ReceivePort();
  var setup = Setup(receivePort.sendPort);
  var resources = <SendPort>{};
  var tasks = <SendPort>{};
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

class KickTaskMessage {
  Set<SendPort> resources;

  KickTaskMessage({required this.resources});
}

class DieMessage {}
