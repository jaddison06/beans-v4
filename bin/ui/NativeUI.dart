import 'Display.dart';
import 'EventPoller.dart';
import 'Font.dart';

abstract class NativeUI {
  Display get display;
  EventPoller get event;

  Font getFont(String family, int size);

  void Destroy();
}