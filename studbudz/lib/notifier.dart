import 'package:flutter/material.dart';
import 'package:studubdz/Engine/engine.dart';

class Controller extends ChangeNotifier {
  //instantiates the controller internally
  static final Controller _instance = Controller._internal();
  Controller._internal();

  //technically shouldn't be public but
  //I wanted to avoid needing to access it via an intermediary function
  late Engine engine;

  factory Controller() {
    return _instance; // always returns the same insance
  }

  void setEngine(Engine engine) {
    this.engine = engine;
  }
}
