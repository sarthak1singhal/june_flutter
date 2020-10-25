/*
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:video_player/video_player.dart';

class VideoRecordingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Container(
      color: Colors.black,
      child: VideoRecording(),
    );
  }
}

class VideoRecording extends StatefulWidget {
  @override
  _VideoRecordingState createState() => _VideoRecordingState();
}

class _VideoRecordingState extends BasePresenter<VideoRecording>
    with TickerProviderStateMixin<VideoRecording>, VideoControllerMixin
    implements VideoRecordingPresenterView {
  static const int startValue = 30;

  Stream<NativeDeviceOrientation> orientationChangeListener;
  int rotationQuarterTurns = 0;
  RecordingMode mode;
  String videoFilePath;
  VideoRecordingPresenter _presenter;
  List<CameraDescription> _cameras;
  CameraController _controller;
  int _selectedCamera;
  AnimationController _animationController;
  String _filePath;
  VideoPlayerController _videoController;
  VoidCallback _videoListener;

  _VideoRecordingState() {
    this._presenter = VideoRecordingPresenter(this);
  }

  @override
  void initState() {
    NativeDeviceOrientationCommunicator().orientation().then(
            (orientation) => setMountedState(() => rotationQuarterTurns = convertOrientationToQuarterTurns(orientation)));
    orientationChangeListener = NativeDeviceOrientationCommunicator().onOrientationChanged(useSensor: true)
      ..listen((NativeDeviceOrientation orientation) =>
          setMountedState(() => rotationQuarterTurns = convertOrientationToQuarterTurns(orientation)));

    mode = RecordingMode.ready;
    _selectedCamera = 0;
    _cameras = [];
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: startValue));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _presenter.onRecordingTap(true);
    });
    super.initState();
    _presenter.loadCameras();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _animationController?.dispose();
    _presenter?.dispose();
    _videoController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  int convertOrientationToQuarterTurns(NativeDeviceOrientation orientation) {
    int quarterTurns;
    switch (orientation) {
      case NativeDeviceOrientation.portraitUp:
      case NativeDeviceOrientation.unknown:
        quarterTurns = 0;
        break;
      case NativeDeviceOrientation.landscapeLeft:
        quarterTurns = 1;
        break;
      case NativeDeviceOrientation.portraitDown:
        quarterTurns = 2;
        break;
      case NativeDeviceOrientation.landscapeRight:
        quarterTurns = 3;
        break;
    }
    return quarterTurns;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _presenter.onCancelRecording();
      return false;
    },
    child: Stack(children: <Widget>[
      buildMainContent(),
      buildVideoRecordingController(),
    ]),
  );

  Container buildMainContent() =>
      Container(child: _controller != null ? buildCameraOrVideoPreview() : ProgressLoader());

  VideoRecordingController buildVideoRecordingController() => VideoRecordingController(
    mode,
    _cameras,
    StepTween(begin: startValue, end: 0).animate(_animationController),
    Tween<double>(begin: 0.0, end: 1.0).animate(_animationController),
        () => _presenter.onCancelRecording(),
        () => _presenter.onSelectNextCamera(_cameras, _selectedCamera),
        () => _presenter.onRecordingTap(mode == RecordingMode.recording),
        () => _presenter.onContinue(_filePath),
        () => _presenter.onRetry(_filePath),
    _presenter.onPlay,
    rotationQuarterTurns,
  );

  Widget buildCameraOrVideoPreview() => mode == RecordingMode.preview ? buildVideoPreview() : buildCameraPreview();

  @override
  void showCameras(CameraController controller, int selectedIndex, List<CameraDescription> cameras) =>
      setMountedState(() {
        _selectedCamera = selectedIndex;
        _cameras = cameras;
        _controller = controller;
      });

  @override
  void startRecording() => setMountedState(() {
    _animationController.forward();
    mode = RecordingMode.recording;
  });

  @override
  void stopRecording() => setMountedState(() {
    _animationController
      ..stop()
      ..reset();
    mode = RecordingMode.end;
  });

  @override
  void updateFilePath(filePath) => setMountedState(() => _filePath = filePath);

  @override
  void retryRecording() => setMountedState(() => mode = RecordingMode.ready);

  @override
  void startPreview() {
    if (mode != RecordingMode.preview) {
      setMountedState(() => mode = RecordingMode.preview);
    }
    _videoListener = () {
      if (mode == RecordingMode.preview && !_videoController.value.isPlaying) {
        _videoController.removeListener(_videoListener);
        setMountedState(() => mode = RecordingMode.end);
        return;
      }
    };
    _videoController = VideoPlayerController.file(File(_filePath))
      ..setLooping(false)
      ..initialize().then((_) => refreshState()) // refresh the state here to get the correct aspect ratio of the video.
      ..addListener(_videoListener)
      ..play();
  }

  Widget buildCameraPreview() => Center(
    child: CameraPreview(_controller),
  );

  double get videoPreviewAspectRatio {
    if (_videoController.value.size == null) {
      return 1.0;
    }

    double aspectRatio = _videoController.value.aspectRatio;
    bool isDeviceInLandscape = rotationQuarterTurns == 1 || rotationQuarterTurns == 3;

    return isDeviceInLandscape ? 1.0 / aspectRatio : aspectRatio;
  }

  Widget buildVideoPreview() => Center(
    child: Container(
      child: AspectRatio(
        aspectRatio: videoPreviewAspectRatio,
        child: RotatedBox(quarterTurns: rotationQuarterTurns, child: VideoPlayer(_videoController)),
      ),
    ),
  );

  @override
  void showCancelConfirmation() =>
      showGenericAlert("upload_alert_delete_post_title", "upload_alert_delete_post_message", [
        "upload_progress_page_alert_action_cancel",
        "upload_progress_page_alert_action_delete_recording",
      ]).then((value) => _presenter.onCancelAnswered("upload_progress_page_alert_action_cancel" == value));
}*/
