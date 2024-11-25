import 'dart:isolate';

import 'package:mas_labs/agents/user/messages.dart';
import 'package:mas_labs/agents/user/user_agent.dart';

void main() async {
  print('');
  var receivePort = ReceivePort();
  var user = await UserSettings(parentPort: receivePort.sendPort).spawn();
  receivePort.listen((message) {
    if (message is DieMessage) {
      print('It must die');
      receivePort.close();
      Isolate.current.kill();
    }
  });
  user.send(DieMessage());
}
