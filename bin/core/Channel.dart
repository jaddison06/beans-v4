import 'FixtureType.dart';
import 'Param.dart';

class Channel {
  FixtureType<LiveParam> info;
  Channel(FixtureType<Param> fixtureType) :
    info = fixtureType.toLive();
}