class MagicBox {
  //const
  int maxNumber = 8;
  int holdTime = 200;
  int holdTime_merge = 200;
  int splitFinishHoldTime = 2000;

  //variable
  Vrec vrecOrigin;
  Vrec[][] vrecs;
  int number;
  boolean splitOrMerge, startMerge, finishMerge, end;

  //TimeLine
  TimeLine tl;
  int limitTime = 500;

  //color & display
  color[] colors = {color(58, 83, 155),    //blue
                    color(217, 30, 24),    //red
                    color(249, 191, 59)};  //yellow
  int colorIndex;
  float transparency = 220;

  //parameters of extended functions
  float vibrateRate = 0.2;
  float rotateRate = vibrateRate + 0.3;
  float breathRate = rotateRate + 0.2;




  //constructor
  MagicBox() {
    vrecs = new Vrec[maxNumber-1][2];
    number = -1;
    splitOrMerge = true;
    startMerge = false;
    finishMerge = false;
    end = false;
    tl = new TimeLine(limitTime);

    //random parameter
    colorIndex = int(random(0, colors.length));
    transparency = random(180,240);
  }

  //init
  void init(float x, float y, float w, float h) {
    vrecOrigin = new Vrec(x, y, w, h, x, y);
    vrecOrigin.appearance = false;
    tl.startTimer();
    number = 0;
  }

  //display
  void display() {
    //draw the vrecs
    if (number != -1) vrecOrigin.display(colors[colorIndex], transparency);
    for (int i=0; i<number; i++) {
      for (int j=0; j<2; j++) {
        vrecs[i][j].display(colors[colorIndex], transparency);
      }
    }
    if (number == 0 && !startMerge) {
      if(!vrecOrigin.appearance) {
        vrecOrigin.fade(true, tl.liner(), colors[colorIndex], transparency);
        //println(tl.liner());
      }
    }
    if(end) vrecOrigin.fade(false, tl.liner(), colors[colorIndex], transparency);
  }

  //update
  void update() {
    //update the locations of vrecs
    for (int i=0; i<number; i++) {
      for (int j=0; j<2; j++) {
        vrecs[i][j].updateLocation();
      }
    }
  }

  void reset() {
    number = -1;
    splitOrMerge = true;
    startMerge = false;
    finishMerge = false;
  }

  void move() {
    //println("number = " + number);
    if (number == 0 && splitOrMerge) {
      if (millis() > vrecOrigin.getBornTime() + holdTime + limitTime) {
        vrecOrigin.splitRec();
        vrecs[0][0] = vrecOrigin.childVrecs[0];
          vrecs[0][0].startTimer();
        vrecs[0][1] = vrecOrigin.childVrecs[1];
          vrecs[0][1].startTimer();
        number = 1;
      }
    } else if (number > 0 && number < maxNumber && splitOrMerge) {
      if (vrecs[number-1][0].reached() ) {

        /****SOUND*****************/
        vrecs[number-1][0].splitSound();
        /**************************/

        if (millis() > vrecs[number-1][0].getReachedTime() + holdTime) {
          if (number < maxNumber-1 ) {
            /**********set movement********/
            float randomIndex = random(0,1);
            if(randomIndex < vibrateRate) {
              vrecs[number-1][1].triggerVibrate();
              vrecs[number-1][1].noiseSound();
            }
            else if(randomIndex < rotateRate) {
              vrecs[number-1][1].triggerRotate();
              vrecs[number-1][1].rotateSound();
            }
            else if(randomIndex < breathRate) {
              vrecs[number-1][1].triggerBreath();
              vrecs[number-1][1].breathSound();
            }

            /**********set movement********/



            vrecs[number-1][0].splitRec();       //let the first on in each pair of Vrec to split
            vrecs[number][0] = vrecs[number-1][0].childVrecs[0];
            vrecs[number][1] = vrecs[number-1][0].childVrecs[1];
            number++;

          }
          if(number == maxNumber-1) {
              splitOrMerge = false;
          }
          //println("After number++ :" + number);
        }
      }
    } else if (number > 1 && !splitOrMerge) {
      //*********************//
      //first, deal with the first critical rec
      //whick is the first two to merge
      //*********************//


      if (vrecs[number-1][0].reached() && number == maxNumber-1 && !startMerge) {

        /****SOUND*****************/
        vrecs[number-1][0].splitSound();
        vrecs[number-1][0].mergeSound();
        /**************************/

        if (millis() > vrecs[number-1][0].getReachedTime() + splitFinishHoldTime) {
          vrecs[number-2][0].mergeRec();
          vrecs[number-1][0].resetReachedTime();
          startMerge = true;
        }
      } else if (vrecs[number-1][0].reached() && number > 0 && startMerge) {
        //update the appearance
        vrecs[number-1][0].appearance = false;
        vrecs[number-1][1].appearance = false;
        vrecs[number-2][0].lineAppearance = false;
        vrecs[number-2][0].appearance = true;

        /****SOUND*****************/
        vrecs[number-1][0].mergeSound();
        /**************************/

        if (millis() > vrecs[number-1][0].getReachedTime() + holdTime_merge) {
          number--;
          if (number>1) {
            vrecs[number-2][0].mergeRec();
            vrecs[number-1][0].resetReachedTime();
          } else if (number==1 && vrecs[number][0].reached()) {
            vrecOrigin.mergeRec();
            vrecs[0][0].resetReachedTime();
          }
        }
      }
    } else if (number==1 && !splitOrMerge) {
      if (vrecs[0][0].reached() && !finishMerge) {
        if (maxNumber == 2) {
            finishMerge = true;
            vrecOrigin.mergeRec();
        }
        else {
          finishMerge = true;
          number = 0;
        }
      }
    }

    //when the merge is finished reset the parameters
    if (finishMerge && vrecs[0][0].reached()) {

      /****SOUND*****************/
      vrecs[0][0].mergeSound();
      /**************************/

      vrecOrigin.lineAppearance = false;
      vrecOrigin.appearance = true;
      if (millis() > vrecs[0][0].getReachedTime() + holdTime_merge) {
        splitOrMerge = true;
        startMerge = false;
        finishMerge = false;
        number = -1;
        end = true;
        tl.startTimer();
      }
    }
  }

  boolean checkEnd() {
    return end;
  }
}