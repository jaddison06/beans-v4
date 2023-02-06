import 'ui/SDL/SDLDisplay.dart';
import 'ui/SDL/SDLFont.dart';
import 'ui/V2.dart';
import 'ui/Colour.dart';
import 'dart_codegen.dart';

void main(List<String> arguments) {
  libSDLFont().Init();
  final display = SDLDisplay('beans', false);
  final font = SDLFont('res/Menlo Regular.ttf', 20);
  print('Successful init!');
  for (var i = 0; i < 500; i++) {
    display.DrawText('cock and balls', V2(5, 5), font, Colour(255, 255, 255));
    display.Paint();
  }
  display.Destroy();
  libSDLFont().Quit();
}
