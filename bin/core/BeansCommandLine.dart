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

// range ::= num ('thru' num)
// selector ::= range ('+' | '-' range)*

// Either a range of values or just a single value
class Range {
  int start;
  int? end;
  RangeOperator? operator;
  Range(this.start, this.end, [this.operator]);
}

enum RangeOperator {
  Plus,
  Minus
}

typedef Selector = List<Range>;

/// - Start - haven't parsed anything yet
/// - ProcDetected - found a procedure name, need either object type or selector (implicit object)
/// - Sel_ShouldBeRangeStart - we **should** be parsing the **start** value of a range
/// - Sel_RangeStart - we're parsing the **start** value of a range
/// - Sel_ShouldBeRangeEnd - we **should** be parsing the **end** value of a range
/// - Sel_RangeEnd - we're parsing the **end** value of a range
enum _ParserState {
  Start,
  ProcDetected,
  Sel_ShouldBeRangeStart,
  Sel_RangeStart,
  Sel_ShouldBeRangeEnd,
  Sel_RangeEnd
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
            state = _ParserState.Sel_ShouldBeRangeStart;
          } else if (isNum(token)) {
            // implicit object selection - insert the object & reverse
            current.insert(0, defaultObjectType());
            i--;
            state = _ParserState.Sel_ShouldBeRangeStart;
          } else {
            // todo: more helpful error message - can't have 'XXX' here - needs toString() from codegen
            // which in turn needs disallowing of unknown events in the first place
            throw BCLParseError('Expected a procedure or selector');
          }
          break;
        }
        case _ParserState.ProcDetected: {
          // same object selection logic as detecting an object in _ParserState.Start
          if (isNum(token)) {
            current.insert(1, defaultObjectType());
            i--;
          } else if (isObject(token)) {
            state = _ParserState.Sel_ShouldBeRangeStart;
          } else {
            throw BCLParseError('Expected an object or selector');
          }
          break;
        }
        // todo: actually CHECK the object managers for existence
        case _ParserState.Sel_ShouldBeRangeStart: {
          if (!isNum(token)) throw BCLParseError('Expected a selector');
          state = _ParserState.Sel_RangeStart;
          break;
        }
        case _ParserState.Sel_RangeStart: {
          if (isRangeModifier(token)) {
            state = _ParserState.Sel_ShouldBeRangeEnd;
          } else if (isRangeOperator(token)) {
            state = _ParserState.Sel_ShouldBeRangeStart;
          } else if (!isNum(token)) {
            // we're out of the selectory frying pan and into the fire!
          }
          break;
        }
        case _ParserState.Sel_ShouldBeRangeEnd: {
          if (!isNum(token)) throw BCLParseError('Expected another ID');
          state = _ParserState.Sel_RangeEnd;
          break;
        }
        case _ParserState.Sel_RangeEnd: {
          if (isRangeModifier(token)) {
            throw BCLParseError("Can't have 'thru' here!");
          } else if (isRangeOperator(token)) {
            state = _ParserState.Sel_ShouldBeRangeStart;
          } else if (!isNum(token)) {
            // once again, out of the range and into the meaty bit!!
          }
        }
      }
    }
  }
}