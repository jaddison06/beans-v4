import 'Font.dart';
import 'V2.dart';
import 'Colour.dart';

abstract class Display {
  void DrawRect(V2 pos, V2 size, Colour col);
  void FillRect(V2 pos, V2 size, Colour col);
  void DrawText(String text, V2 pos, Font font, Colour col);

  void Paint();

  V2 get dimensions;
}