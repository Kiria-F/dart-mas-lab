import 'package:mas_labs/agents/task/task.dart';
import 'package:mas_labs/base/base_message.dart';

class RequestMessage extends BaseMessage {
  final TaskInfo info;
  final String name;

  RequestMessage({required this.info, required super.sender, required this.name});
}

class AcceptMessage extends BaseMessage {
  AcceptMessage({required super.sender});
}

class KysMessage {}
