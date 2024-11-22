import 'dart:io';
import 'dart:isolate';

import 'package:mas_labs/agents/resource/incoming.dart';
import 'package:mas_labs/agents/task/incoming.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/main.dart';

class TaskSettings extends BaseSettings {
  final TaskInfo info;

  TaskSettings({required super.root, required super.name, required this.info});

  @override
  BaseAgent createAgent() => TaskAgent(this);
}

class TaskAgent extends BaseAgent {
  final TaskInfo info;
  int foundResources = 0;
  List<Offer> offers = [];

  TaskAgent(TaskSettings settings)
      : info = settings.info,
        super(rootPort: settings.root, name: settings.name);

  @override
  void listener(dynamic message) {
    sleep(Duration(milliseconds: random.nextInt(500) + 250));
    if (message is StartMessage) {
      print('Task [ $name ] started searching for the resource\n');
      foundResources = message.resources.length;
      for (var resource in message.resources) {
        resource.send(RequestMessage(info: info, senderPort: port, senderName: name));
      }
    }
    if (message is OfferMessage) {
      print('Task [ $name ] got offer from resource [ ${message.senderName} ]\n');
      offers.add(Offer(task: info, doneSeconds: message.doneSeconds, offerer: message.senderPort));
      if (offers.length == foundResources) {
        var bestOffer = offers.reduce((a, b) => a.doneSeconds < b.doneSeconds ? a : b);
        bestOffer.offerer.send(AcceptMessage(senderPort: port, senderName: name));
        for (var offer in offers) {
          if (offer != bestOffer) {
            offer.offerer.send(RejectMessage(senderPort: port, senderName: name));
          }
        }

        rootPort.send(TaskDoneMessage());
        Isolate.current.kill();
      }
    }
  }
}

class TaskInfo {
  final int amount;
  final int price;
  final double rate;

  TaskInfo({required this.amount, required this.price, required this.rate});
}

class Offer {
  final TaskInfo task;
  final int doneSeconds;
  final SendPort offerer;

  Offer({required this.task, required this.doneSeconds, required this.offerer});
}
