import 'ui/SDL/SDLUI.dart';
import 'ui/V2.dart';
import 'ui/UIManager.dart';

import 'ui/windows/ColourWindow.dart';

import 'dart_codegen.dart';

import 'core/Engine.dart';

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
  
  libhelloWorld().helloWorld();

  final engine = Engine();
  engine.channels[0].info.intensity[0].level = 515;
  while (true) {
    engine.SendDmx();
  }
}
