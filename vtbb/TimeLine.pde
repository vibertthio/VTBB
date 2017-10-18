class TimeLine {
  boolean state;
  int localtime;
  int limit;
  int elapsedTime;
  int repeatTime = 3;
  boolean breathState = false;

  float linerRate = 4;

  TimeLine(int sec) {
    limit=sec;
    state=false;
  }

  float liner() {
    if (state == true) {
      elapsedTime = millis() - localtime;

      if (elapsedTime>int(limit)) {
        elapsedTime = int(limit);
        state=false;
      }
    }
    return pow(float(elapsedTime)/limit,linerRate);
  }

  float repeatBreathMovement() {
    if (state == true) {
      //println("check!!!!");
      elapsedTime = millis() - localtime;
      if (elapsedTime>int(limit)) {
        elapsedTime = int(limit);
        if(repeatTime < 1 && breathState) {
          state = false; }
        else {
          if(breathState == true)
            repeatTime-- ;
          breathState = !breathState;
          startTimer();
        }
      }
    }

    float t = float(elapsedTime)/limit;
    if(!breathState) {
      return pow(t, linerRate); }
    else {
      return pow((t-1), linerRate); }
  }

  void setLinerRate(float r) { linerRate = r; }
  void setRepeatTime(int t) { repeatTime = t; }

  boolean startTimer() {
    if (state == true) {
      localtime = currentTime();
      elapsedTime = 0;
      return false;
    }
    else {
      localtime = currentTime();
      state=true;
      elapsedTime = 0;
      return true;
    }
  }

  int currentTime() {
    return millis();
  }
}
