import 'package:mas_labs/agents/task/task.dart';

abstract final class Tools {
  static double calcValue(TaskInfoMini task, int doneSeconds) {
    assert(0 < task.rate && task.rate < 1);
    var decreaser = 1 - task.rate;
    var resultPrice = task.price.toDouble();
    for (var i = 0; i < doneSeconds; i++) {
      resultPrice *= decreaser;
    }
    return resultPrice;
  }

  static String visualizeSchedule({
    required List<({String name, int seconds})> plan,
    ({String name, int seconds, int index})? insertion,
  }) {
    double wrapper = 5;
    var insertionDone = insertion == null;
    StringBuffer planRender = StringBuffer('[ ');
    StringBuffer anchorRender = StringBuffer('  ');
    StringBuffer insertionRender = StringBuffer('  ');

    for (var i = 0; i < plan.length; i++) {
      if (insertion != null && i == insertion.index) {
        planRender.write(' ');
        anchorRender.write('^');
        insertionRender.write(insertion.name[0] * (insertion.seconds / wrapper).ceil());
        insertionDone = true;
      }
      var size = (plan[i].seconds / wrapper).ceil();
      planRender.write(plan[i].name[0] * size);
      if (!insertionDone) {
        anchorRender.write(' ' * size);
        insertionRender.write(' ' * size);
      }
    }
    if (insertion != null && insertion.index == plan.length) {
      anchorRender.write('^');
      insertionRender.write(insertion.name[0] * (insertion.seconds / wrapper).ceil());
    }
    planRender.write(' ]');
    var render = StringBuffer();
    render.writeln(planRender);
    if (insertion != null) {
      render.writeln(anchorRender);
      render.writeln(insertionRender);
    }
    return render.toString();
  }
}
