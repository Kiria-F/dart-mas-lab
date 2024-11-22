import 'dart:isolate';

import 'package:mas_labs/agents/task/task.dart';

import '/agents/resource/resource.dart';

List<ResourceSettings> resourceSetup(SendPort rootPort) => [
      ResourceSettings(root: rootPort, name: 'W12', performance: 12.5),
      ResourceSettings(root: rootPort, name: 'W10', performance: 10.5),
      ResourceSettings(root: rootPort, name: 'W8', performance: 8.0),
      ResourceSettings(root: rootPort, name: 'W6', performance: 6.5),
    ];

List<TaskSettings> taskSetup(SendPort rootPort) => [
      TaskSettings(root: rootPort, name: 'A Task', info: TaskInfo(amount: 10, cost: 90, rate: 0.95)),
      TaskSettings(root: rootPort, name: 'B Task', info: TaskInfo(amount: 20, cost: 85, rate: 0.90)),
      TaskSettings(root: rootPort, name: 'C Task', info: TaskInfo(amount: 25, cost: 95, rate: 0.80)),
      TaskSettings(root: rootPort, name: 'D Task', info: TaskInfo(amount: 15, cost: 80, rate: 0.85)),
      TaskSettings(root: rootPort, name: 'K Task', info: TaskInfo(amount: 40, cost: 90, rate: 0.15)),
      TaskSettings(root: rootPort, name: 'L Task', info: TaskInfo(amount: 60, cost: 85, rate: 0.20)),
      TaskSettings(root: rootPort, name: 'M Task', info: TaskInfo(amount: 65, cost: 95, rate: 0.25)),
      TaskSettings(root: rootPort, name: 'N Task', info: TaskInfo(amount: 55, cost: 80, rate: 0.10)),
      TaskSettings(root: rootPort, name: 'O Task', info: TaskInfo(amount: 50, cost: 85, rate: 0.15)),
      TaskSettings(root: rootPort, name: 'P Task', info: TaskInfo(amount: 55, cost: 90, rate: 0.20)),
      TaskSettings(root: rootPort, name: 'X Task', info: TaskInfo(amount: 65, cost: 10, rate: 0.20)),
      TaskSettings(root: rootPort, name: 'Y Task', info: TaskInfo(amount: 65, cost: 20, rate: 0.25)),
      TaskSettings(root: rootPort, name: 'Z Task', info: TaskInfo(amount: 45, cost: 15, rate: 0.10)),
    ];
