/* @pjs preload="jensen2.jpg"; */

/*
To do:
  - Show new image on mouse click
*/


float spacing = 3;
float goldenAngle = 137.5;
float minThickness = 1.0;
float maxThickness = 7.0;

int drawStyle = 0;
color targetColor = color(0);
color backgroundColor = color(255);

int num = 0;
PImage img;

String tooltip;



int worldPosToImageIndex(PVector worldPos) {
  int startX = width/2-img.width/2;
  int valX = (int)worldPos.x-startX;
  if (valX < 0 || valX > img.width-1) {
    return -1;
  }
  
  int startY = height/2-img.height/2;
  int valY = (int)worldPos.y-startY;
  if (valY < 0 || valY > img.height-1) {
    return -1;
  }
  
  return valX + (valY*img.width);
}


void reset() {
  num = 0;
  background(backgroundColor);
}


void setup() {
  size(600, 600);
  
  rectMode(CENTER);
  imageMode(CENTER);
  
  tooltip = "Left-click to change image.\n";
  tooltip += "Press any key to change the drawing style.\n";
  
  img = loadImage("jensen2.jpg");
  img.loadPixels();
  
  background(backgroundColor);
  
  frameRate(240);
}


void draw() {
  float angle = num * goldenAngle;
  float r = spacing * sqrt(num);
  float x = r * cos(radians(angle)) + width/2;
  float y = r * sin(radians(angle)) + height/2;
  
  num += 1;
  
  int imgIndex = worldPosToImageIndex(new PVector(x, y));
  
  if (imgIndex > -1) {
    color pixelColor = img.pixels[imgIndex];
    
    // Darker colors will produce a larger circle.
    // The further from origin, the larger max thickness can be to fill in the gaps.
    float b = brightness(pixelColor);
    float thickness = map(b, 0, 255, maxThickness+r*0.015, minThickness);
    
    switch(drawStyle) {
      case 0:
        stroke(pixelColor);
        strokeWeight(thickness);
        point(x, y);
        break;
      case 1:
        noStroke();
        fill(pixelColor);
        triangle(x, y, x+thickness*0.5, y-thickness, x+thickness, y);
        break;
      case 2:
        noStroke();
        fill(pixelColor);
        rect(x, y, thickness, thickness);
        break;
    }
  }
  
  noStroke();
  fill(backgroundColor);
  rect(0, height*2-50, width*2, height*2);
  
  fill(0);
  textAlign(CENTER);
  textSize(10);
  text(tooltip, width/2, height-30);
}


void mousePressed() {
  if (mouseButton == LEFT) {
    reset();
  } else if (mouseButton == RIGHT) {
    saveFrame("goldenRatioSketcher-###.png");
  }
}


void keyPressed() {
  reset();
  
  drawStyle += 1;
  if (drawStyle > 2) {
    drawStyle = 0;
  }
}
