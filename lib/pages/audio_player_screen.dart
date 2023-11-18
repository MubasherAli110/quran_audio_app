// ignore_for_file: prefer_typing_uninitialized_variables, unnecessary_null_comparison

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final assetsAudioPlayer = AssetsAudioPlayer();
  Duration totalDuration = Duration.zero;
  Duration remainingDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  double sliderValue = 0.0;
  double volume = 1.0;
  bool isShuffleEnabled = false;
  LoopMode loopMode = LoopMode.none;
  var audioPath;

  List<String> surahNames = [
    "Surah Al-Adiyat",
    "Surah Al-Qaria",
    "Surah Al-Inshirāḥ ",
    "Surah Al-Ḍuḥā ",
    "Surah Al-Layl",
    "Surah Al-Shams",
    "Surah Al-Balad",
    "Surah Al-Fajr",
    "Surah Al-Muzzammil",
    "Surah At-Talaq",
    "Surah Adh-Dhariyat",
  ];
  List<String> audioPaths = [
    'assets/audios/100.mp3',
    'assets/audios/101.mp3',
    'assets/audios/94.mp3',
    'assets/audios/93.mp3',
    'assets/audios/92.mp3',
    'assets/audios/91.mp3',
    'assets/audios/90.mp3',
    'assets/audios/89.mp3',
    'assets/audios/73.mp3',
    'assets/audios/65.mp3',
    'assets/audios/51.mp3',
  ];

  String currentSurahName = "";

  @override
  void initState() {
    super.initState();

    assetsAudioPlayer.realtimePlayingInfos.listen((info) {
      if (info != null) {
        setState(() {
          sliderValue = info.currentPosition.inMilliseconds.toDouble() /
              info.current!.audio.duration.inMilliseconds.toDouble();
          totalDuration = info.current!.audio.duration;
          remainingDuration = totalDuration - info.currentPosition;
          currentPosition = info.currentPosition;
          audioPath = info.current?.audio.assetAudioPath;
          currentSurahName = surahNames[audioPaths.indexOf(audioPath)];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Audio Quran',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.4,
            image: AssetImage(
              "assets/gif/bg.gif",
            ),
            fit: BoxFit.cover,
          ),
        ),
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  currentSurahName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(
                  height: 150,
                ),
                TextButton(
                  onPressed: () {
                    assetsAudioPlayer.open(
                      Playlist(
                          audios:
                              audioPaths.map((path) => Audio(path)).toList()),
                      loopMode: loopMode,
                    );
                  },
                  child: const Text(
                    "Play",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(currentPosition),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    SizedBox(
                      width: 240,
                      child: Slider(
                        thumbColor: Colors.white,
                        value: sliderValue,
                        onChanged: (newValue) {
                          setState(() {
                            sliderValue = newValue;
                          });
                        },
                        onChangeEnd: (value) {
                          final totalDuration = assetsAudioPlayer
                              .current.value!.audio.duration.inMilliseconds
                              .toDouble();

                          final newPosition = (value * totalDuration).toInt();
                          assetsAudioPlayer
                              .seek(Duration(milliseconds: newPosition));
                        },
                      ),
                    ),
                    Text(
                      formatDuration(totalDuration),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        assetsAudioPlayer.previous();
                      },
                      icon: const Icon(Icons.skip_previous),
                    ),
                    StreamBuilder<bool>(
                      stream: assetsAudioPlayer.isPlaying,
                      builder: (context, snapshot) {
                        final bool isPlaying = snapshot.data ?? false;
                        return IconButton(
                            color: Colors.white,
                            onPressed: () {
                              if (isPlaying) {
                                assetsAudioPlayer.pause();
                              } else {
                                assetsAudioPlayer.play();
                              }
                            },
                            icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow));
                      },
                    ),
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        assetsAudioPlayer.next();
                      },
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
