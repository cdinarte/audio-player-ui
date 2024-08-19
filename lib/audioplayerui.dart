library audioplayerui;

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayerui/ui/defaultUi.dart';
import 'package:audioplayerui/ui/simpleUi.dart';
import 'package:flutter/material.dart';

class AudioPlayerController {
  AudioPlayer audioPlayer = AudioPlayer();

  final bool autoPlay;

  AudioPlayerController({this.autoPlay = false});

  void play(String url) async {
    await audioPlayer.setSourceUrl(url);
    audioPlayer.resume();
  }

  void playLocal(String localPath) async {
    await audioPlayer.setSourceDeviceFile(localPath);
    audioPlayer.resume();
  }

  void pause() {
    audioPlayer.pause();
  }

  void stop() {
    audioPlayer.stop();
  }

  void resume() {
    audioPlayer.resume();
  }
}

class AudioPlayerView extends StatefulWidget {
  final AudioPlayerController audioPlayerController;
  final String? trackTitle;
  final String? trackSubtitle;
  final String trackUrl;
  final bool isLocal;
  final String? imageUrl;
  final bool simpleDesign;

  const AudioPlayerView({
    Key? key,
    required this.audioPlayerController,
    this.trackTitle,
    this.trackSubtitle,
    required this.trackUrl,
    this.isLocal = false,
    this.imageUrl,
    this.simpleDesign = false,
  }) : super(key: key);

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState(
    audioPlayerController,
    trackTitle,
    trackSubtitle,
    trackUrl,
    isLocal,
    imageUrl,
    simpleDesign,
  );
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  Duration duration = Duration();
  final AudioPlayerController audioPlayerController;
  late AudioPlayer audioPlayer;
  bool hasNext = false;
  bool hasPrevious = false;
  double playbackPosition = 0.0;
  PlayerState? audioPlayerState;
  final String? trackTitle;
  final String? trackSubtitle;
  final String trackUrl;
  final bool isLocal;
  final String? imageUrl;
  final bool simpleDesign;

  String trackPosition = "00:00";
  String trackLength = "00:00";

  _AudioPlayerViewState(
      this.audioPlayerController,
      this.trackTitle,
      this.trackSubtitle,
      this.trackUrl,
      this.isLocal,
      this.imageUrl,
      this.simpleDesign,
      );

  @override
  void initState() {
    audioPlayer = audioPlayerController.audioPlayer;
    if (audioPlayerController.autoPlay) {
      _playTrack();
    } else {
      _initTrackPlayback();
    }
    _initPositionChangeListener();
    _initTrackChangeListener();

    super.initState();
  }

  _initTrackPlayback() async {
    if (isLocal) {
      await audioPlayer.setSourceDeviceFile(trackUrl);
    } else {
      await audioPlayer.setSourceUrl(trackUrl);
    }

    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        trackLength = _printDuration(duration);
      });
    });
  }

  _playTrack() async {
    if (isLocal) {
      await audioPlayer.setSourceDeviceFile(trackUrl);
    } else {
      await audioPlayer.setSourceUrl(trackUrl);
    }
    audioPlayer.resume();
  }

  _initPositionChangeListener() async {
    audioPlayer.onPositionChanged.listen((Duration p) async {
      Duration? audioPlayerDuration = await audioPlayer.getDuration();
      if (audioPlayerDuration != null) {
        int trackDuration = audioPlayerDuration.inSeconds;
        String trackLengthFormat = _printDuration(audioPlayerDuration);
        String trackPositionFormat = _printDuration(p);

        setState(() {
          playbackPosition = (p.inSeconds / trackDuration).toDouble();
          trackLength = trackLengthFormat;
          trackPosition = trackPositionFormat;
        });
      }
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  _initTrackChangeListener() {
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        audioPlayerState = state;
      });
    });
  }

  _seekTrack(double position) async {
    Duration? audioPlayerDuration = await audioPlayer.getDuration();
    if (audioPlayerDuration != null) {
      int trackDuration = audioPlayerDuration.inSeconds;
      int seekPosition = (position * trackDuration).round();
      audioPlayer.seek(Duration(seconds: seekPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return simpleDesign
        ? SimpleUi(
      audioPlayer: audioPlayer,
      imageUrl: imageUrl,
      trackTitle: trackTitle,
      trackSubtitle: trackSubtitle,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
      playbackPosition: playbackPosition,
      audioPlayerState: audioPlayerState,
      trackPosition: trackPosition,
      trackLength: trackLength,
      seekTrack: _seekTrack,
      key: ValueKey("audioPlayerKey"),
    )
        : DefaultUi(
      audioPlayer: audioPlayer,
      imageUrl: imageUrl,
      trackTitle: trackTitle,
      trackSubtitle: trackSubtitle,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
      playbackPosition: playbackPosition,
      audioPlayerState: audioPlayerState,
      trackPosition: trackPosition,
      trackLength: trackLength,
      seekTrack: _seekTrack,
      key: ValueKey("audioPlayerKey"),
    );
  }

  @override
  void dispose() {
    audioPlayer.release();
    audioPlayer.dispose();
    super.dispose();
  }
}
