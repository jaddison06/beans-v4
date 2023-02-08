import 'Channel.dart';
import '../dmx/DmxManager.dart';
import 'FixtureType.dart';

class Engine {
  List<UniverseData> outputConfig() => [UniverseData(
    Interface.Sacn,
    1,
    1
  )];
  List<ChannelData> patch() => [ChannelData(
    1,
    1,
    'testDimmer'
  )];

  final dmx = DmxManager();
  List<Channel> channels = [];

  void initChannels() {
    for (var channel in patch()) {
      channels.add(Channel(
        channel.universe,
        channel.address,
        FixtureType.fromFile('res/fixturelibrary/${channel.fixtureType}.yaml')
      ));
    }
  }

  Engine() {
    dmx.init(outputConfig());
    initChannels();
  }

  void SendDmx() {
    for (var channel in channels) {
      for (var param in channel.info.allParams) {
        dmx.unis[channel.universe]![channel.address + param.dmx] = (
          255 * ((param.level - param.min) / (param.max - param.min))
        ).toInt();
      }
    }
    dmx.Send();
  }
}