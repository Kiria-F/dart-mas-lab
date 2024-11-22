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
        super(root: settings.root, name: settings.name);

  @override
  void listener(dynamic message) {
    sleep(Duration(milliseconds: random.nextInt(500) + 250));
    if (message is StartMessage) {
      print('[1] Task [$name] started searching for the resource\n');
      foundResources = message.resources.length;
      for (var resource in message.resources) {
        resource.send(RequestMessage(info: info, sender: me, name: name));
      }
    }
    if (message is OfferMessage) {
      print('[3] Task [$name] got offer from resource [${message.sender}]\n');
      offers.add(Offer(task: info, doneSeconds: message.doneSeconds, offerer: message.sender));
      if (offers.length == foundResources) {
        var bestOffer = offers.reduce((a, b) => a.doneSeconds < b.doneSeconds ? a : b);
        bestOffer.offerer.send(AcceptMessage(sender: me));
        for (var offer in offers) {
          if (offer != bestOffer) {
            offer.offerer.send(RejectMessage(sender: me));
          }
        }

        root.send(TaskDoneMessage());
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
