/*
- Draw enemy vision

https://www.youtube.com/watch?v=73Dc5JTCmKI
*/
 
 
PVector player;
Enemy enemy1;
Wall wall1;
float intx = 0;
float inty = 0;


class Wall {
  PVector pos1;
  PVector pos2;
  boolean isColliding = false;
   
  Wall(float x1, float y1, float x2, float y2) {
    this.pos1 = new PVector(x1, y1);
    this.pos2 = new PVector(x2, y2);
  }
   
  void draw() {
    stroke(100);
    strokeWeight(4);
    line(this.pos1.x, this.pos1.y, this.pos2.x, this.pos2.y);
  }
}


class Enemy {
  PVector pos = new PVector(0, 0);
  PVector dir = new PVector(0, 0);
  float sightDistance = 100;
  float sightAngle = 45;
  float periphiralDistance = 150;
  float periphiralAngle = 50;
  int state = 0;
   
  void viewCheck(PVector pos) {
    // Normal state
    this.state = 0;
     
    float distance = dist(pos.x, pos.y, this.pos.x, this.pos.y);
     
    if (distance < this.periphiralDistance) {
      // Point direction to pos
      PVector dir = new PVector(pos.x, pos.y);
      dir.sub(this.pos);
      dir.normalize();
       
      // Check angle
      PVector ray1 = new PVector(dir.x, dir.y);
      ray1.normalize();
      PVector ray2 = new PVector(this.dir.x, this.dir.y);
      ray2.normalize();
      float angle = degrees(acos(ray1.dot(ray2)));
       
      if (distance < this.sightDistance && angle < this.sightAngle) {
        // Create segment from vision
        float px1 = this.pos.x;
        float py1 = this.pos.y;
        dir.mult(this.sightDistance);
        dir.add(this.pos);
        float px2 = dir.x;
        float py2 = dir.y;
        
        // Draw end point
        strokeWeight(0);
        stroke(0);
        line(this.pos.x, this.pos.y, px2, py2);
        
        boolean hitWall = getSegmentIntersection(px1, py1, px2, py2, 
                                                 wall1.pos1.x, wall1.pos1.y, wall1.pos2.x, wall1.pos2.y);
        
        if (hitWall) {
          noFill();
          ellipse(intx, inty, 15, 15);
          
          float intDist = dist(intx, inty, this.pos.x, this.pos.y);
          if (intDist < distance) {
             return;
          }
        }
        
        // Alert state
        this.state = 1;
      }
    }
  }
  
  void draw() {
    if (this.state == 1) {
      fill(255, 0, 0, 50);
    } else if (this.state == 2) {
      fill(255, 255, 0, 50);
    } else {
      fill(0, 0, 255, 50);
    }
    noStroke();
     
    // Draw vision cones
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate((atan2(this.dir.y, this.dir.x)));
    translate(-this.pos.x, -this.pos.y);
    arc(this.pos.x, this.pos.y, this.sightDistance*2, this.sightDistance*2, radians(-this.sightAngle), radians(this.sightAngle));
    //arc(this.pos.x, this.pos.y, this.periphiralDistance*2, this.periphiralDistance*2, radians(-this.periphiralAngle), radians(this.periphiralAngle));
    popMatrix();
     
    // Draw enemy
    fill(255, 0, 0);
    ellipse(this.pos.x, this.pos.y, 20, 20);
     
    // Draw text
    fill(0);
    textAlign(CENTER);
    textSize(30);
    if (this.state == 1) {
      text("!", this.pos.x, this.pos.y-15);
    } else if (this.state == 2) {
      text("?", this.pos.x, this.pos.y-15);
    }
  }
}


boolean getSegmentIntersection(float px1, float py1, 
                               float px2, float py2, 
                               float px3, float py3, 
                               float px4, float py4) {
  float sx1 = px2-px1;
  float sy1 = py2-py1;
  float sx2 = px4-px3;
  float sy2 = py4-py3;
   
  // Check if they are parallel
  if (sx1 == sx2 || sy1 == sy2) {
    return false;
  }
   
  // Gets value along each segment
  float s = (-sy1 * (px1-px3) + sx1 * (py1-py3)) / (-sx2*sy1+sx1*sy2);
  float t = (sx2 * (py1-py3) - sy2 * (px1-px3)) / (-sx2*sy1+sx1*sy2);
   
  // If both values are between 0.0-1.0 then it's a hit
  if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
    // Set intersect points
    intx = px1 + (t*sx1);
    inty = py1 + (t*sy1);
    return true;
  }
   
  return false;
}

 
void setup() {
 size(700, 700);
 noStroke();
  
 player = new PVector(0, 0);
 
 wall1 = new Wall(300, 450, 550, 400);
  
 enemy1 = new Enemy();
 enemy1.pos.x = width/2;
 enemy1.pos.y = 100;
 enemy1.dir.x = sin(radians(0));
 enemy1.dir.y = cos(radians(0));
 enemy1.sightDistance = 500;
 enemy1.periphiralDistance = 500;
}
 
 
void draw() {
 //println(mouseX + ", " + mouseY);
 background(255);
  
 player.x = mouseX;
 player.y = mouseY;
  
 enemy1.viewCheck(player);
 enemy1.draw();
 
 fill(0, 255, 0);
 ellipse(player.x, player.y, 20, 20);
 
 wall1.draw();
}
