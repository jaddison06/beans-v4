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

enum _SelectorState {
  RangeStart,
  RangeEnd
}

enum _ParserState {
  Start,
  ProcDetected,
  ObjectDetected,
  ImplicitObject
}

class BCLParseError implements Exception {
  final String message;
  BCLParseError(this.message);
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

  bool isNum(BCLToken tok) => tok.type == BCLTokenType.Text && const ['1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(tok.text);
  bool isRangeModifier(BCLToken tok) => tok.type == BCLTokenType.Text && const ['t'].contains(tok.text);
  bool isRangeOperator(BCLToken tok) => tok.type == BCLTokenType.Text && const ['=', '-'].contains(tok.text);

  // range ::= num ('thru' num)
  // selector ::= range ('+' | '-' range)*
  //
  // todo: actually CHECK the object managers for existence
  int selector(int start) {
    if (!isNum(current[start])) return 0;
    var end = start;
    var state = _SelectorState.RangeStart;
    outer: while (end < current.length) {
      switch (state) {
        case _SelectorState.RangeStart: {
          if (isRangeModifier(current[end])) {
            end++;
            if (!isNum(current[end])) {
              throw BCLParseError('Expected an ID');
            }
            state = _SelectorState.RangeEnd;
          } else if (isRangeOperator(current[end])) {
            end++;
          } else if (isNum(current[end])) {
            end++;
          } else {
            break outer;
          }
          break;
        }
        case _SelectorState.RangeEnd: {
          if (isRangeOperator(current[end])) {
            end++;
            if (!isNum(current[end])) {
              throw BCLParseError('Expected an ID');
            }
            state = _SelectorState.RangeStart;
          } else if (isNum(current[end])) {
            end++;
          } else if (isRangeModifier(current[end])) {
            throw BCLParseError('Expected a new range');
          } else {
            break outer;
          }
        }
      }      
    }

    return end - start;
  }

  // todo: temporary implementation
  BCLToken defaultObjectType() => BCLToken(
    BCLTokenType.Text,
    null,
    'u',
    Modifiers.none()
  );

  void parse() {
    var state = _ParserState.Start;
    for (var i = 0; i < current.length; i++) {
      final token = current[i];
      switch (state) {
        case _ParserState.Start: {
          if (isProc(token)) {
            state = _ParserState.ProcDetected;
          } else if (isObject(token)) {
            state = _ParserState.ObjectDetected;
          } else if (isNum(token)) {
            // implicit object selection
            current.insert(0, defaultObjectType());
            state = _ParserState.ImplicitObject;
          } else {
            // todo: more helpful error message - can't have 'XXX' here - needs toString() from codegen
            // which in turn needs disallowing of unknown events in the first place
            throw BCLParseError('Expected procedure or selector');
          }
          break;
        }
        case _ParserState.ObjectDetected: {

        }
      }
    }
    if (current.isEmpty) return;
    if (isProc(current.first)) {
      if (current.length >= 2) {
        if (isNum(current[1])) {
          current.insert(1, defaultObjectType());
        }
      }
    } else if (isObject(current.first)) {

    } else {
      // error!
    }
  }
}