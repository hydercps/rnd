ArrayList<Particle> allParticles = new ArrayList<Particle>();
float push = 0;
PVector explosionPos;


class Particle {
  PVector pos = new PVector(0, 0, 0);
  PVector vel = new PVector(0, 0, 0);
  color pixelColor;
  float fallRate = 0;
  boolean active = false;
  int zDepth = 0;
  
  Particle(float x, float y, float z) {
    this.pos.set(x, y, z);
    this.pixelColor = color(255, 0, 0);
    this.fallRate = random(0.5, 8.0);
  }
 
  void draw() {
    strokeWeight(3);
    stroke(this.pixelColor);
    
    pushMatrix();
    translate(this.pos.x, this.pos.y, this.pos.z);
    rotate(45);
    point(0, 0, 0);
    //ellipse(0, 0, 3, 3);
    popMatrix();
  }
}


void setup() {
  size(640, 640, P3D);
  noStroke();
  noFill();
  
  int heartSize = 6;
  int spacing = 8;
  
  // Code for getting heart shape by Ilyas Shafigin (www.openprocessing.org/sketch/377004)
  for (int z = 0; z < 20; z++) {
    for (float angle = -90; angle < 90; angle += 1.5) {
      float t = angle*2.0;
      float x = 16*pow(sin(radians(t)), 3);
      float y = -13*cos(radians(t)) + 5*cos(radians(2*t)) + 2*cos(radians(3*t)) + cos(radians(4*t));
      Particle p = new Particle(x*heartSize+width/2, y*heartSize+height/2, z*spacing);
      p.pixelColor = color(50+z*10, 0, z*5);
      p.zDepth = z+1;
      allParticles.add(p);
    }
  }
  
  explosionPos = new PVector(-width/2, -height/2, 0);
}
 
void draw() {
  background(#262526);
  
  PVector gravity = new PVector(0, 0.1);
  
  for (Particle p : allParticles) {
    if (p.active) {
      p.vel.add(gravity);
      if (p.pos.x == width/2) { 
        // This is just so there aren't any particles going straight down the middle
        p.vel.x += random(-0.15, 0.15);
      }
      p.pos.add(p.vel);
    } else {
      PVector dir = new PVector(-width/2, -height/2, 0);
      dir.add(p.pos);
      dir.normalize();
      dir.mult(push*(p.zDepth*0.05)+cos(frameCount*0.05)*1.5);
      p.pos.add(dir);
    }
    
    p.draw();
  }
  push = sin(frameCount*0.05)*1.5;
}


void mousePressed() {
  explosionPos.x = -mouseX;
  explosionPos.y = -mouseY;
  
  for (Particle p : allParticles) {
    /*float distance = dist(-explosionPos.x, -explosionPos.y, p.pos.x, p.pos.y);
    if (distance > 100) {
      continue;
    }*/
    PVector dir = new PVector(explosionPos.x, explosionPos.y, explosionPos.z);
    dir.add(p.pos);
    dir.normalize();
    dir.mult(p.fallRate);
    p.vel.add(dir);
    p.active = true;
  }
}
