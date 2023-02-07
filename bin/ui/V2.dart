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

  bool containedBy(V2 pos, V2 size) {
    return (
      x >= pos.x &&
      y >= pos.y &&
      x <= (pos.x + size.x) &&
      y <= (pos.y + size.y)
    );
  }

  V2 operator +(Object other) {
    if (other is V2) {
      return V2(
        x + other.x,
        y + other.y
      );
    } else if (other is int) {
      return V2(
        x + other,
        y + other
      );
    } else {
      throw "Can't add a V2 and a ${other.runtimeType}";
    }
  }

  V2 operator -() {
    return V2(-x, -y);
  }

  V2 operator -(Object other) {
    if (other is V2) {
      return this + -other;
    } else if (other is int) {
      return this + -other;
    } else {
      throw "Can't subtract a V2 and a ${other.runtimeType}";
    }
  }

  @override
  String toString() => '($x, $y)';
}