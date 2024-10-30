import 'calculator.dart';
import 'number.dart';

void main() async {
  final c8rPort = await C8rSettings().spawn();
  final numberAdd3Port = await NumberSettings(
    value: 3,
    operation: (a, b) => a + b,
    calculatorPort: c8rPort,
  ).spawn();
  final numberTimes2Port = await NumberSettings(
    value: 2,
    operation: (a, b) => a * b,
    calculatorPort: c8rPort,
  ).spawn();
  numberAdd3Port.send('run');
  numberTimes2Port.send('run');
  numberAdd3Port.send('run');
  // await Future.delayed(Duration(hours: 1));
}
