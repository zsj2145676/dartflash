part of dartflash;

class _TweenProperty
{
  String name;
  num startValue;
  num targetValue;

  _TweenProperty(this.name, this.startValue, this.targetValue);
}

//-----------------------------------------------------------------------------------

class Tween implements Animatable
{
  DisplayObject _displayObject;
  TransitionFunction _transitionFunction;

  List<_TweenProperty> _tweenProperties;

  Function _onStart;
  Function _onUpdate;
  Function _onComplete;

  num _totalTime;
  num _currentTime;
  num _delay;
  bool _roundToInt;
  bool _started;

  Tween(DisplayObject displayObject, num time, [TransitionFunction transitionFunction = null])
  {
    _displayObject = displayObject;
    _transitionFunction = (transitionFunction != null) ? transitionFunction : Transitions.linear;

    _currentTime = 0.0;
    _totalTime = max(0.0001, time);
    _delay = 0.0;
    _roundToInt = false;
    _started = false;

    _tweenProperties = new List<_TweenProperty>();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void animate(String property, num targetValue)
  {
    var properties = ['x', 'y', 'pivotX', 'pivotY', 'scaleX', 'scaleY', 'rotation', 'alpha'];

    if (properties.indexOf(property) == -1)
      throw new ArgumentError("Error #9003: The supplied property ('$property') is not supported at this time.");

    if (_displayObject != null && _started == false)
      _tweenProperties.add(new _TweenProperty(property, 0.0, targetValue));
  }

  //-------------------------------------------------------------------------------------------------

  void scaleTo(num factor)
  {
    animate('scaleX', factor);
    animate('scaleY', factor);
  }

  //-------------------------------------------------------------------------------------------------

  void moveTo(num x, num y)
  {
    animate('x', x);
    animate('y', y);
  }

  //-------------------------------------------------------------------------------------------------

  void fadeTo(num alpha)
  {
    animate('alpha', alpha);
  }

  //-------------------------------------------------------------------------------------------------

  void complete()
  {
    if (this.isComplete == false)
      advanceTime(_totalTime - _currentTime);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time)
  {
    if (_currentTime < _totalTime || _started == false)
    {
      _currentTime = _currentTime + time;

      if (_currentTime > _totalTime)
        _currentTime = _totalTime;

      if (_currentTime >= 0.0)
      {
        if (_started == false)
        {
          _started = true;

          for(int i = 0; i < _tweenProperties.length; i++)
          {
            var tp = _tweenProperties[i];

            switch(tp.name) {
              case 'x':        tp.startValue = _displayObject.x; break;
              case 'y':        tp.startValue = _displayObject.y; break;
              case 'pivotX':   tp.startValue = _displayObject.pivotX; break;
              case 'pivotY':   tp.startValue = _displayObject.pivotY; break;
              case 'scaleX':   tp.startValue = _displayObject.scaleX; break;
              case 'scaleY':   tp.startValue = _displayObject.scaleY; break;
              case 'rotation': tp.startValue = _displayObject.rotation; break;
              case 'alpha':    tp.startValue = _displayObject.alpha; break;
            }
          }

          if (_onStart != null)
            _onStart();
        }

        //-------------

        num ratio = _currentTime / _totalTime;
        num transition = _transitionFunction(ratio);

        for(int i = 0; i < _tweenProperties.length; i++)
        {
          var tp = _tweenProperties[i];
          var value = tp.startValue + transition * (tp.targetValue - tp.startValue);
          value = _roundToInt ? value.round() : value;

          switch(tp.name) {
            case 'x':        _displayObject.x = value; break;
            case 'y':        _displayObject.y = value; break;
            case 'pivotX':   _displayObject.pivotX = value; break;
            case 'pivotY':   _displayObject.pivotY = value; break;
            case 'scaleX':   _displayObject.scaleX = value; break;
            case 'scaleY':   _displayObject.scaleY = value; break;
            case 'rotation': _displayObject.rotation = value; break;
            case 'alpha':    _displayObject.alpha = value; break;
          }
        }

        if (_onUpdate != null)
          _onUpdate();

        //-------------

        if (_onComplete != null && _currentTime == _totalTime)
          _onComplete();
      }
    }

    return _currentTime < _totalTime;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  DisplayObject get displayObject => _displayObject;
  num get totalTime => _totalTime;
  num get currentTime => _currentTime;
  num get delay => _delay;
  bool get roundToInt => _roundToInt;
  bool get isComplete => _currentTime >= _totalTime;

  set delay(num value)
  {
    if (_started == false)
      _currentTime = _currentTime + _delay - value;

    _delay = value;
  }

  set roundToInt(bool value)
  {
    _roundToInt = value;
  }

  //-------------------------------------------------------------------------------------------------

  Function get onStart => _onStart;
  Function get onUpdate => _onUpdate;
  Function get onComplete => _onComplete;

  void set onStart(Function value) { _onStart = value; }
  void set onUpdate(Function value) { _onUpdate = value; }
  void set onComplete(Function value) { _onComplete = value; }
}
