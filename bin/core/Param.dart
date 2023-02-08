class Param {
  final String name;
  final int min, max, home, dmx;
  final bool is16Bit;
  Param(this.name, this.min, this.max, this.home, this.dmx, this.is16Bit);
}

class LiveParam extends Param {
  int level;
  LiveParam(String name, int min, int max, int home, int dmx, bool is16Bit) :
    level = home,
    super(name, min, max, home, dmx, is16Bit);

  static LiveParam fromBase(Param param) => LiveParam(param.name, param.min, param.max, param.home, param.dmx, param.is16Bit);
}