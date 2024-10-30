import 'dart:mirrors';

class C {
  int n;

  C(this.n) {
    print('Constructed [$n]');
  }

  int get getn => n;

  void qwerty() {
    print('qwe');
  }
}

constructor(Function f, dynamic settings) {
  return f('', settings);
}

void main() {
  final owner = reflectClass(C);
  var c = owner.newInstance(Symbol(''), [10]);
  if (c is C) {
    var cc = c as C;
    print(cc.getn);
  }
  // var c = constructor(owner.newInstance, 10);
}
