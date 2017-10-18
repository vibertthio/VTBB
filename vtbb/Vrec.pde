class Vrec {
  //variables
  float xpos, ypos, xi, yi;
  float xdes, ydes;
  float wid, hei;
  Vrec[] childVrecs;
  boolean appearance = true;
  boolean lineAppearance = false;

  //the distance of seperation
  float gap = 100;

  //the movement velocity
  int movingTime = 1000;
  float v_offset = 0;
  float accel = 5;
  float base = 1.01;
  float a = 2*gap/pow(float(movingTime),2);

  //time variable
  int bornTime;
  int startMovingTime;
  int reachedTime = 2147483647;
  int vibrateTime = 5000;
  int rotateTime = 2000;
  int breathTime = 500;

  //for static movement
  TimeLine moveTimer = new TimeLine(movingTime);
  TimeLine vibrateTimer = new TimeLine(vibrateTime);
  TimeLine rotateTimer = new TimeLine(rotateTime);
  TimeLine breathTimer = new TimeLine(breathTime);


  //color
  color lineColor = color(90, 82, 87);


  //constructor
  Vrec(float x, float y, float w, float h, float _x, float _y) {
    xpos = x;
    ypos = y;
    xi = x;
    yi = y;
    wid  = w;
    hei  = h;
    xdes = _x;
    ydes = _y;
    childVrecs = new Vrec[2];
    bornTime = millis();

  }


  //functions
  void splitRec() {
    appearance = false;
    lineAppearance = true;
    if( wid > hei ) {
      //split the Vrec
      if (random(0,1) < 0.5) {
        childVrecs[0] = new Vrec(xpos, ypos, wid/2,
                           hei, xpos-gap/2, ypos);
        childVrecs[1] = new Vrec(xpos+wid/2, ypos, wid/2,
                           hei, (xpos+wid/2+gap/2), ypos);
      }
      else {
        childVrecs[1] = new Vrec(xpos, ypos, wid/2,
                           hei, xpos-gap/2, ypos);
        childVrecs[0] = new Vrec(xpos+wid/2, ypos, wid/2,
                           hei, (xpos+wid/2+gap/2), ypos);
      }
    }

    else {
      if (random(0,1) < 0.5) {
        childVrecs[0] = new Vrec(xpos, ypos, wid,
                           hei/2, xpos, ypos-gap/2);
        childVrecs[1] = new Vrec(xpos, ypos+hei/2, wid,
                           hei/2, xpos, (ypos+hei/2+gap/2));
      }
      else {
        childVrecs[1] = new Vrec(xpos, ypos, wid,
                           hei/2, xpos, ypos-gap/2);
        childVrecs[0] = new Vrec(xpos, ypos+hei/2, wid,
                           hei/2, xpos, (ypos+hei/2+gap/2));
      }
    }

    childVrecs[0].startTimer();
    childVrecs[1].startTimer();
  }

  void mergeRec() {
    if(wid > hei) {
      childVrecs[0].xdes = childVrecs[0].xi;
        childVrecs[0].xi = childVrecs[0].xpos;
      childVrecs[1].xdes = childVrecs[1].xi;
        childVrecs[1].xi = childVrecs[1].xpos;
    }
    else {
      childVrecs[0].ydes = childVrecs[0].yi;
        childVrecs[0].yi = childVrecs[0].ypos;
      childVrecs[1].ydes = childVrecs[1].yi;
        childVrecs[1].yi = childVrecs[1].ypos;
    }
    //childVrecs[0].lineAppearance = false;
    //childVrecs[0].appearance = true;
    childVrecs[0].startTimer();
    childVrecs[1].startTimer();
  }

  void display(color c, float transparent) {
    if(vibrate && reached()) {
      vibrate(c, transparent);
    }

    else if(rotation && reached()) {
      rotation(c, transparent);
    }

    else if( breath && reached()) {
      breath(c, transparent);
    }

    else {
      staticDisplay(c, transparent);
    }

  }

  void fade(boolean fadeIn, float rate, color c, float transparent) {
    //compress the signal
    if(rate > 1)
      rate = 1;

    if(fadeIn)
      transparent = rate* transparent;
    else
      transparent = transparent * (1 - rate);

    noStroke();
    fill(c, transparent);
    rect(xpos, ypos, wid, hei);

  }

  void updateLocation() {
    float _xpos, _ypos;
    if(xpos != xdes) {
      _xpos = xi -
        0.5 * a * pow((millis()-startMovingTime),2)
        * ((xpos - xdes)/abs(xpos - xdes));
      _xpos = xi + (xdes - xi)*(moveTimer.liner());

      //check if next position is over!
      if ( (_xpos - xdes)*(xdes - xpos)>0 )
        xpos = xdes;
      else
        xpos = _xpos;
    }
    if(ypos != ydes){
      _ypos = yi -
        0.5 * a * pow((millis()-startMovingTime),2)
        * ((ypos - ydes)/abs(ypos - ydes));
      _ypos = yi + (ydes - yi)*(moveTimer.liner());

      //check if next position is over!
      if ( (_ypos - ydes)*(ydes - ypos)>0 )
        ypos = ydes;
      else
        ypos = _ypos;
    }

    //remember the time when reached
    if(xpos == xdes && ypos == ydes && millis()<reachedTime)
      reachedTime = millis();
  }

  boolean reached() {
    if((xpos == xdes) && (ypos == ydes))
      return true;
    else return false;
  }

  void resetInitialPos() {
    xi = xpos;
    yi = ypos;
  }

  int getBornTime() {
    return bornTime;
  }

  int getReachedTime() {
    return reachedTime;
  }

  void resetReachedTime() { reachedTime = 2147483647; }
  void setStartMovingTime() { startMovingTime = millis(); }

  void startTimer() {
    moveTimer.localtime = moveTimer.currentTime();
    moveTimer.state=true;
  }

  //extended function
  boolean vibrate = false;
  //float vibrateIntensity = (wid*hei)*10;
  float vibrateIntensity = 4;
  float vibrateDivergeRate = 0.6;

  boolean breath = false;
  float breathIntensity = 0.15;
  float breathMoveRate = 2;

  boolean rotation = false;
  float rotateAngle = PI;
  float rotateDivergeRate = 3;

  void triggerVibrate() {
    vibrate = !vibrate;
    vibrateTimer.setLinerRate(vibrateDivergeRate);
    vibrateTimer.startTimer();
  }
  void triggerBreath() {
    breath = !breath;
    breathTimer.setLinerRate(breathMoveRate);
    breathTimer.startTimer();
  }
  void triggerRotate() {
    rotation = !rotation;
    rotateTimer.setLinerRate(rotateDivergeRate);
    rotateTimer.startTimer();
  }

  void vibrate(color c, float transparent) {
    float x, y;
    if(appearance) {
      noStroke();
      fill(c, transparent);
      x = xpos + vibrateIntensity*random(-1, 1)*(1-vibrateTimer.liner());
      y = ypos + vibrateIntensity*random(-1, 1)*(1-vibrateTimer.liner());
      rect(x, y, wid, hei);
    }
    if(lineAppearance) {
      stroke(lineColor, transparent);
      patternLine(int(childVrecs[0].xpos+(childVrecs[0].wid)/2),
                  int(childVrecs[0].ypos+(childVrecs[0].hei)/2),
                  int(childVrecs[1].xpos+(childVrecs[1].wid)/2),
                  int(childVrecs[1].ypos+(childVrecs[1].hei)/2), 0x5555, 8);
    }
  }

  //TODO
  void breath(color c, float transparent) {
    //println("breath check");
    float x, y, w, h;
    float rate;
    if(appearance) {
      noStroke();
      fill(c, transparent);
      rate = breathTimer.repeatBreathMovement();
      //println("rate: " + rate);
      x = xpos - (breathIntensity/2) * wid * rate;
      y = ypos - (breathIntensity/2) * hei * rate;
      w = (1 + breathIntensity * rate)* wid;
      h = (1 + breathIntensity * rate)* hei;

      translate(x,y);
      rect(0, 0, w, h);
      translate(-x, -y);

    }
    if(lineAppearance) {
      stroke(lineColor, transparent);
      patternLine(int(childVrecs[0].xpos+(childVrecs[0].wid)/2),
                  int(childVrecs[0].ypos+(childVrecs[0].hei)/2),
                  int(childVrecs[1].xpos+(childVrecs[1].wid)/2),
                  int(childVrecs[1].ypos+(childVrecs[1].hei)/2), 0x5555, 8);
    }
  }

  void rotation(color c, float transparent) {
    if(appearance) {
      noStroke();
      fill(c, transparent);
      float angle = rotateAngle*rotateTimer.liner();

      translate(xpos + wid/2, ypos + hei/2);
      rotate(angle);
      rect(-wid/2, -hei/2, wid, hei);
      rotate(-angle);
      translate(-(xpos + wid/2), -(ypos + hei/2));
    }

    if(lineAppearance) {
      stroke(lineColor, transparent);
      patternLine(int(childVrecs[0].xpos+(childVrecs[0].wid)/2),
                  int(childVrecs[0].ypos+(childVrecs[0].hei)/2),
                  int(childVrecs[1].xpos+(childVrecs[1].wid)/2),
                  int(childVrecs[1].ypos+(childVrecs[1].hei)/2), 0x5555, 8);
    }
  }

  void staticDisplay(color c, float transparent) {
    if(appearance) {
      noStroke();
      fill(c, transparent);
      rect(xpos, ypos, wid, hei);
    }
    if(lineAppearance) {
      stroke(lineColor, transparent);
      patternLine(int(childVrecs[0].xpos+(childVrecs[0].wid)/2),
                  int(childVrecs[0].ypos+(childVrecs[0].hei)/2),
                  int(childVrecs[1].xpos+(childVrecs[1].wid)/2),
                  int(childVrecs[1].ypos+(childVrecs[1].hei)/2), 0x5555, 8);
    }
  }

  //Sound functions
  boolean hasSplitSound = false;
  boolean hasMergeSound = false;
  boolean hasNoise = false;
  boolean hasRotate = false;
  boolean hasBreath = false;

  float whRatioPartition[] = {0.95, 0.85, 0.7, 0.6};
  float areaPartition[] = {100, 250, 500, 1000, 2500, 5000,
                           7500, 10000, 20000, 40000, 60000};

  void splitSound() {
    int volume = 0;
    int note = 0;
    if(!hasSplitSound) {
      hasSplitSound = true;
      float area = hei * wid ;
      float whRatio = hei / wid;
      if(whRatio > 1) whRatio = 1/whRatio;
      while(area > areaPartition[volume]) {
        volume++;
        if(volume == areaPartition.length)
          break;
      }
      while(whRatio < whRatioPartition[note]) {
        note++;
        if(note == whRatioPartition.length)
          break;
      }

      oscP5.send("/regular",new Object[] {note, volume, 0}, myRemoteLocation);

      //debug
      println("area: " + area);
      println("volume: " + volume);
      println("whRatio: " + whRatio);
      println("note: " + note);
    }
  }

  void noiseSound() {
    if(!hasNoise) {
      oscP5.send("/noise",new Object[] {-1, 0, 1}, myRemoteLocation);
    }
  }

  void rotateSound() {
    if(!hasRotate) {
      oscP5.send("/noise",new Object[] {-1, 0, 2}, myRemoteLocation);
    }
  }

  void breathSound() {
    if(!hasBreath) {
      oscP5.send("/noise",new Object[] {-1, 0, 3}, myRemoteLocation);
    }
  }

  void mergeSound() {

  }



}






