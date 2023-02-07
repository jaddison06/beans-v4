import 'ui/SDL/SDLUI.dart';
import 'ui/V2.dart';
import 'ui/UIManager.dart';

import 'ui/windows/ColourWindow.dart';

void main(List<String> arguments) {
  final ui = SDLUI('beans', true);

  final manager = UIManager(ui);

  manager.addWindow(ColourWindow(), V2(0, 0), V2(50, 50));
  manager.addWindow(ColourWindow(), V2(55, 0), V2(50, 50));
  manager.addWindow(ColourWindow(), V2(0, 55), V2(50, 50));
  manager.addWindow(ColourWindow(), V2(55, 55), V2(50, 50));

  manager.go();
  
  ui.Destroy();
  V2.destroy();
}
