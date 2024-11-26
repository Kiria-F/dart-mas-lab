import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/messages.dart';

class TaskSettings extends BaseSettings {
  final TaskInfoMini info;

  TaskSettings({required super.rootPort, required super.name, required this.info});

  @override
  BaseAgent createAgent() => TaskAgent(this);
}

class TaskAgent extends BaseAgent {
  final TaskInfoMini info;
  Map<SendPort, int?> resources = {};
  SendPort? activeOffer;

  TaskAgent(TaskSettings settings)
      : info = settings.info,
        super(rootPort: settings.rootPort, name: settings.name);

  bool _offersCollected() => resources.values.fold(true, (a, b) => a && b != null);

  @override
  void listener(dynamic message) {
    switch (message) {
      case InitTaskMessage initData:
        print('Task [ $name ] started searching for the resource\n');
        for (var resource in initData.resources) {
          resources[resource] = null;
          resource.send(RequestOfferMessage(info: info, port: port, name: name));
        }
      case OfferMessage offer:
        print('Task [ $name ] got offer from resource [ ${offer.name} ]\n');
        resources[offer.port] = offer.doneSeconds;
        if (_offersCollected()) {
          var bestOffer = resources.entries.reduce((a, b) => a.value! < b.value! ? a : b);
          bestOffer.key.send(AcceptOfferMessage(port: port, name: name));
          for (var resource in resources.keys) {
            if (resource != bestOffer.key) {
              resource.send(RejectOfferMessage(port: port, name: name));
            }
          }
        }
      case DieMessage _:
        print('Task [ $name ] died\n');
        rootPort.send(TaskDeadMessage(name: name, port: port));
        receivePort.close();
    }
  }
}

class TaskInfoMini {
  final int amount;
  final int price;
  final double rate;

  TaskInfoMini({required this.amount, required this.price, required this.rate});

  TaskInfoMini.fromAnother(TaskInfoMini info)
      : amount = info.amount,
        price = info.price,
        rate = info.rate;
}
