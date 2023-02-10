import '../ui/EventPoller.dart';
import '../dart_codegen.dart';
import '../objects.dart';
import 'Engine.dart';

enum BCLTokenType {
  Key,
  Text
}

class BCLToken {
  BCLTokenType type;
  Key? key;
  String? text;
  Modifiers modifiers;
  BCLToken(this.type, this.key, this.text, this.modifiers);
}

class BeansCommandLine with CommandLineBase {
  final Engine engine;
  BeansCommandLine(this.engine);

  List<BCLToken> current = [];

  void processEvent(EventPoller event) {
    switch (event.type) {
      case EventType.Key: {
        switch (event.key) {
          case Key.Backspace: {
            if (event.modifiers.shift) {
              current.clear();
            } else if (current.isNotEmpty) {
              current.removeLast();
            }
            break;
          }
          case Key.Return: {
            // execute();
            break;
          }
          default: {
            current.add(BCLToken(
              BCLTokenType.Key,
              event.key,
              null,
              event.modifiers
            ));
            parse();
          }
        }
        break;
      }
      case EventType.Text: {
        current.add(BCLToken(
          BCLTokenType.Text,
          null,
          event.text,
          event.modifiers
        ));
        parse();
        break;
      }
      default: {}
    }
  }

  void parse() {
    
  }
}