abstract class Serializable {
  Serializable(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

abstract class BeansObject<T extends Serializable> {
  BeansObject(T info);
}