import 'dart:collection';

import 'package:vine/vine.dart';

class VineFieldPool {
  static final _pool = Queue<VineField>();
  static final int _maxSize = 1000;

  static VineField acquire(String name, dynamic value) {
    if (_pool.isEmpty) return VineField(name, value);
    return _pool.removeFirst()
      ..name = name
      ..value = value
      ..canBeContinue = true
      ..customKeys.clear();
  }

  static void release(VineField field) {
    if (_pool.length < _maxSize) {
      _pool.add(field);
    }
  }
}
