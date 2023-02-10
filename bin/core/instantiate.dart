import 'dart:mirrors';

/// instantiate a Type
T instantiate<T>({
    Symbol constructorName = const Symbol(''),
    List<dynamic> positionalArguments = const [],
    Map<Symbol, dynamic> namedArguments = const {}
  }) {
  final mirror = reflectClass(T);
  return mirror.newInstance(constructorName, positionalArguments, namedArguments).reflectee;
}