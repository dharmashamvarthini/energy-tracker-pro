import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> init() async {
    await _player.setSourceAsset('assets/sounds/alert.mp3');
  }

  static Future<void> playAlertSound() async {
    await _player.play(AssetSource('assets/sounds/alert.mp3'));
  }

  static Future<void> stopSound() async {
    await _player.stop();
  }
}