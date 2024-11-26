import 'dart:isolate';

import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/main.dart';

class TaskSettings extends BaseSettings {
  final TaskInfoMini info;

  TaskSettings({required super.rootPort, required super.name, required this.info});

  @override
  BaseAgent createAgent() => TaskAgent(this);
}

class TaskAgent extends BaseAgent {
  final TaskInfoMini info;
  int foundResources = 0;
  List<Offer> offers = [];
  SendPort? activeResource;

  TaskAgent(TaskSettings settings)
      : info = settings.info,
        super(rootPort: settings.rootPort, name: settings.name);

  @override
  void listener(dynamic message) {
    if (message is KickTaskMessage) {
      print('Task [ $name ] started searching for the resource\n');
      foundResources = message.resources.length;
      for (var resource in message.resources) {
        resource.send(RequestOfferMessage(info: info, senderPort: port, senderName: name));
      }
    }
    if (message is OfferMessage) {
      print('Task [ $name ] got offer from resource [ ${message.senderName} ]\n');
      offers.add(Offer(task: info, doneSeconds: message.doneSeconds, offerer: message.senderPort));
      if (offers.length == foundResources) {
        var bestOffer = offers.reduce((a, b) => a.doneSeconds < b.doneSeconds ? a : b);
        bestOffer.offerer.send(AcceptOfferMessage(senderPort: port, senderName: name));
        for (var offer in offers) {
          if (offer != bestOffer) {
            offer.offerer.send(RejectOfferMessage(senderPort: port, senderName: name));
          }
        }
        port.send(DieMessage());
      }
    }
    if (message is DieMessage) {
      print('Task [ $name ] died\n');
      rootPort.send(TaskDeadMessage(senderName: name, senderPort: port));
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

class Offer {
  final TaskInfoMini task;
  final int doneSeconds;
  final SendPort offerer;

  Offer({required this.task, required this.doneSeconds, required this.offerer});
}
