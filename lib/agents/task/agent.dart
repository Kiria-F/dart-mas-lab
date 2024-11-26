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
      case OfferAcceptAbortedMessage offer:
        resources[offer.port] = null;
        offer.port.send(RequestOfferMessage(info: info, port: port, name: name));
      case ResourceDiedMessage resource:
        resources.remove(resource.port);
        if (activeOffer == resource.port) {
          activeOffer = null;
          reviewOffers();
        }
      case OfferChangedMessage offer:
        resources[offer.port] = offer.doneSeconds;
        reviewOffers();
      case DieMessage _:
        print('Task [ $name ] died\n');
        rootPort.send(TaskDiedMessage(name: name, port: port));
        receivePort.close();
    }
  }

  void pollResources({bool loud = true}) {}

  void reviewOffers() {
    var bestOffer = resources.entries.reduce((a, b) => a.value! < b.value! ? a : b);
    if (bestOffer.key != activeOffer) {
      activeOffer!.send(RejectOfferMessage(port: port, name: name));
      activeOffer = bestOffer.key;
      activeOffer!.send(AcceptOfferMessage(port: port, name: name));
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
