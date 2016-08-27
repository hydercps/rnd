/*
- Edge handling should sample more evenly instead of bias
- Work in javascript mode

https://www.youtube.com/watch?v=73Dc5JTCmKI
http://ncase.me/sight-and-light/
*/
import java.util.Comparator;
import java.util.Collections;


PVector player;
Enemy enemy1;
ArrayList<Wall> walls = new ArrayList<Wall>();
boolean debug = true;


class IntInfo {
  boolean collision = false;
  PVector endPos;
  Segment seg1;
  Wall wall;
  float s = 0;
  float t = 0;
  float angle = 0;

  IntInfo() {
    this.endPos = new PVector(0, 0);
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


class Wall extends Segment {
  Wall(float x1, float y1, float x2, float y2) {
    super(x1, y1, x2, y2);
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

  IntInfo shootRay(float angle, float mag, boolean display) {
    // Create a ray with supplied magnitude
    PVector dir1 = new PVector(sin(radians(angle)), cos(radians(angle)));
    dir1.normalize();
    PVector p2 = new PVector(this.pos.x, this.pos.y);
    dir1.mult(mag);
    p2.add(dir1);
    
    // Check if ray collides any walls and get the closest one
    IntInfo intInfo = new IntInfo();
    float closestDist = 0;
    for (int i = 0; i < walls.size(); i++) {
      IntInfo wallIntInfo = getSegmentIntersection(new Segment(this.pos.x, this.pos.y, p2.x, p2.y), walls.get(i));
      float currentDist = dist(this.pos.x, this.pos.y, wallIntInfo.endPos.x, wallIntInfo.endPos.y);
      
      if (i == 0 || currentDist < closestDist) {
        intInfo = wallIntInfo;
        closestDist = currentDist;
      }
    }
    intInfo.angle = angle;

    if (display && debug) {
      strokeWeight(1);
      stroke(0, 100);
      line(this.pos.x, this.pos.y, p2.x, p2.y);
      
      if (intInfo.collision) {
        noFill();
        stroke(150, 150, 255);
        strokeWeight(10);
        point(intInfo.endPos.x, intInfo.endPos.y);
      }
    }

    return intInfo;
  }
  
  // Keeps firing rays between min and max angles to get better drawing around edges
  void edgeHandling(IntInfo intInfo, IntInfo lastIntInfo, ArrayList<PVector> positions) {
    if (intInfo.collision != lastIntInfo.collision || (intInfo.collision && lastIntInfo.collision && intInfo.wall != lastIntInfo.wall)) {
      float maxAngle = max(intInfo.angle, lastIntInfo.angle);
      float minAngle = min(intInfo.angle, lastIntInfo.angle);
      ArrayList<IntInfo> betweenIntInfo = new ArrayList<IntInfo>();
      int edgeResolveCount = 3;
      
      for (int i = 0; i < edgeResolveCount; i++) {
        float newAngle = (minAngle + maxAngle)/2.0;
        if ((int)minAngle >= (int)maxAngle || (int)maxAngle <= (int)minAngle) {
          break;
        }
        
        IntInfo newIntInfo = this.shootRay(newAngle, this.sightDistance, true);
        betweenIntInfo.add(newIntInfo);
        
        if (intInfo.collision) {
          // Miss then hit
          if (newIntInfo.collision && newIntInfo.wall == intInfo.wall) {
            maxAngle = newAngle;
          } else {
            minAngle = newAngle;
          }
        } else {
          // Hit then miss
          if (newIntInfo.collision && newIntInfo.wall == lastIntInfo.wall) {
            minAngle = newAngle;
          } else {
            maxAngle = newAngle;
          }
        }
      }
      
      // Sort by angle so vertex indexes will be correct
      Collections.sort(betweenIntInfo, new Comparator<IntInfo>() {
        public int compare(IntInfo a1, IntInfo a2) {
          if (a1.angle > a2.angle) {
            return 0;
          }
          return -1;
        }
      });
      
      ArrayList<PVector> newPositions = new ArrayList<PVector>();
      for (IntInfo o : betweenIntInfo) {
        newPositions.add(o.endPos);
      }
      positions.addAll(positions.size()-1, newPositions);
    }
  }

  void drawFieldOfView() {
    int rayCount = 10;
    float angleStep = this.sightAngle/(rayCount-1)*2;
    float currentAngle = degrees(atan2(this.dir.x, this.dir.y));
    ArrayList<PVector> positions = new ArrayList<PVector>();
    IntInfo lastIntInfo = null;
    
    for (int i = 0; i < rayCount; i ++) {
      // Cast ray at supplied angle
      float angle = currentAngle+i*angleStep-this.sightAngle;
      IntInfo intInfo = this.shootRay(angle, this.sightDistance, true);
      positions.add(intInfo.endPos);
      
      if (lastIntInfo != null) {
        this.edgeHandling(intInfo, lastIntInfo, positions);
      }
      
      lastIntInfo = intInfo;
    }

    // Draw polygons
    if (this.state == 1) {
      fill(255, 0, 0, 50);
    } else {
      fill(0, 0, 255, 50);
    }
    noStroke();
    
    beginShape();
    for (int i = 0; i < positions.size ()-1; i++) {
      vertex(this.pos.x, this.pos.y);

      PVector p1 = positions.get(i);
      vertex(p1.x, p1.y);

      PVector p2 = positions.get(i+1);
      vertex(p2.x, p2.y);
    }
    endShape();
  }
  
  // Checks if a position is within this enemy's vision
  void viewCheck(PVector pos) {
    // Normal state
    this.state = 0;

    float distance = dist(pos.x, pos.y, this.pos.x, this.pos.y);

    if (distance < this.sightDistance) {
      // Point direction to pos
      PVector dir = new PVector(pos.x, pos.y);
      dir.sub(this.pos);
      dir.normalize();

      // Check if it's within angle cone
      PVector ray1 = new PVector(dir.x, dir.y);
      ray1.normalize();
      PVector ray2 = new PVector(this.dir.x, this.dir.y);
      ray2.normalize();
      float relativeAngle = degrees(acos(ray1.dot(ray2)));

      if (relativeAngle < this.sightAngle) {
        // Shoot a ray to see if it hits any obstacles
        float angle = degrees(atan2(dir.x, dir.y));
        IntInfo intInfo = this.shootRay(angle, this.sightDistance, false);
        float rayDistance = dist(intInfo.endPos.x, intInfo.endPos.y, this.pos.x, this.pos.y);
        
        if (debug) {
          strokeWeight(1);
          stroke(0);
          line(this.pos.x, this.pos.y, intInfo.endPos.x, intInfo.endPos.y);
          
          if (intInfo.collision) {
            noFill();
            ellipse(intInfo.endPos.x, intInfo.endPos.y, 15, 15);
          }
        }
        
        if (distance < rayDistance) {
          // Alert state
          this.state = 1;
        }
      }
    }
  }

  void draw() {
    // Draw fov
    this.drawFieldOfView();
    
    // Draw enemy
    noStroke();
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


IntInfo getSegmentIntersection(Segment seg1, Wall wall) {
  IntInfo intInfo = new IntInfo();
  intInfo.seg1 = seg1;
  intInfo.wall = wall;

  float sx1 = seg1.pos2.x-seg1.pos1.x;
  float sy1 = seg1.pos2.y-seg1.pos1.y;
  float sx2 = wall.pos2.x-wall.pos1.x;
  float sy2 = wall.pos2.y-wall.pos1.y;

  // Check if they are parallel
  if (sx1 == sx2 || sy1 == sy2) {
    return intInfo;
  }

  // Gets value along each segment
  float s = (-sy1 * (seg1.pos1.x-wall.pos1.x) + sx1 * (seg1.pos1.y-wall.pos1.y)) / (-sx2*sy1+sx1*sy2);
  float t = (sx2 * (seg1.pos1.y-wall.pos1.y) - sy2 * (seg1.pos1.x-wall.pos1.x)) / (-sx2*sy1+sx1*sy2);

  // If both values are between 0.0-1.0 then it's a hit
  if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
    // Set intersect points
    intInfo.collision = true;
    intInfo.s = s;
    intInfo.t = t;
    intInfo.endPos.x = seg1.pos1.x + (t*sx1);
    intInfo.endPos.y = seg1.pos1.y + (t*sy1);
  } else {
    intInfo.endPos.x = seg1.pos2.x;
    intInfo.endPos.y = seg1.pos2.y;
  }

  return intInfo;
}


void setup() {
  size(700, 700);
  noStroke();

  player = new PVector(0, 0);
  
  walls.add(new Wall(380, 300, 550, 250));
  walls.add(new Wall(350, 430, 500, 380));
  
  enemy1 = new Enemy();
  enemy1.pos.x = 150;
  enemy1.pos.y = 100;
  float enemyAngle = 45;
  enemy1.dir.x = sin(radians(enemyAngle));
  enemy1.dir.y = cos(radians(enemyAngle));
  enemy1.sightDistance = 500;
}


void draw() {
  background(255);

  player.x = mouseX;
  player.y = mouseY;
  
  enemy1.viewCheck(player);
  enemy1.draw();

  noStroke();
  fill(0, 255, 0);
  //ellipse(player.x, player.y, 20, 20);
  
  for (Wall wall : walls) {
    wall.draw();
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    walls.get(0).pos1.x = mouseX;
    walls.get(0).pos1.y = mouseY;
  } else if (mouseButton == RIGHT) {
    walls.get(0).pos2.x = mouseX;
    walls.get(0).pos2.y = mouseY;
  }
  //println(walls.get(0).pos1 + ", " + walls.get(0).pos2);
}


void keyPressed() {
  if (keyCode == 32) {
    debug = ! debug;
  }
}
