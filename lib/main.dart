import 'package:mas_labs/agents/task/task.dart';

import 'setup.dart';

void main() async {
  var resources = await Future.wait([for (var settings in resourceSetup) settings.spawn()]);

  var taskInfoMessage = TaskInfo(
    cost: 40.5,
    seconds: 720,
  );

  resources[0].send(taskInfoMessage);
}
