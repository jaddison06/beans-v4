import 'ui/SDL/SDLDisplay.dart';
import 'ui/SDL/SDLFont.dart';
import 'ui/SDL/SDLEvent.dart';
import 'ui/V2.dart';
import 'ui/Colour.dart';
import 'dart_codegen.dart';

void main(List<String> arguments) {
  libSDLFont().Init();
  final display = SDLDisplay('beans', true);
  final font = SDLFont('res/Menlo Regular.ttf', 20);
  final event = SDLEvent();
  print('Successful init!');
  var quit = false;
  var pos = V2(0, 0);
  while (!quit) {
    while (event.Poll() > 0) {
      switch (event.type) {
        case EventType.Quit: quit = true; break;
        case EventType.MouseMove: pos = event.pos; break;
        default: {}
      }
    }
    display.DrawText(pos.toString(), pos, font, Colour(255, 255, 255));
    display.Paint();
  }
  display.Destroy();
  font.Destroy();
  libSDLFont().Quit();
}
