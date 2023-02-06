import '../../dart_codegen.dart';
import '../Event.dart';
import '../V2.dart';

class SDLEvent extends SDLEventRaw implements Event {
  @override
  V2 get pos => V2.fromPointers(GetPos);

  @override
  List<Modifier> get modifiers {
    var out = <Modifier>[];

    if (HasShift()) out.add(Modifier.Shift);
    if (HasControl()) out.add(Modifier.Control);
    if (HasAlt()) out.add(Modifier.Alt);
    if (HasCaps()) out.add(Modifier.Caps);

    return out;
  }
}