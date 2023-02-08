import '../dart_codegen.dart';

class SacnInterface {
  Map<int, E131> configuredUnis = {};

  Universe getUni(int id) {
    if (!configuredUnis.containsKey(id)) configuredUnis[id] = E131('beans', '127.0.0.1', id);

    return configuredUnis[id]!.GetUniverseStart();
  }

  void Send() {
    for (var uni in configuredUnis.values) {
      uni.Send();
    }
  }

  void Destroy() {
    for (var uni in configuredUnis.values) {
      uni.Destroy();
    }
    configuredUnis = {};
  }
}