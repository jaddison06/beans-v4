import 'Font.dart';
import 'V2.dart';
import 'Colour.dart';

abstract class Display {
  void DrawRect(V2 pos, V2 size, Colour col);
  void FillRect(V2 pos, V2 size, Colour col);
  void DrawText(String text, V2 pos, Font font, Colour col);

  void SetClip(V2 pos, V2 size);
  void ResetClip();
  void Clear(Colour col);

  // DOESN'T CLEAR JUST UPDATES!!
  void Paint();

  V2 get dimensions;
}