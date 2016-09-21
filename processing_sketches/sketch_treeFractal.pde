/*
To do:
  - Optimize code
*/


ArrayList<Branch> branches = new ArrayList<Branch>();
ArrayList<Leaf> leaves = new ArrayList<Leaf>();
int maxLevel = 9;


class Leaf {
  PVector pos;
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  float diameter;
  float opacity;
  float hue;
  float sat;
  Branch parent;
  PVector offset;
  boolean dynamic = false;
  
  Leaf(float _x, float _y, Branch _parent) {
    this.pos = new PVector(_x, _y);
    this.diameter = random(2.0, 8.0);
    this.opacity = random(5.0, 50.0);
    this.parent = _parent;
    this.offset = new PVector(_parent.restPos.x-this.pos.x, _parent.restPos.y-this.pos.y);
    
    if (leaves.size() % 5 == 0) {
      this.hue = 5;
      this.sat = 100;
    } else {
      this.hue = random(75.0, 95.0);
      this.sat = 50;
    }
  }
  
  void display() {
    noStroke();
    fill(this.hue, sat, 100, this.opacity);
    ellipse(this.pos.x, this.pos.y, this.diameter, this.diameter);
  }
  
  void applyForce(PVector force) {
    this.acc.add(force);
  }
  
  void move() {
    if (this.dynamic) {
      PVector gravity = new PVector(0, 0.02);
      this.applyForce(gravity);
      
      this.vel.add(this.acc);
      this.pos.add(this.vel);
      this.acc.mult(0);
      
      this.bounds();
    } else {
      this.pos.x = this.parent.end.x+this.offset.x;
      this.pos.y = this.parent.end.y+this.offset.y;
    }
  }
  
  void bounds() {
    if (! this.dynamic) {
      return;
    }
    
    if (this.pos.y > height-10) {
      this.vel.y = 0;
      this.vel.x *= 0.95;
    }
  }
}


class Branch {
  PVector start;
  PVector end;
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  int level;
  Branch parent = null;
  PVector restPos;
  float restLength;

  Branch(float _x1, float _y1, float _x2, float _y2, int _level) {
    this.start = new PVector(_x1, _y1);
    this.end = new PVector(_x2, _y2);
    this.level = _level;
    this.restLength = dist(_x1, _y1, _x2, _y2);
    this.restPos = new PVector(_x2, _y2);
  }

  void display() {
    stroke(10, 57, 20+this.level*4);
    strokeWeight(maxLevel-this.level+1);
    if (this.parent != null) {
      line(this.parent.end.x, this.parent.end.y, this.end.x, this.end.y);
    } else {
      line(this.start.x, this.start.y, this.end.x, this.end.y);
    }
  }

  Branch newBranch(float angle, float mult) {
    PVector direction = new PVector(this.end.x, this.end.y);
    direction.sub(this.start);
    direction.rotate(radians(angle));
    direction.mult(mult);

    PVector newEnd = new PVector(this.end.x, this.end.y);
    newEnd.add(direction);

    return new Branch(this.end.x, this.end.y, newEnd.x, newEnd.y, this.level+1);
  }
  
  void applyForce(PVector force) {
    PVector forceCopy = force.get();
    float divValue = map(this.level, 0, maxLevel, 5.0, 2.0);
    forceCopy.div(divValue);
    this.acc.add(forceCopy);
  }
  
  void sim() {
    PVector airDrag = new PVector(this.vel.x, this.vel.y);
    float dragMagnitude = airDrag.mag();
    airDrag.normalize();
    airDrag.mult(-1);
    airDrag.mult(0.025*dragMagnitude*dragMagnitude);
    this.applyForce(airDrag);
    
    PVector spring = new PVector(this.end.x, this.end.y);
    spring.sub(this.restPos);
    float stretchedLength = dist(this.restPos.x, this.restPos.y, this.end.x, this.end.y);
    spring.normalize();
    float mult = map(this.level, 0, maxLevel, 0.05, 0.1);
    spring.mult(-mult*stretchedLength);
    this.applyForce(spring);
  }
  
  void move() {
    this.sim();
   this.vel.mult(0.95); 
    if (this.vel.mag() < 0.05) {
      this.vel.mult(0);
    }
    this.vel.add(this.acc);
    this.end.add(this.vel);
    this.acc.mult(0);    
  }
}


void subDivide(Branch branch) {
  ArrayList<Branch> newBranches = new ArrayList<Branch>();
  
  int newBranchCount = (int)random(1, 4);
  
  if (newBranchCount == 1) {
    newBranches.add(branch.newBranch(random(-45.0, 45.0), random(0.65, 0.85)));
  } else if (newBranchCount == 2) {
    newBranches.add(branch.newBranch(-random(10.0, 45.0), random(0.65, 0.85)));
    newBranches.add(branch.newBranch(random(10.0, 45.0), random(0.65, 0.85)));
  } else {
    newBranches.add(branch.newBranch(-random(15.0, 45.0), random(0.65, 0.85)));
    newBranches.add(branch.newBranch(random(-10.0, 10.0), random(0.65, 0.85)));
    newBranches.add(branch.newBranch(random(15.0, 45.0), random(0.65, 0.85)));
  }
  
  for (Branch newBranch : newBranches) {
    newBranch.parent = branch;
    branches.add(newBranch);

    if (newBranch.level < maxLevel) {
      subDivide(newBranch);
    } else {
      float offset = 5.0;
      for (int i = 0; i < 5; i++) {
        leaves.add(new Leaf(newBranch.end.x+random(-offset, offset), newBranch.end.y+random(-offset, offset), newBranch));
      }
    }
  }
}


void generateNewTree() {
  branches.clear();
  leaves.clear();
  float rootLength = random(80.0, 150.0);
  branches.add(new Branch(width/2, height, width/2, height-rootLength, 0));
  subDivide(branches.get(0));
}


void setup() {
  size(800, 700);
  colorMode(HSB, 100);
  generateNewTree();
}


void draw() {
  background(100);
  
  for (int i = 0; i < branches.size(); i++) {
    Branch branch = branches.get(i);
    branch.move();
    branch.display();
  }
  
  for (int i = leaves.size()-1; i > -1; i--) {
    Leaf leaf = leaves.get(i);
    leaf.move();
    leaf.display();
    if (leaf.dynamic) {
      if (leaf.pos.x < 0 || leaf.pos.x > width) {
        leaves.remove(i);
      }
    }
  }
}


void mousePressed() {
  generateNewTree();
}


void keyPressed() {
  float distThreshold = 300;
  
  PVector source = new PVector(mouseX, mouseY);
  
  for (Branch branch : branches) {
    float distance = dist(mouseX, mouseY, branch.end.x, branch.end.y);
    if (distance > distThreshold) {
      continue;
    }
    
    PVector explosion = new PVector(branch.end.x, branch.end.y);
    explosion.sub(source);
    explosion.normalize();
    float mult = map(distance, 0, distThreshold, 10.0, 1.0);
    explosion.mult(mult);
    branch.applyForce(explosion);
  }
  
  for (Leaf leaf : leaves) {
    float distance = dist(mouseX, mouseY, leaf.pos.x, leaf.pos.y);
    if (distance > 50) {
      continue;
    }
    
    PVector explosion = new PVector(leaf.pos.x, leaf.pos.y);
    explosion.sub(source);
    explosion.normalize();
    float mult = map(distance, 0, 50, 10, 0);
    explosion.mult(mult);
    leaf.applyForce(explosion);
    
    leaf.dynamic = true;
  }
}
