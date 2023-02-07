import '../NativeUI.dart';

import 'SDLDisplay.dart';
import 'SDLEvent.dart';
import 'SDLFont.dart';
import '../../dart_codegen.dart';

class SDLUI extends NativeUI {
  @override
  final SDLDisplay display;
  @override
  final SDLEvent event;

  SDLUI(String title, bool fullscreen) :
    display = SDLDisplay(title, fullscreen),
    event = SDLEvent() {
      libSDLFont().Init();
  }

  @override
  SDLFont getFont(String family, int size) => SDLFont(family, size);
  
  @override
  void Destroy() {
    display.Destroy();
    event.Destroy();
    libSDLFont().Quit();
  }
}