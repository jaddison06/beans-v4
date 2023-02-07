import '../V2.dart';
import '../Window.dart';
import '../Colour.dart';

class ColourWindow extends Window {
  int i = 0;

  final colours = [
    Colour.red,
    Colour.green,
    Colour.blue,
    Colour.cyan,
    Colour.magenta,
    Colour.yellow
  ];

  void nextI() {
    i++;
    if (i == colours.length) i = 0;
  }

  @override
  void paint(PaintDetails ctx) {
    print('Painting ColourWindow!');
    ctx.display.FillRect(ctx.pos, ctx.size, colours[i]);
  }
  
  @override
  void onMouseDown(V2 pos) {
    refreshWith(nextI);
  }
}