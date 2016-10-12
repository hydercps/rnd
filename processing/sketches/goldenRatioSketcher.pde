/* @pjs preload="jensen.jpg"; */

/*
To do:
  - Don't create a dot if it's out of bounds from the image
  - Store each dot as an object
  - Mouse click to make all dots dynamic and fall out of bounds
  - Show new image once dots are out of bounds
*/

float spacing = 3;
float goldenAngle = 137.5;
float minThickness = 1.0;
float maxThickness = 8.0;

color targetColor = color(0);
color backgroundColor = color(255);

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


void setup() {
  size(600, 600);
  
  imageMode(CENTER);
  img = loadImage("jensen.jpg");
  img.loadPixels();
  
  background(backgroundColor);
  
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
  
  float b = brightness(pixelColor);
  
  // Darker colors will produce a larger circle.
  // The further from origin, the larger max thickness can be to fill in the gaps.
  float thickness = map(b, 0, 255, maxThickness+r*0.015, minThickness);
  
  //strokeWeight(thickness);
  //point(x, y);
  
  noStroke();
  fill(pixelColor);
  triangle(x, y, x+thickness*0.5, y-thickness, x+thickness, y);
}


void mousePressed() {
  if (mouseButton == RIGHT) {
    saveFrame("goldenRatioSketcher-###.png");
  }
}
