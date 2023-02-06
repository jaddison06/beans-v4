import '../Font.dart';
import '../../dart_codegen.dart';

class SDLFont extends SDLFontRaw implements Font {
  SDLFont(String family, int size) : super(family, size);
}