/*
To do:
  - condition to stop if length is too small
  - draw leaves
  - sway branches
  - apply dynamics
*/


ArrayList<Branch> branches = new ArrayList<Branch>();
ArrayList<Leaf> leaves = new ArrayList<Leaf>();

class Leaf {
  PVector pos;
  float diameter;
  float opacity;
  float hue;
  
  Leaf(float _x, float _y) {
    this.pos = new PVector(_x, _y);
    this.diameter = random(2.0, 8.0);
    this.opacity = random(5.0, 50.0);
    this.hue = random(75.0, 95.0);
    //this.hue = 85;
  }
  
  void display() {
    noStroke();
    fill(this.hue, 50, 100, this.opacity);
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
    strokeWeight(10-this.level);
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
  Branch branch1 = branch.newBranch(-random(0.0, 45.0), random(0.65, 0.85));
  Branch branch2 = branch.newBranch(random(0.0, 45.0), random(0.65, 0.85));
  branches.add(branch1);
  branches.add(branch2);

  int maxLevel = 9;

  if (branch1.level < maxLevel) {
    subDivide(branch1);
  }

  if (branch2.level < maxLevel) {
    subDivide(branch2);
  }
  
  if (branch1.level == maxLevel) {
    float offset = 5.0;
    for (int i = 0; i < 10; i++) {
      leaves.add(new Leaf(branch1.end.x+random(-offset, offset), branch1.end.y+random(-offset, offset)));
    }
  }
}


void setup() {
  size(700, 700);
  colorMode(HSB, 100);
  branches.add(new Branch(width/2, height, width/2, height-100, 0));
  subDivide(branches.get(0));
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
  println(mouseY);
}
