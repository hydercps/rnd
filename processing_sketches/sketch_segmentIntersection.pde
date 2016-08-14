Segment seg1;
Segment seg2;
Segment seg3;
Segment seg4;
Segment seg5;


class Segment {
  PVector pos1;
  PVector pos2;
  boolean isColliding = false;
  
  Segment(float x1, float y1, float x2, float y2) {
    this.pos1 = new PVector(x1, y1);
    this.pos2 = new PVector(x2, y2);
  }
  
  void draw() {
    if (this.isColliding) {
      stroke(255, 0, 0);
    } else {
      stroke(0);
    }
    
    strokeWeight(7);
    point(this.pos1.x, this.pos1.y);
    point(this.pos2.x, this.pos2.y);
    
    strokeWeight(1);
    line(this.pos1.x, this.pos1.y, this.pos2.x, this.pos2.y); 
  }
}


void setup() {
  size(500, 300);
  background(255);
  seg1 = new Segment(200, 200, 380, 230);
  seg2 = new Segment(50, 50, 200, 100);
  seg3 = new Segment(200, 100, 300, 250);
  seg4 = new Segment(300, 250, 350, 150);
  seg5 = new Segment(350, 150, 450, 130);
  drawLines();
}


void draw() {
}


void mouseDragged() {
  if (mouseButton == LEFT) {
    seg1.pos1.x = mouseX;
    seg1.pos1.y = mouseY;
  } else if (mouseButton == RIGHT) {
    seg1.pos2.x = mouseX;
    seg1.pos2.y = mouseY;
  }
  
  background(255);
  drawLines();
}


void drawLines() {
  seg2.isColliding = getSegmentIntersection(seg1, seg2);
  seg3.isColliding = getSegmentIntersection(seg1, seg3);
  seg4.isColliding = getSegmentIntersection(seg1, seg4);
  seg5.isColliding = getSegmentIntersection(seg1, seg5);
  seg1.draw();
  seg2.draw();
  seg3.draw();
  seg4.draw();
  seg5.draw();
}


// Converted from Gavin's solution
// http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
boolean getSegmentIntersection(Segment seg1, Segment seg2) {
  // They aren't colliding if their bounding boxes aren't overlapping
  boolean inBounds = getBoundsIntersection(seg1, seg2);
  if (! inBounds) {
    return false;
  }
  
  float sx1 = seg1.pos2.x-seg1.pos1.x;
  float sy1 = seg1.pos2.y-seg1.pos1.y;
  float sx2 = seg2.pos2.x-seg2.pos1.x;
  float sy2 = seg2.pos2.y-seg2.pos1.y;
  
  // Check if they are parallel
  if (sx1 == sx2 || sy1 == sy2) {
    return false;
  }
  
  // Gets value along each segment
  float s = (-sy1 * (seg1.pos1.x-seg2.pos1.x) + sx1 * (seg1.pos1.y-seg2.pos1.y)) / (-sx2*sy1+sx1*sy2);
  float t = (sx2 * (seg1.pos1.y-seg2.pos1.y) - sy2 * (seg1.pos1.x-seg2.pos1.x)) / (-sx2*sy1+sx1*sy2);
  //println("s:" + s + ", t:" + t);
  
  // If both values are between 0.0-1.0 then it's a hit
  if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
    return true;
  }
  
  return false;
}


// Calculates aabb collision check against both bounding boxes
boolean getBoundsIntersection(Segment seg1, Segment seg2) {
  float ax = min(seg1.pos1.x, seg1.pos2.x);
  float ay = min(seg1.pos1.y, seg1.pos2.y);
  float AX = max(seg1.pos1.x, seg1.pos2.x);
  float AY = max(seg1.pos1.y, seg1.pos2.y);
  
  float bx = min(seg2.pos1.x, seg2.pos2.x);
  float by = min(seg2.pos1.y, seg2.pos2.y);
  float BX = max(seg2.pos1.x, seg2.pos2.x);
  float BY = max(seg2.pos1.y, seg2.pos2.y);
  
  if(! ( (AX < bx) || (BX < ax) || (AY < by) || (BY < ay) )) {
    return true;
  }
  
  return false;
}
