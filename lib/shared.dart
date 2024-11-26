import 'dart:isolate';

class AgentInfo {
  SendPort port;
  String name;

  AgentInfo(this.name, this.port);

  static Future<AgentInfo> fromFuture(String name, Future<SendPort> port) async {
    return AgentInfo(name, await port);
  }

  @override
  bool operator ==(Object other) {
    if (other is! AgentInfo) return false;
    return port == other.port && name == other.name;
  }

  @override
  int get hashCode => Object.hash(port, name);
}

class TaskInfoCore {
  final int amount;
  final int price;
  final double rate;

  TaskInfoCore({required this.amount, required this.price, required this.rate});

  TaskInfoCore.fromAnother(TaskInfoCore info)
      : amount = info.amount,
        price = info.price,
        rate = info.rate;

  @override
  bool operator ==(Object other) =>
      other is TaskInfoCore &&
      other.runtimeType == runtimeType &&
      other.amount == amount &&
      other.price == price &&
      other.rate == rate;

  @override
  int get hashCode => Object.hash(amount, price, rate);
}

class TaskInfo extends TaskInfoCore {
  final SendPort port;
  final String name;

  TaskInfo.fromCore(super.info, this.port, this.name) : super.fromAnother();

  TaskInfo.fromAnother(TaskInfo super.info)
      : port = info.port,
        name = info.name,
        super.fromAnother();

  @override
  bool operator ==(Object other) =>
      other is TaskInfo && other.runtimeType == runtimeType && other.port == port && other.name == name;

  @override
  int get hashCode => Object.hash(super.hashCode, port, name);
}
