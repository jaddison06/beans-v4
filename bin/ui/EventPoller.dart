import '../dart_codegen.dart';
import 'V2.dart';

class Modifiers {
  final bool shift;
  final bool control;
  final bool alt;
  final bool caps;
  const Modifiers({required this.shift, required this.control, required this.alt, required this.caps});

  static Modifiers none() => Modifiers(shift: false, control: false, alt: false, caps: false);

  @override
  bool operator==(covariant Modifiers other) => (
    shift == other.shift &&
    control == other.control &&
    alt == other.alt &&
    caps == other.caps
  );

  @override
  int get hashCode => Object.hash(shift, control, alt, caps);
}

abstract class EventPoller {
  EventType get type;
  V2 get pos;
  Key get key;
  String get text;
  MouseButton get mouseButton;
  Modifiers get modifiers;

  int Poll();
  void Destroy();
}