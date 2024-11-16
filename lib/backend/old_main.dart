import 'calculator.dart';
import 'number.dart';

void main() async {
  // Порт актора калькулятора
  final c8rPort = await C8rSettings().spawn();

  // Порт актора числа
  final numberAdd3Port = await NumberSettings(
    value: 3,
    operation: (a, b) => a + b,
    calculatorPort: c8rPort,
  ).spawn();

  // Порт актора числа
  final numberTimes2Port = await NumberSettings(
    value: 2,
    operation: (a, b) => a * b,
    calculatorPort: c8rPort,
  ).spawn();

  // Отправка сигналам акторам
  numberAdd3Port.send('run');
  numberTimes2Port.send('run');
  numberAdd3Port.send('run');
  // await Future.delayed(Duration(hours: 1));
}
