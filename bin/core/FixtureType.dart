import 'Param.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';

class FixtureType<T extends Param> {
  final List<T> intensity;
  final List<T> colour;
  final List<T> position;
  final List<T> gobo;
  final List<T> beam;

  List<T> get allParams => intensity + colour + position + gobo + beam;

  FixtureType({required this.intensity, required this.colour, required this.position, required this.gobo, required this.beam});

  static FixtureType<T> _fromFile<T extends Param>(String fname, T Function(String, int, int, int, int) createParam) {
    final contents = File(fname).readAsStringSync();

    final intensity = <T>[];
    final colour = <T>[];
    final position = <T>[];
    final gobo = <T>[];
    final beam = <T>[];

    final processAll = (void Function(T) addToList, YamlMap paramGroup) {
      for (var param in paramGroup.entries) {
        addToList(createParam(
          param.key,
          param.value['min']!,
          param.value['max']!,
          param.value['home']!,
          param.value['dmx']!
        ));
      }
    };

    try {
      final YamlMap doc = loadYaml(contents);
      for (MapEntry paramGroup in doc['params'].entries) {
        switch (paramGroup.key as String) {
          case 'intensity': {
            processAll((param) => intensity.add(param), paramGroup.value);
            break;
          }
          case 'colour': {
            processAll((param) => colour.add(param), paramGroup.value);
            break;
          }
          case 'position': {
            processAll((param) => position.add(param), paramGroup.value);
            break;
          }
          case 'gobo': {
            processAll((param) => gobo.add(param), paramGroup.value);
            break;
          }
          case 'beam': {
            processAll((param) => beam.add(param), paramGroup.value);
            break;
          }
        }
      }
    } catch (e) {
      print('Failed to load fixture from $fname: $e');
      exit(1);
    }

    return FixtureType(
      intensity: intensity,
      colour: colour,
      position: position,
      gobo: gobo,
      beam: beam
    );
  }

  static FixtureType<Param> fromFile(String fname) => _fromFile(fname, (name, min, max, home, dmx) => Param(name, min, max, home, dmx));
  static FixtureType<LiveParam> liveFromFile(String fname) => _fromFile(fname, (name, min, max, home, dmx) => LiveParam(name, min, max, home, dmx));

  List<LiveParam> _paramGroupToLive(List<Param> group) => group.map((param) => LiveParam.fromBase(param)).toList();

  FixtureType<LiveParam> toLive() => FixtureType(
    intensity: _paramGroupToLive(intensity),
    colour: _paramGroupToLive(colour),
    position: _paramGroupToLive(position),
    gobo: _paramGroupToLive(gobo),
    beam: _paramGroupToLive(beam)
  );
}