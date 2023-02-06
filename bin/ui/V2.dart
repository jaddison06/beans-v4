import 'dart:ffi';
import 'package:ffi/ffi.dart';

class V2 {
  static Pointer<Int32> _x = nullptr, _y = nullptr;

  static void _initPointers() {
    if (_x == nullptr) _x = malloc<Int32>();
    if (_y == nullptr) _y = malloc<Int32>();
  }

  static void destroy() {
    if (_x != nullptr) malloc.free(_x);
    if (_y != nullptr) malloc.free(_y);
  }

  final int x, y;
  V2(this.x, this.y);

  static V2 fromPointers(void Function(Pointer<Int32>, Pointer<Int32>) populate) {
    _initPointers();
    populate(_x, _y);
    return V2(_x.value, _y.value);
  }
}