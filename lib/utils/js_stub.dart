/// This file provides stub implementations of the dart:js functionality
/// for non-web platforms to avoid compilation errors.

// Stub class to mimic the JsObject from dart:js
class JsObject {
  final dynamic _obj;

  JsObject(this._obj);

  factory JsObject.fromBrowserObject(dynamic object) => JsObject(object);

  bool hasProperty(String name) => false;

  dynamic operator [](String name) => JsObject(null);

  operator []=(String name, dynamic value) {}

  dynamic callMethod(String method, [List? args]) => null;
}

// Stub variable to mimic context from dart:js
final context = JsObject(null);
