/*
To do:
  - condition to stop if length is too small
  - sway branches
  - apply dynamics
*/


ArrayList<Branch> branches = new ArrayList<Branch>();
ArrayList<Leaf> leaves = new ArrayList<Leaf>();
int maxLevel = 9;


class Leaf {
  PVector pos;
  float diameter;
  float opacity;
  float hue;
  float sat;
  
  Leaf(float _x, float _y) {
    this.pos = new PVector(_x, _y);
    this.diameter = random(2.0, 8.0);
    this.opacity = random(5.0, 50.0);
    
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
}


class Branch {
  PVector start;
  PVector end;
  int level;

  Branch(float _x1, float _y1, float _x2, float _y2, int _level) {
    this.start = new PVector(_x1, _y1);
    this.end = new PVector(_x2, _y2);
    this.level = _level;
  }
  
  float getLength() {
    return 0;
  }

  void display() {
    stroke(10, 57, 20+this.level*4);
    strokeWeight(maxLevel-this.level);
    line(this.start.x, this.start.y, this.end.x, this.end.y);
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
    branches.add(newBranch);

    if (newBranch.level < maxLevel) {
      subDivide(newBranch);
    } else {
      float offset = 5.0;
      for (int i = 0; i < 5; i++) {
        leaves.add(new Leaf(newBranch.end.x+random(-offset, offset), newBranch.end.y+random(-offset, offset)));
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
  
  for (Branch branch : branches) {
    branch.display();
  }
  
  for (Leaf leaf : leaves) {
    leaf.display();
  }
}


void mousePressed() {
  generateNewTree();
}
