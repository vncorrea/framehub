import 'package:flutter/material.dart';

class AboutViewModel extends ChangeNotifier {
  String get aboutText => '''
  O FrameHub é um aplicativo de compartilhamento de histórias por meio de fotos.\n
  Foi desenvolvido por:
    - Igor Bianchini Ulian
    - Vinícius Corrêa Goulart Silva
  
  Espero que vocês gostem do FrameHub!
''';
} 