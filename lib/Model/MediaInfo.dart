class MediaInfo{
  
  
  
  int _duration;
  String _filepath;

  int get duration => _duration;

  set duration(int value) {
    _duration = value;
  }

  MediaInfo(this._duration, this._filepath);

  String get filepath => _filepath;

  set filepath(String value) {
    _filepath = value;
  }
}