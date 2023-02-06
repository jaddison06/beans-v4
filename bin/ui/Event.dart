import '../dart_codegen.dart';
import 'V2.dart';

abstract class Event {
  EventType get type;
  V2 get pos;
  Key get key;
  String get text;
  MouseButton get mouseButton;
  List<Modifier> get modifiers;

  int Poll();
  void Destroy();
}