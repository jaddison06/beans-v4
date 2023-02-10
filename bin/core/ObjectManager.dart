import 'BeansObject.dart';
import 'instantiate.dart';

class ObjectManager<T extends Serializable, O extends BeansObject<T>> {
  Map<int, O> objects = {};
  ObjectManager(Map<int, dynamic> json) {
    for (var entry in json.entries) {
      // oh my god
      objects[entry.key] = instantiate<O>(positionalArguments: [instantiate<T>(positionalArguments: entry.value)]);
    }
  }
}