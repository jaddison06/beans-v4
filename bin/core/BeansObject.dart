// range ::= num ('thru' num)
// selector ::= range ('+' | '-' range)*

// Either a range of values or just a single value
class Range {
  int start;
  int? end;
  RangeOperator? operator;
  Range(this.start, this.end, [this.operator]);
}

enum RangeOperator {
  Plus,
  Minus
}

typedef Selector = List<Range>;

abstract class Serializable {
  Serializable(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

abstract class BeansObject<T extends Serializable> {
  BeansObject(T info);
}