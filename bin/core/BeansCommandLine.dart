import '../ui/EventPoller.dart';
import '../dart_codegen.dart';
import 'BeansObject.dart';
import '../objects.dart';
import 'Engine.dart';

class BCLParseError implements Exception {
  final String message;
  BCLParseError(this.message);
}

enum BCLTokenType {
  Key,
  Text
}

class BCLToken {
  final BCLTokenType type;
  final Key? key;
  final String? text;
  final Modifiers modifiers;
  const BCLToken(this.type, this.key, this.text, this.modifiers);

  @override
  bool operator==(covariant BCLToken other) => (
    type == other.type &&
    key == other.key &&
    text == other.text &&
    modifiers.control == other.modifiers.control &&
    modifiers.alt == other.modifiers.alt
  );

  @override
  int get hashCode => Object.hash(type, key, text, modifiers);
}

class BCLProc {
  final String displayName;
  const BCLProc(this.displayName);
}

enum BCLMethodParamType {
  Int,
  Object
}

class BCLMethodParam {
  BCLMethodParamType type;
  BCLToken? object;
  BCLMethodParam(this.type, [this.object]);
}

class BCLMethod {
  final String displayName;
  final List<BCLMethodParam> paramTypes;
  const BCLMethod(this.displayName, this.paramTypes);
}

// uh oh!! this is where things start to get messy! don't forget to DECOUPLE!!!!!!!!!
class BCLObj {
  final String displayName;
  final Map<BCLToken, BCLMethod> methods;
  const BCLObj(this.displayName, this.methods);
}

/// - Start - haven't parsed anything yet
/// - ProcDetected - found a procedure name, need either object type or selector (implicit object)
/// - Sel_ShouldBeRangeStart - we **should** be parsing the **start** value of a range
/// - Sel_RangeStart - we're parsing the **start** value of a range
/// - Sel_ShouldBeRangeEnd - we **should** be parsing the **end** value of a range
/// - Sel_RangeEnd - we're parsing the **end** value of a range
/// - PrimaryObjSelected - we've got a selector either for the first argument of our proc or for the object to operate on
/// - ExpectMethodArg - we've successfully got an object method and are now in arguments - see supplementary state vars for more!
/// - InArg - we're in the argument, need either numbers or a method separator
enum _ParserState {
  Start,
  ProcDetected,
  Sel_ShouldBeRangeStart,
  Sel_RangeStart,
  Sel_ShouldBeRangeEnd,
  Sel_RangeEnd,
  PrimaryObjSelected,
  ExpectMethodArg,
  InArg
}

class BeansCommandLine with CommandLineBase {
  final Engine engine;
  BeansCommandLine(this.engine);

  List<BCLToken> current = [];

  bool _matchText(List<String> text, BCLToken tok) => tok.type == BCLTokenType.Text && text.contains(tok.text);

  bool isNum(BCLToken tok) => _matchText(const ['1', '2', '3', '4', '5', '6', '7', '8', '9'], tok);
  bool isRangeModifier(BCLToken tok) => _matchText(const ['t'], tok);
  bool isRangeOperator(BCLToken tok) => _matchText(const ['=', '-'], tok);
  bool isArgSeparator(BCLToken tok) => _matchText(const [','], tok);

  // todo: temporary implementation
  BCLToken defaultObjectType() => BCLToken(
    BCLTokenType.Text,
    null,
    'u',
    Modifiers.none()
  );

  bool isProc(BCLToken tok) => procedures.containsKey(tok);
  bool isObject(BCLToken tok) => objects.containsKey(tok);

  void parse() {
    var state = _ParserState.Start;
    BCLMethod? method;
    var methodParamIdx = 0;

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
            state = _ParserState.PrimaryObjSelected;
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
            state = _ParserState.PrimaryObjSelected;
          }
          break;
        }
        case _ParserState.PrimaryObjSelected: {
          if (isProc(current[0])) {
            // todo: secondary proc args?
            throw BCLParseError('Only single-arg procs supported at the moment');
          } else {
            //? what the fuck
            // if (current[0] == current[1])
            method = objects[current[0]]!.methods[token];
            if (method == null) {
              throw BCLParseError('Unknown method!');
            }
            state = _ParserState.ExpectMethodArg;
          }
          break;
        }
        case _ParserState.ExpectMethodArg: {
          switch (method!.paramTypes[methodParamIdx].type) {
            case BCLMethodParamType.Object: {
              if (isNum(token)) {
                current.insert(i, method.paramTypes[methodParamIdx].object!);
                i--;
              } else if (token != method.paramTypes[methodParamIdx].object) {
                throw BCLParseError('Wrong type for ${method.displayName}!');
              }
              break;
            }
            case BCLMethodParamType.Int: {
              if (!isNum(token)) {
                throw BCLParseError('Need a number!');
              }
            }
          }
          break;
        }
        case _ParserState.InArg: {
          if (isArgSeparator(token)) {
            methodParamIdx++;
            if (methodParamIdx >= method!.paramTypes.length) {
              throw BCLParseError('Too many parameters!');
            }
            state = _ParserState.ExpectMethodArg;
          } else if (!isNum(token)) {
            throw BCLParseError('Need a number!');
          }
        }
      }
    }
  }

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
}