import oscP5.*;
import netP5.*;


//constant
int maxNumber = 30;
PImage img;

//variables
MagicBox[] magicBoxes;
MagicBox theMagicBox;
float xmouse, ymouse;
int index = 0;

//color
color backGround = color(236, 240, 241);

//oscP5
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  frameRate(50);
  //size(1000, 600);
  size(1920, 1080);
  //size(1280, 720);
  //size(500,300);
  //fullScreen();


  magicBoxes = new MagicBox[maxNumber];
  theMagicBox = new MagicBox();

  //noise background
  background(backGround);
  img = loadImage("noise.jpg");
  tint(backGround, 5);
  image(img, 0, 0, width, height);
  tint(255, 255);

  //oscP5
  oscP5 = new OscP5(this,9020);
  myRemoteLocation = new NetAddress("127.0.0.1",9020);
}

void draw() {
  //clear the background
  background(backGround);



  //println("index : " + index);
  //println("millis(): " + millis());

  //draw the draft
  if(mouseButton == LEFT) {
    noFill();
    stroke(255);
    rect(xmouse, ymouse, mouseX-xmouse, mouseY-ymouse);
  }

  for(int i=0; i<index; i++) {

    if(magicBoxes[i].checkEnd() && !magicBoxes[i].tl.state) {
      for(int j=i; j<index-1; j++) {
        magicBoxes[j] = magicBoxes[j+1];
      }
      index--;
    }
    else {
      magicBoxes[i].move(); //<>//
      magicBoxes[i].update();
      magicBoxes[i].display();
    }
  }

  //noise background
  tint(241, 196, 15, 10);
  image(img, 0, 0, width, height);
  tint(255, 255);   //noise background

}

void mousePressed() {
  xmouse = mouseX;
  ymouse = mouseY;
}

void mouseReleased() {
  if(index < maxNumber) {
    for(int i=index; i>0; i--) {
      magicBoxes[i] = magicBoxes[i-1]; }
    index++;
  }
  else if(index == maxNumber) {
    for(int i=maxNumber-1; i>0; i--) {
      magicBoxes[i] = magicBoxes[i-1]; }
  }
  magicBoxes[0] = new MagicBox();
  float x_max = max(xmouse, mouseX);
  float x_min = min(xmouse, mouseX);
  float y_max = max(ymouse, mouseY);
  float y_min = min(ymouse, mouseY);
  magicBoxes[0].init(x_min, y_min ,
          x_max-x_min, y_max-y_min);
}


void keyPressed() {
  if (key == 's') {
    if (looping)  noLoop();
    else          loop();
  }

  if (key == 't') {
    print("check");
    oscP5.send("/regular",new Object[] {-1, 0, 0}, myRemoteLocation);
  }
}
