// Global variables
ArrayList<Bob> bobs = new ArrayList<Bob>();
int bobCount = 60;
float distThreshold = 100;


class Bob {
  
  PVector pos;
  PVector dir;
  float speed;
  
  Bob(float _x, float _y, float _angle, float _speed) {
    this.pos = new PVector(_x, _y);
    
    this.dir = new PVector(sin(radians(_angle)), cos(radians(_angle)));
    this.dir.normalize();
    
    this.speed = _speed;
  }
  
  void move() {
    this.pos.x += this.dir.x*this.speed;
    this.pos.y += this.dir.y*this.speed;
  }
  
  void keepInBounds() {
    if (this.pos.x < 0) {
      this.pos.x = 0;
      this.dir.x *= -1;
    } else if (this.pos.x > width) {
      this.pos.x = width;
      this.dir.x *= -1;
    }
    
    if (this.pos.y < 0) {
      this.pos.y = 0;
      this.dir.y *= -1;
    } else if (this.pos.y > height) {
      this.pos.y = height;
      this.dir.y *= -1;
    }
  }
  
  void drawFill() {
    ArrayList<Bob> proximityBobs = new ArrayList<Bob>();
    
    for (Bob otherBob : bobs) {
      if (this == otherBob) {
        continue;
      }
      
      float distance = dist(this.pos.x, this.pos.y, otherBob.pos.x, otherBob.pos.y);
      if (distance < distThreshold) {
        proximityBobs.add(otherBob);
      }
    }
    
    stroke(150, 255, 200, 20);
    strokeWeight(100);
    point(this.pos.x, this.pos.y);
    
    stroke(255);
    
    if (proximityBobs.size() > 0) {
      float sat = map(proximityBobs.size(), 0, 10, 0, 255);
      stroke(0, sat, 255, 50);
      strokeWeight(proximityBobs.size()*0.5);
      
      for (Bob otherBob : proximityBobs) {
        line(this.pos.x, this.pos.y, otherBob.pos.x, otherBob.pos.y);
      }
    }
        
    if (proximityBobs.size() > 3) {
      this.speed *= 0.99;
    } else {
      this.speed *= 1.01;
    }
    
    this.speed = max(0.25, min(this.speed, 6));
    
    float alpha = map(proximityBobs.size(), 0, 10, 0, 255);
    //stroke(255, alpha);
    
    strokeWeight(proximityBobs.size()*5);
    
    point(this.pos.x, this.pos.y);
    
    stroke(255);
    strokeWeight(proximityBobs.size());
    point(this.pos.x, this.pos.y);
  }
}


void setup() {
  size(800, 800);
  background(0);
  colorMode(HSB, 255);
  
  for (int i = 0; i < bobCount; i++) {
    bobs.add(new Bob(random(0.0, width), 
                     random(0.0, height), 
                     random(0.0, 360.0), 
                     random(0.5, 2.0)));
  }
}


void draw() {
  background(0);
  
  for (Bob bob : bobs) {
    bob.move();
    bob.keepInBounds();
    bob.drawFill();
  }
}
