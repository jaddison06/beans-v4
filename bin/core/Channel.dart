import 'FixtureType.dart';
import 'Param.dart';

class ChannelData {
  int universe;
  int address;
  String fixtureType;
  ChannelData(this.universe, this.address, this.fixtureType);
}

// todo: we need to remodel this LiveParam business

class Channel {
  int universe;
  int address;
  FixtureType<LiveParam> info;
  Channel(this.universe, this.address, FixtureType<Param> fixtureType) :
    info = fixtureType.toLive();
}