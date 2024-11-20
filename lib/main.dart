import 'agents/resource/incoming.dart';
import 'setup.dart';

void main() async {
  var resources = await Future.wait([for (var settings in resourceSetup) settings.spawn()]);

  var taskInfoMessage = TaskInfoMessage(
    amount: 10.5,
    price: 8.5,
  );

  resources[0].send(taskInfoMessage);
}
