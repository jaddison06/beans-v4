class Colour {
  int r, g, b, a;
  Colour(this.r, this.g, this.b, [this.a = 255]);

  static Colour red = Colour(255, 0, 0);
  static Colour green = Colour(0, 255, 0);
  static Colour blue = Colour(0, 0, 255);
  static Colour cyan = Colour(0, 255, 255);
  static Colour magenta = Colour(255, 0, 255);
  static Colour yellow = Colour(255, 255, 0);
  static Colour white = Colour(255, 255, 255);
  static Colour black = Colour(0, 0, 0);
  static Colour transparent = Colour(0, 0, 0, 0);
}