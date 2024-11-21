import 'dart:isolate';

import 'package:mas_labs/agents/task/task.dart';

import '/agents/resource/resource.dart';

List<ResourceSettings> resourceSetup(SendPort rootPort) => [
      ResourceSettings(root: rootPort, name: 'A Big Brother', performance: 12.5),
      ResourceSettings(root: rootPort, name: 'B Scooterman', performance: 10.5),
      ResourceSettings(root: rootPort, name: 'C Walker', performance: 8.5),
      ResourceSettings(root: rootPort, name: 'D Gnome', performance: 4.0),
    ];

List<TaskSettings> taskSetup(SendPort rootPort) => [
      TaskSettings(root: rootPort, name: 'A Pure Diamond', info: TaskInfo(cost: 100, amount: 10)),
      TaskSettings(root: rootPort, name: 'B Golden Bar', info: TaskInfo(cost: 95, amount: 15)),
      TaskSettings(root: rootPort, name: 'C Rare Reagent', info: TaskInfo(cost: 90, amount: 20)),
      TaskSettings(root: rootPort, name: 'D Faberge Egg', info: TaskInfo(cost: 85, amount: 25)),
      TaskSettings(root: rootPort, name: 'E Gothic Sword', info: TaskInfo(cost: 80, amount: 30)),
      TaskSettings(root: rootPort, name: 'F Collectible Coin', info: TaskInfo(cost: 75, amount: 35)),
      TaskSettings(root: rootPort, name: 'G Acoustic Guitar', info: TaskInfo(cost: 70, amount: 40)),
      TaskSettings(root: rootPort, name: 'H Vintage Clock', info: TaskInfo(cost: 65, amount: 45)),
      TaskSettings(root: rootPort, name: 'K Natural Coat', info: TaskInfo(cost: 60, amount: 50)),
      TaskSettings(root: rootPort, name: 'L Blue Jeans', info: TaskInfo(cost: 55, amount: 55)),
      TaskSettings(root: rootPort, name: 'M Oak Table', info: TaskInfo(cost: 50, amount: 60)),
      TaskSettings(root: rootPort, name: 'N Warm Sweater', info: TaskInfo(cost: 45, amount: 65)),
      TaskSettings(root: rootPort, name: 'O Restraint Dinner', info: TaskInfo(cost: 40, amount: 70)),
      TaskSettings(root: rootPort, name: 'P Red Carpet', info: TaskInfo(cost: 35, amount: 75)),
      TaskSettings(root: rootPort, name: 'Q Anime Poster', info: TaskInfo(cost: 30, amount: 80)),
      TaskSettings(root: rootPort, name: 'R Lost Book', info: TaskInfo(cost: 25, amount: 85)),
      TaskSettings(root: rootPort, name: 'S Office Eraser', info: TaskInfo(cost: 20, amount: 90)),
      TaskSettings(root: rootPort, name: 'T Paper Rabbit', info: TaskInfo(cost: 15, amount: 95)),
      TaskSettings(root: rootPort, name: 'U Plastic Bag', info: TaskInfo(cost: 10, amount: 100)),
    ];
