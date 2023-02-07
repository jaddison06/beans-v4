import '../Display.dart';
import 'SDLFont.dart';
import '../V2.dart';
import '../Colour.dart';
import '../../dart_codegen.dart';

class SDLDisplay extends SDLDisplayRaw implements Display {
  SDLDisplay(String title, bool fullscreen) : super(title, fullscreen) {
    if (errorCode != SDLInitErrorCode.Success) throw SDLInitErrorCodeToString(errorCode);
  }

  @override
  void SetClip(V2 pos, V2 size) {
    cSetClip(pos.x, pos.y, size.x, size.y);
  }

  @override
  void Clear(Colour col) {
    cClear(col.r, col.g, col.b, col.a);
  }

  @override
  V2 get dimensions {
    return V2.fromPointers((x, y) => GetSize(x, y));
  }

  @override
  void DrawRect(V2 pos, V2 size, Colour col) {
    cDrawRect(pos.x, pos.y, size.x, size.y, col.r, col.g, col.b, col.a);
  }

  @override
  void FillRect(V2 pos, V2 size, Colour col) {
    cFillRect(pos.x, pos.y, size.x, size.y, col.r, col.g, col.b, col.a);
  }
  
  @override
  void DrawText(String text, V2 pos, covariant SDLFont font, Colour col) {
    cDrawText(font, text, pos.x, pos.y, col.r, col.g, col.b, col.a);
  }
}