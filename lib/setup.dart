import 'dart:isolate';

import 'package:mas_lab/agents/resource/settings.dart';
import 'package:mas_lab/agents/task/settings.dart';
import 'package:mas_lab/shared.dart';

class Setup {
  final SendPort rootPort;

  Setup(this.rootPort);

  List<ResourceSettings> get resourceSetup {
    return [
      ResourceSettings(rootPort: rootPort, name: 'R10', performance: 5),
      ResourceSettings(rootPort: rootPort, name: 'R9', performance: 4.5),
      ResourceSettings(rootPort: rootPort, name: 'R8', performance: 4),
      ResourceSettings(rootPort: rootPort, name: 'R7', performance: 3.5),
    ];
  }

  List<TaskSettings> get taskSetup {
    return [
      TaskSettings(rootPort: rootPort, name: 'A', info: TaskInfoCore(amount: 10, price: 90, rate: 0.30)),
      TaskSettings(rootPort: rootPort, name: 'B', info: TaskInfoCore(amount: 20, price: 85, rate: 0.25)),
      TaskSettings(rootPort: rootPort, name: 'C', info: TaskInfoCore(amount: 25, price: 95, rate: 0.35)),
      TaskSettings(rootPort: rootPort, name: 'D', info: TaskInfoCore(amount: 15, price: 80, rate: 0.20)),
      TaskSettings(rootPort: rootPort, name: 'K', info: TaskInfoCore(amount: 40, price: 90, rate: 0.015)),
      TaskSettings(rootPort: rootPort, name: 'L', info: TaskInfoCore(amount: 60, price: 85, rate: 0.020)),
      TaskSettings(rootPort: rootPort, name: 'M', info: TaskInfoCore(amount: 65, price: 95, rate: 0.025)),
      TaskSettings(rootPort: rootPort, name: 'N', info: TaskInfoCore(amount: 55, price: 80, rate: 0.010)),
      TaskSettings(rootPort: rootPort, name: 'O', info: TaskInfoCore(amount: 50, price: 85, rate: 0.015)),
      TaskSettings(rootPort: rootPort, name: 'P', info: TaskInfoCore(amount: 55, price: 90, rate: 0.020)),
      TaskSettings(rootPort: rootPort, name: 'X', info: TaskInfoCore(amount: 65, price: 10, rate: 0.020)),
      TaskSettings(rootPort: rootPort, name: 'Y', info: TaskInfoCore(amount: 65, price: 20, rate: 0.025)),
      TaskSettings(rootPort: rootPort, name: 'Z', info: TaskInfoCore(amount: 45, price: 15, rate: 0.010)),
    ];
  }
}
