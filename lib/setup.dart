import 'dart:isolate';

import 'package:mas_labs/agents/task/task.dart';

import '/agents/resource/resource.dart';

class Setup {
  final SendPort rootPort;

  Setup(this.rootPort);

  List<ResourceSettings> get resourceSetup {
    return [
      ResourceSettings(root: rootPort, name: 'W12', performance: 4.0),
      // ResourceSettings(root: rootPort, name: 'W10', performance: 4.1),
      // ResourceSettings(root: rootPort, name: 'W8', performance: 4.2),
      // ResourceSettings(root: rootPort, name: 'W6', performance: 4.3),
    ];
  }

  List<TaskSettings> get taskSetup {
    return [
      TaskSettings(root: rootPort, name: 'A Task', info: TaskInfo(amount: 10, price: 90, rate: 0.30)),
      TaskSettings(root: rootPort, name: 'B Task', info: TaskInfo(amount: 20, price: 85, rate: 0.25)),
      TaskSettings(root: rootPort, name: 'C Task', info: TaskInfo(amount: 25, price: 95, rate: 0.35)),
      TaskSettings(root: rootPort, name: 'D Task', info: TaskInfo(amount: 15, price: 80, rate: 0.20)),
      TaskSettings(root: rootPort, name: 'K Task', info: TaskInfo(amount: 40, price: 90, rate: 0.015)),
      TaskSettings(root: rootPort, name: 'L Task', info: TaskInfo(amount: 60, price: 85, rate: 0.020)),
      TaskSettings(root: rootPort, name: 'M Task', info: TaskInfo(amount: 65, price: 95, rate: 0.025)),
      TaskSettings(root: rootPort, name: 'N Task', info: TaskInfo(amount: 55, price: 80, rate: 0.010)),
      TaskSettings(root: rootPort, name: 'O Task', info: TaskInfo(amount: 50, price: 85, rate: 0.015)),
      TaskSettings(root: rootPort, name: 'P Task', info: TaskInfo(amount: 55, price: 90, rate: 0.020)),
      TaskSettings(root: rootPort, name: 'X Task', info: TaskInfo(amount: 65, price: 10, rate: 0.020)),
      TaskSettings(root: rootPort, name: 'Y Task', info: TaskInfo(amount: 65, price: 20, rate: 0.025)),
      TaskSettings(root: rootPort, name: 'Z Task', info: TaskInfo(amount: 45, price: 15, rate: 0.010)),
    ];
  }
}
