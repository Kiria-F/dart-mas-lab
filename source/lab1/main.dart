import 'calculator.dart';
import 'number.dart';

void main() async {
  var c8rPort = await Calculator.spawn((initialValue: 0));
  var numberAdd3Port = await Number.spawn((
    value: 3,
    operation: (a, b) => a + b,
    calculatorPort: c8rPort,
  ));
  var numberTimes2Port = await Number.spawn((
    value: 2,
    operation: (a, b) => a * b,
    calculatorPort: c8rPort,
  ));
  numberAdd3Port.send('run');
  numberTimes2Port.send('run');
  numberAdd3Port.send('run');
  // await Future.delayed(Duration(hours: 1));
}
