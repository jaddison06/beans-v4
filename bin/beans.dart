import 'ui/SDL/SDLUI.dart';
import 'ui/V2.dart';
import 'ui/UIManager.dart';

import 'ui/windows/ColourWindow.dart';

import 'dart_codegen.dart';

void main(List<String> arguments) {
  // final ui = SDLUI('beans', true);

  // final manager = UIManager(ui);

  // manager.addWindow(ColourWindow(), V2(0, 0), V2(50, 50));
  // manager.addWindow(ColourWindow(), V2(55, 0), V2(50, 50));
  // manager.addWindow(ColourWindow(), V2(0, 55), V2(50, 50));
  // manager.addWindow(ColourWindow(), V2(55, 55), V2(50, 50));

  // manager.go();
  
  // ui.Destroy();
  // V2.destroy();

  final e131 = E131('beans', '127.0.0.1', 1);
  final universe = e131.GetUniverseStart();
  universe[1] = 255;
  while (true) {
    e131.Send();
  }
}
