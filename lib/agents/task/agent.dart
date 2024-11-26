import 'package:mas_labs/agents/resource/messages.dart';
import 'package:mas_labs/agents/task/messages.dart';
import 'package:mas_labs/base/base_agent.dart';
import 'package:mas_labs/base/base_settings.dart';
import 'package:mas_labs/messages.dart';
import 'package:mas_labs/shared.dart';

class TaskSettings extends BaseSettings {
  final TaskInfoCore info;

  TaskSettings({required super.rootPort, required super.name, required this.info});

  @override
  BaseAgent createAgent() => TaskAgent(this);
}

class TaskAgent extends BaseAgent {
  final TaskInfoCore info;
  Map<AgentInfo, int?> resources = {};
  AgentInfo? activeOffer;

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
          resource.port.send(RequestOfferMessage(info: info, port: port, name: name));
        }

      case ResourceBornMessage resource:
        resources[resource] = null;
        resource.port.send(RequestOfferMessage(info: info, port: port, name: name));

      case ResourceUpdatedMessage resource:
        resources[resource] = null;
        resource.port.send(RequestOfferMessage(info: info, port: port, name: name));

      case OfferMessage offer:
        resources[offer] = offer.doneSeconds;
        if (_offersCollected()) {
          var bestOffer = resources.entries.reduce((a, b) => a.value! < b.value! ? a : b);
          if (bestOffer.key != activeOffer) {
            activeOffer?.port.send(RejectOfferMessage(port: port, name: name));
          }
          bestOffer.key.port.send(AcceptOfferMessage(port: port, name: name));
          activeOffer = bestOffer.key;
        }

      case OfferAcceptAbortedMessage offer:
        resources[offer] = null;
        offer.port.send(RequestOfferMessage(info: info, port: port, name: name));

      case ResourceDiedMessage resource:
        resources.remove(resource);
        if (activeOffer == resource) {
          activeOffer = null;
        }
        print('Task [ $name ] got to know about [ ${message.name} ] death\n');
        reviewOffers();
      case OfferChangedMessage offer:
        resources[offer] = offer.doneSeconds;
        reviewOffers();

      case DieMessage _:
        print('Task [ $name ] died\n');
        activeOffer?.port.send(TaskDiedMessage(name: name, port: port));
        rootPort.send(TaskDiedMessage(name: name, port: port));
        receivePort.close();
    }
  }

  void pollResources({bool loud = true}) {}

  void reviewOffers() {
    if (!_offersCollected()) return;
    var bestOffer = resources.entries.reduce((a, b) => a.value! < b.value! ? a : b);
    if (bestOffer.key != activeOffer) {
      activeOffer?.port.send(RejectOfferMessage(port: port, name: name));
      activeOffer = bestOffer.key;
      activeOffer!.port.send(AcceptOfferMessage(port: port, name: name));
    }
  }
}
