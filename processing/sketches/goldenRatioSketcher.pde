/* @pjs preload="profile.jpg"; */

float spacing = 3;
float goldenAngle = 137.5;
float minThickness = 0.1;
float maxThickness = 8.0;
color targetColor = color(0);

int num = 0;
PImage img;


color getPixelColor(PVector worldPos) {
  
  color nullColor = color(255);
  
  int startX = width/2-img.width/2;
  int valX = (int)worldPos.x-startX;
  if (valX < 0 || valX > img.width-1) {
    return nullColor;
  }
  
  int startY = height/2-img.height/2;
  int valY = (int)worldPos.y-startY;
  if (valY < 0 || valY > img.height-1) {
    return nullColor;
  }
  
  int index = valX + (valY*img.width);
  
  return img.pixels[index];
}


float getColorDistance(color pixelColor) {
  return dist(red(pixelColor), green(pixelColor), blue(pixelColor), red(targetColor), green(targetColor), blue(targetColor));
}


void setup() {
  size(600, 600);
  
  imageMode(CENTER);
  img = loadImage("profile.jpg");
  img.loadPixels();
  
  background(255);
  
  frameRate(240);
}


void draw() {
  //image(img, width/2, height/2);
  
  float angle = num * goldenAngle;
  float r = spacing * sqrt(num);
  float x = r * cos(radians(angle)) + width/2;
  float y = r * sin(radians(angle)) + height/2;
  
  num += 1;
  
  color pixelColor = getPixelColor(new PVector(x, y));
  stroke(pixelColor);
  
  float distance = getColorDistance(pixelColor);
  
  float thickness = constrain(map(distance, 0, 300, maxThickness, minThickness), minThickness, maxThickness);
  strokeWeight(thickness);
  
  //stroke(0);
  //strokeWeight(3);
  
  point(x, y);
}


void mousePressed() {
  if (mouseButton == RIGHT) {
    saveFrame("goldenRatioSketcher-###.png");
  }
}
