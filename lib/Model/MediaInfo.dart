class MediaInfo{
  
  
  
  double _duration;
  String _filepath;

  double get duration => _duration;

  set duration(double value) {
    _duration = value;
  }

  MediaInfo(this._duration, this._filepath);

  String get filepath => _filepath;

  set filepath(String value) {
    _filepath = value;
  }
}