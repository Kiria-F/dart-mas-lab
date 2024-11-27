import 'package:mas_lab/agents/base/agent.dart';
import 'package:mas_lab/agents/base/messages.dart';
import 'package:mas_lab/agents/resource/messages.dart';
import 'package:mas_lab/agents/task/messages.dart';
import 'package:mas_lab/agents/task/settings.dart';
import 'package:mas_lab/messages.dart';
import 'package:mas_lab/shared.dart';

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

      case BaseMessage resource when resource is ResourceBornMessage || resource is ResourceUpdatedMessage:
        resources[resource] = null;
        resource.port.send(RequestOfferMessage(info: info, port: port, name: name));

      case OfferMessage offer:
        resources[offer] = offer.doneSeconds;
        if (_offersCollected()) {
          var bestOffer = resources.entries.reduce((a, b) => a.value! < b.value! ? a : b);
          if (bestOffer.key != activeOffer) {
            activeOffer?.port.send(RevokeAgreementMessage(port: port, name: name));
          }
          bestOffer.key.port.send(AcceptOfferMessage(port: port, name: name));
          activeOffer = bestOffer.key;
        }

      case OfferIrrelevantMessage offer:
        resources[offer] = null;
        offer.port.send(RequestOfferMessage(info: info, port: port, name: name));

      case ResourceDiedMessage resource:
        resources.remove(resource);
        if (activeOffer == resource) {
          activeOffer = null;
        }
        reviewOffers();

      case ScheduleChangedMessage offer:
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
      activeOffer?.port.send(RevokeAgreementMessage(port: port, name: name));
      activeOffer = bestOffer.key;
      activeOffer!.port.send(AcceptOfferMessage(port: port, name: name));
    }
  }
}
