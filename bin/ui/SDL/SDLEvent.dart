import '../../dart_codegen.dart';
import '../EventPoller.dart';
import '../V2.dart';

class SDLEvent extends SDLEventRaw implements EventPoller {
  @override
  V2 get pos => V2.fromPointers(GetPos);

  @override
  Modifiers get modifiers => Modifiers(
    shift: HasShift(),
    control: HasControl(),
    alt: HasAlt(),
    caps: HasCaps()
  );
}