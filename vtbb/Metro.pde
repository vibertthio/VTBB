class Metro {
  boolean state;
  int elapsedTime;
  int localtime;
  int limit;
  int out;

  Metro(boolean ss, int ll) {
    state = ss;
    limit=ll;
  }

  boolean bang() {
    if (state == true) {
      elapsedTime = (millis() - localtime)%limit;
      if (elapsedTime<=100) {
        return true;
      }
    } 
    return false;
  }

  int currentTime() { 
    return millis();
  }
}