import '../ui/EventPoller.dart';
import '../dart_codegen.dart';
import '../objects.dart';
import 'Engine.dart';

enum CommandLineTokenType {
  Key,
  Text
}

class CommandLineToken {
  CommandLineTokenType type;
  Key? key;
  String? text;
  Modifiers modifiers;
  CommandLineToken(this.type, this.key, this.text, this.modifiers);
}

class CommandLine with CommandLineBase {
  final Engine engine;
  CommandLine(this.engine);

  List<CommandLineToken> current = [];

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
            execute();
            break;
          }
          default: {
            current.add(CommandLineToken(
              CommandLineTokenType.Key,
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
        current.add(CommandLineToken(
          CommandLineTokenType.Text,
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