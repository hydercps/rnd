Sprite hero;

class Sprite {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);
  float closeEnoughTarget = 100;
  float maxSpeed = 5.0;
  float maxForce = 0.25;
  
  void move() {
    // Check if sprite should be slowing down
    float proximityMult = 1.0;
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < this.closeEnoughTarget) {
      proximityMult = distance/this.closeEnoughTarget;
    }
    
    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);
    
    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    steer.normalize();
    steer.mult(this.maxForce);
    this.acc.add(steer);
    
    // Move sprite
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
}


void setup() {
  size(500, 500);
  noStroke();
  
  hero = new Sprite();
  hero.pos.set(100, 400);
  hero.vel.set(-5, -10);
}


void draw() {
  hero.move();
  
  background(255);
  
  fill(255, 0, 0);
  ellipse(hero.pos.x, hero.pos.y, 20, 20);
  
  fill(0, 0, 255, 20);
  ellipse(hero.target.x, hero.target.y, hero.closeEnoughTarget*2, hero.closeEnoughTarget*2);
  
  fill(0, 255, 0);
  ellipse(hero.target.x, hero.target.y, 5, 5);
}


void mouseMoved() {
  hero.target.x = mouseX;
  hero.target.y = mouseY;
}
