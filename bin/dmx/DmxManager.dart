import '../dart_codegen.dart';

import 'SacnInterface.dart';

enum Interface {
  Sacn
}

class UniverseData {
  Interface interface;
  int virtualUni;
  int mappedToUni;
  UniverseData(this.interface, this.virtualUni, this.mappedToUni);
}

// will eventually be responsible for mapping unis to outputs etc
class DmxManager {
  final Map<int, Universe> unis = {};

  final _sacn = SacnInterface();

  void init(List<UniverseData> config) {
    for (var uni in config) {
      switch (uni.interface) {
        case Interface.Sacn: {
          unis[uni.virtualUni] = _sacn.getUni(uni.mappedToUni);
          break;
        }
        default: throw 'Unsupported interface!';
      }
    }
  }

  void Send() {
    _sacn.Send();
  }

  void Destroy() {
    _sacn.Destroy();
  }
}