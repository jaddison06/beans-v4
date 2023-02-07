class Param {
  final String name;
  final int min, max, home, dmx;
  Param(this.name, this.min, this.max, this.home, this.dmx);
}

class LiveParam extends Param {
  int level;
  LiveParam(String name, int min, int max, int home, int dmx) :
    level = home,
    super(name, min, max, home, dmx);

  static LiveParam fromBase(Param param) => LiveParam(param.name, param.min, param.max, param.home, param.dmx);
}