library countdown.base;

import "dart:async";

class CountDown {


  DateTime _begin;
  Timer _timer;
  Duration _duration;
  Duration remainingTime;
  bool isPaused = false;
  StreamController<Duration> _controller;
  Duration _refresh;

  int _everyTick, counter = 0;



  CountDown(Duration duration, {Duration refresh: const Duration(milliseconds: 10), int everyTick: 1}) {
    _refresh = refresh;
    _everyTick = everyTick;

    this._duration = duration;
    _controller = new StreamController<Duration>(onListen: _onListen, onPause: _onPause, onResume: _onResume, onCancel: _onCancel);
  }

  Stream<Duration> get stream => _controller.stream;


  _onListen() {
    // reference point
    _begin = new DateTime.now();
    _timer = new Timer.periodic(_refresh, _tick);
  }


  _onPause() {
    isPaused = true;
    _timer.cancel();
    _timer = null;
  }


  _onResume() {
    _begin = new DateTime.now();

    _duration = this.remainingTime;
    isPaused = false;


    _timer = new Timer.periodic(_refresh, _tick);
  }

  _onCancel() {

    if (!isPaused) {
      _timer.cancel();
      _timer = null;
    }

  }

  void _tick(Timer timer) {
    counter++;
    Duration alreadyConsumed = new DateTime.now().difference(_begin);
    this.remainingTime = this._duration - alreadyConsumed;
    if (this.remainingTime.isNegative) {
      timer.cancel();
      timer = null;

      _controller.close();
    } else {

      if (counter % _everyTick == 0) {
        _controller.add(this.remainingTime);
        counter = 0;
      }
    }
  }

}