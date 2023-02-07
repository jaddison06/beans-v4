import 'ui/SDL/SDLUI.dart';
import 'ui/V2.dart';
import 'ui/UIManager.dart';

import 'ui/windows/ColourWindow.dart';

void main(List<String> arguments) {
  final ui = SDLUI('beans', true);

  final manager = UIManager(ui);

  manager.addWindow(ColourWindow(), V2(5, 5), V2(50, 100));

  manager.go();
  
  ui.Destroy();
  V2.destroy();
}