/*********************************************/
/*******************DASH LINE*****************/
/*********************************************/
void patternLine(int xStart, int yStart, int xEnd, int yEnd, int linePattern, int lineScale) {
  int temp, yStep, x, y;
  int pattern = linePattern;
  int carry;
  int count = lineScale;

  boolean steep = (abs(yEnd - yStart) > abs(xEnd - xStart));
  if (steep == true) {
    temp = xStart;
    xStart = yStart;
    yStart = temp;
    temp = xEnd;
    xEnd = yEnd;
    yEnd = temp;
  }
  if (xStart > xEnd) {
    temp = xStart;
    xStart = xEnd;
    xEnd = temp;
    temp = yStart;
    yStart = yEnd;
    yEnd = temp;
  }
  int deltaX = xEnd - xStart;
  int deltaY = abs(yEnd - yStart);
  int error = - (deltaX + 1) / 2;

  y = yStart;
  if (yStart < yEnd) {
    yStep = 1;
  } else {
    yStep = -1;
  }
  for (x = xStart; x <= xEnd; x++) {
    if ((pattern & 1) == 1) {
  if (steep == true) {
    point(y, x);
  } else {
    point(x, y);
  }
  carry = 0x8000;
    } else {
  carry = 0;
    }
    count--;
    if (count <= 0) {
  pattern = (pattern >> 1) + carry;
  count = lineScale;
    }

    error += deltaY;
    if (error >= 0) {
  y += yStep;
  error -= deltaX;
    }
  }
}