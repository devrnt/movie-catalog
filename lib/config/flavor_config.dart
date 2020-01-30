import 'package:flutter/material.dart';

class FlavorConfig extends InheritedWidget {
  final Widget child;
  final FlavorBuild flavorBuild;

  FlavorConfig({@required this.child, @required this.flavorBuild});

  static FlavorConfig of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FlavorConfig>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

enum FlavorBuild { Free, Pro }
