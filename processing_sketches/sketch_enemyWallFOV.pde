/*
* Make a collision info class
 * Draw enemy vision with vertexes
 - Fix vision display on edges of walls
 * Generic function to shoot rays
 * Store angle way was shot at
 * Get point between both ray angles
 * Consider if lastIntInfo && intInfo don't match collision, it shoots a 3 rays directly to the segment's point
 - Test fails when wall is at the end of the vision's length
 - Test edges again with multiple walls being hit
 - Multiple walls
 - Get closest wall
 https://www.youtube.com/watch?v=73Dc5JTCmKI
 http://ncase.me/sight-and-light/
 */


PVector player;
Enemy enemy1;
Wall wall1;
boolean debug = true;


class IntInfo {
  boolean collision = false;
  PVector intersection;
  Segment seg1;
  Segment seg2;
  float s = 0;
  float t = 0;
  float angle = 0;

  IntInfo() {
    this.intersection = new PVector(0, 0);
  }
}


class Segment {
  PVector pos1;
  PVector pos2;

  Segment(float x1, float y1, float x2, float y2) {
    this.pos1 = new PVector(x1, y1);
    this.pos2 = new PVector(x2, y2);
  }
}


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
  float sightAngle = 25;
  int state = 0;

  IntInfo shootRay(float angle, float mag, boolean drawLines) {
    PVector dir1 = new PVector(sin(radians(angle)), cos(radians(angle)));
    dir1.normalize();

    PVector p2 = new PVector(this.pos.x, this.pos.y);
    dir1.mult(mag);
    p2.add(dir1);

    IntInfo intInfo = getSegmentIntersection(new Segment(this.pos.x, this.pos.y, p2.x, p2.y), 
    new Segment(wall1.pos1.x, wall1.pos1.y, wall1.pos2.x, wall1.pos2.y));
    intInfo.angle = angle;

    if (drawLines && debug) {
      strokeWeight(1);
      stroke(150, 150, 255);
      line(this.pos.x, this.pos.y, p2.x, p2.y);
    }

    return intInfo;
  }

  void drawFieldOfView() {
    int rayCount = 10;
    float angleStep = this.sightAngle/(rayCount-1)*2;
    //float currentAngle = degrees(acos(this.dir.x));
    float currentAngle = degrees(atan2(this.dir.x, this.dir.y));
    ArrayList<PVector> positions = new ArrayList<PVector>();
    IntInfo lastIntInfo = null;

    for (int i = 0; i < rayCount; i ++) {
      // Cast ray at supplied angle
      float angle = currentAngle+i*angleStep-this.sightAngle;
      IntInfo intInfo = this.shootRay(angle, this.sightDistance, true);

      if (intInfo.collision) {
        if (debug) {
          noFill();
          stroke(150, 150, 255);
          strokeWeight(10);
          point(intInfo.intersection.x, intInfo.intersection.y);
        }
        positions.add(new PVector(intInfo.intersection.x, intInfo.intersection.y));
      } else {
        positions.add(intInfo.seg1.pos2);
      }

      // Fix edges
      if (lastIntInfo != null) {
        if (intInfo.collision != lastIntInfo.collision) {
          float bias;
          Segment seg;

          // Get the closest edge point
          if (intInfo.collision) {
            bias = intInfo.s;
            seg = intInfo.seg2;
          } else {
            bias = lastIntInfo.s;
            seg = lastIntInfo.seg2;
          }

          // Get point from segment
          float minAngle = min(lastIntInfo.angle, intInfo.angle);
          float maxAngle = max(lastIntInfo.angle, intInfo.angle);

          PVector point1 = new PVector(seg.pos1.x, seg.pos1.y);
          point1.sub(this.pos);
          point1.normalize();
          float angle1 = degrees(atan2(point1.x, point1.y));

          PVector point2 = new PVector(seg.pos2.x, seg.pos2.y);
          point2.sub(this.pos);
          point2.normalize();
          float angle2 = degrees(atan2(point2.x, point2.y));

          PVector pos;
          if (angle1 > minAngle && angle1 < maxAngle) {
            pos = seg.pos1;
          } else {
            pos = seg.pos2;
          }

          if (debug) {
            noStroke();
            fill(255, 0, 255);
            //ellipse(pos.x, pos.y, 10, 10);
          }

          // Get angle to this point
          PVector dir = new PVector(pos.x, pos.y);
          dir.sub(this.pos);
          dir.normalize();

          float newAngle = degrees(atan2(dir.x, dir.y));

          if (lastIntInfo.collision) {
            // Collision then miss

            // This one shouldn't be triggered if it's just out of reach
            IntInfo intInfo1 = this.shootRay(newAngle-0.01, this.sightDistance, true);
            IntInfo intInfo2 = this.shootRay(newAngle+0.01, this.sightDistance, true);
            
            //IntInfo testIntInfo = this.shootRay(angle, this.sightDistance*2, false);
            //println(testIntInfo.seg2);
            //println(lastIntInfo.seg2);
            positions.add(positions.size()-1, intInfo1.intersection);
            positions.add(positions.size()-1, intInfo2.seg1.pos2);
          } else {
            // Miss then collision

            /*IntInfo intInfo1 = this.shootRay(newAngle-0.01, this.sightDistance, true);
             IntInfo intInfo2 = this.shootRay(newAngle+0.01, this.sightDistance, true);
             positions.add(positions.size()-1, intInfo1.seg1.pos2);
             positions.add(positions.size()-1, new PVector(intInfo2.intersection.x, intInfo2.intersection.y));*/
          }
        }
      }
      lastIntInfo = intInfo;
    }

    // Draw polygons
    beginShape();
    noStroke();
    fill(0, 0, 255, 50);
    for (int i = 0; i < positions.size ()-1; i++) {
      vertex(this.pos.x, this.pos.y);

      PVector p1 = positions.get(i);
      vertex(p1.x, p1.y);

      PVector p2 = positions.get(i+1);
      vertex(p2.x, p2.y);
    }
    endShape();
  }

  void viewCheck(PVector pos) {
    // Normal state
    this.state = 0;

    float distance = dist(pos.x, pos.y, this.pos.x, this.pos.y);

    if (distance < this.sightDistance) {
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
        if (debug) {
          strokeWeight(0);
          stroke(0);
          line(this.pos.x, this.pos.y, px2, py2);
        }

        IntInfo intInfo = getSegmentIntersection(new Segment(px1, py1, px2, py2), 
        new Segment(wall1.pos1.x, wall1.pos1.y, wall1.pos2.x, wall1.pos2.y));

        if (intInfo.collision) {
          if (debug) {
            noFill();
            ellipse(intInfo.intersection.x, intInfo.intersection.y, 15, 15);
          }

          float intDist = dist(intInfo.intersection.x, intInfo.intersection.y, this.pos.x, this.pos.y);
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
      fill(255, 0, 0, 20);
    } else {
      fill(0, 0, 255, 20);
    }
    noStroke();

    // Draw vision cones
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate((atan2(this.dir.x, this.dir.y)));
    translate(-this.pos.x, -this.pos.y);
    //arc(this.pos.x, this.pos.y, this.sightDistance*2, this.sightDistance*2, radians(-this.sightAngle), radians(this.sightAngle));
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

/*boolean getaabbIntersection(float ax, float ay, float AX, float AY,
 float bx, float by, float BX, float BY) {
 if (! ( (AX < bx) || (BX < ax) || (AY < by) || (BY < ay) )) {
 return true;
 }
 return false;  
 }*/


IntInfo getSegmentIntersection(Segment seg1, Segment seg2) {
  IntInfo intInfo = new IntInfo();
  intInfo.seg1 = seg1;
  intInfo.seg2 = seg2;

  float sx1 = seg1.pos2.x-seg1.pos1.x;
  float sy1 = seg1.pos2.y-seg1.pos1.y;
  float sx2 = seg2.pos2.x-seg2.pos1.x;
  float sy2 = seg2.pos2.y-seg2.pos1.y;

  // Check if they are parallel
  if (sx1 == sx2 || sy1 == sy2) {
    return intInfo;
  }

  // Gets value along each segment
  float s = (-sy1 * (seg1.pos1.x-seg2.pos1.x) + sx1 * (seg1.pos1.y-seg2.pos1.y)) / (-sx2*sy1+sx1*sy2);
  float t = (sx2 * (seg1.pos1.y-seg2.pos1.y) - sy2 * (seg1.pos1.x-seg2.pos1.x)) / (-sx2*sy1+sx1*sy2);

  // If both values are between 0.0-1.0 then it's a hit
  if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
    // Set intersect points
    intInfo.collision = true;
    intInfo.intersection.x = seg1.pos1.x + (t*sx1);
    intInfo.intersection.y = seg1.pos1.y + (t*sy1);
    intInfo.s = s;
    intInfo.t = t;
  }

  return intInfo;
}


void setup() {
  size(700, 700);
  noStroke();

  player = new PVector(0, 0);

  /*wall1 = new Wall(380, 300, 550, 250);
   
   enemy1 = new Enemy();
   enemy1.pos.x = 150;
   enemy1.pos.y = 100;
   float enemyAngle = 45;
   enemy1.dir.x = sin(radians(enemyAngle));
   enemy1.dir.y = cos(radians(enemyAngle));
   enemy1.sightDistance = 500;*/



  //wall1 = new Wall(260, 300, 269, 250);
  wall1 = new Wall(80, 186, 280, 86);

  enemy1 = new Enemy();
  enemy1.pos.x = 550;
  enemy1.pos.y = 500;
  float enemyAngle = -135;
  enemy1.dir.x = sin(radians(enemyAngle));
  enemy1.dir.y = cos(radians(enemyAngle));
  enemy1.sightDistance = 500;
}


void draw() {
  //wall1.pos1.x += 0.2;
  //wall1.pos2.x -= 0.2;

  //wall1.pos1.set(mouseX+100, mouseY-50);
  //wall1.pos2.set(mouseX-100, mouseY+50);

  //println(mouseX + ", " + mouseY);
  background(255);

  player.x = mouseX;
  player.y = mouseY;

  enemy1.viewCheck(player);
  enemy1.drawFieldOfView();
  enemy1.draw();

  noStroke();
  fill(0, 255, 0);
  ellipse(player.x, player.y, 20, 20);

  wall1.draw();
}
