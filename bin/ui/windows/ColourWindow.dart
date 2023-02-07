import '../Window.dart';
import '../Colour.dart';

class ColourWindow extends Window {
  Colour col = Colour(255, 0, 0, 255);

  @override
  void paint(PaintDetails ctx) {
    print('Painting ColourWindow!');
    ctx.display.FillRect(ctx.pos, ctx.size, col);
  }
}