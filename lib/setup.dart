import 'dart:isolate';

import 'package:mas_labs/agents/task/task.dart';

import '/agents/resource/resource.dart';

class Setup {
  final SendPort rootPort;

  Setup(this.rootPort);

  List<ResourceSettings> get resourceSetup {
    return [
      ResourceSettings(root: rootPort, name: 'W10', performance: 5),
      ResourceSettings(root: rootPort, name: 'W9', performance: 4.5),
      ResourceSettings(root: rootPort, name: 'W8', performance: 4),
      ResourceSettings(root: rootPort, name: 'W7', performance: 3.5),
    ];
  }

  List<TaskSettings> get taskSetup {
    return [
      TaskSettings(root: rootPort, name: 'A', info: TaskInfo(amount: 10, price: 90, rate: 0.30)),
      TaskSettings(root: rootPort, name: 'B', info: TaskInfo(amount: 20, price: 85, rate: 0.25)),
      TaskSettings(root: rootPort, name: 'C', info: TaskInfo(amount: 25, price: 95, rate: 0.35)),
      TaskSettings(root: rootPort, name: 'D', info: TaskInfo(amount: 15, price: 80, rate: 0.20)),
      TaskSettings(root: rootPort, name: 'K', info: TaskInfo(amount: 40, price: 90, rate: 0.015)),
      TaskSettings(root: rootPort, name: 'L', info: TaskInfo(amount: 60, price: 85, rate: 0.020)),
      TaskSettings(root: rootPort, name: 'M', info: TaskInfo(amount: 65, price: 95, rate: 0.025)),
      TaskSettings(root: rootPort, name: 'N', info: TaskInfo(amount: 55, price: 80, rate: 0.010)),
      TaskSettings(root: rootPort, name: 'O', info: TaskInfo(amount: 50, price: 85, rate: 0.015)),
      TaskSettings(root: rootPort, name: 'P', info: TaskInfo(amount: 55, price: 90, rate: 0.020)),
      TaskSettings(root: rootPort, name: 'X', info: TaskInfo(amount: 65, price: 10, rate: 0.020)),
      TaskSettings(root: rootPort, name: 'Y', info: TaskInfo(amount: 65, price: 20, rate: 0.025)),
      TaskSettings(root: rootPort, name: 'Z', info: TaskInfo(amount: 45, price: 15, rate: 0.010)),
    ];
  }
}
