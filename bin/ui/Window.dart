import 'UIManager.dart';
import 'Display.dart';
import 'V2.dart';

class PaintDetails {
  Display display;
  V2 pos;
  V2 size;
  PaintDetails(this.display, this.pos, this.size);
}

// extend this!!
// need:
//   - an extensible method to DECLARATIVELY draw contents
//   - a way of telling the manager shit's changed
//   - something behind the scenes to handle repaints etc

abstract class Window {
  bool needsPaint = true;

  void refreshWith(void Function() changeState) {
    changeState();
    needsPaint = true;
  }

  void paint(PaintDetails ctx);
}