import 'package:flutter/material.dart';

final ValueNotifier<Key> appRestartNotifier = ValueNotifier(UniqueKey());

void restartApp() {
  appRestartNotifier.value = UniqueKey();
}
