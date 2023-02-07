import 'Window.dart';
import 'V2.dart';
import 'NativeUI.dart';
import '../dart_codegen.dart';
import 'Colour.dart';

class _WindowInfo {
  V2 pos;
  V2 size;
  Window window;
  _WindowInfo(this.window, this.pos, this.size);
}

class UIManager {
  final List<_WindowInfo> _windows = [];
  final NativeUI _ui;

  Window? _receiveMouseEvents;
  V2? _dragStart;

  UIManager(this._ui);

  bool _quit = false;

  void addWindow(Window window, V2 pos, V2 size) => _windows.add(_WindowInfo(window, pos, size));

  void _paintAll() {
    for (var window in _windows) {
      if (window.window.needsPaint) {
        _ui.display.SetClip(window.pos, window.size);
        _ui.display.Clear(Colour.black);
        window.window.paint(PaintDetails(_ui.display, window.pos, window.size));
        _ui.display.ResetClip();
        window.window.needsPaint = false;
      }
    }
    _ui.display.Paint();
  }
  
  Window? _windowContaining(V2 hit) {
    for (var window in _windows) {
      if (hit.containedBy(window.pos, window.size)) return window.window;
    }
  }

  void _processAllEvents() {
    while (_ui.event.Poll() > 0) {
      switch (_ui.event.type) {
        case EventType.MouseDown: {
          _receiveMouseEvents = _windowContaining(_ui.event.pos);
          _receiveMouseEvents?.onMouseDown(_ui.event.pos);
          _dragStart = (_receiveMouseEvents == null ? null : _ui.event.pos);
          break;
        }
        case EventType.MouseMove: {
          if (_receiveMouseEvents != null) {
            _receiveMouseEvents!.onMouseDrag(_ui.event.pos - _dragStart!);
          } else {
            _windowContaining(_ui.event.pos)?.onMouseOver(_ui.event.pos);
          }
          break;
        }
        case EventType.MouseUp: {
          (_receiveMouseEvents ?? _windowContaining(_ui.event.pos))?.onMouseUp(_ui.event.pos);
          _receiveMouseEvents = null;
          break;
        }
        case EventType.Quit: _quit = true; break;
        default: {}
      }
    }
  }

  void go() {
    while (!_quit) {
      _processAllEvents();
      _paintAll();
    }
  }
}