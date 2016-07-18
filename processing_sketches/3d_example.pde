import peasy.*;

PeasyCam cam;

class Particle {
  PVector pos = new PVector(0, 0, 0);
  PVector vel = new PVector(0, 0, 0);
  color pixelColor;
  float fallRate = 0;
  
  Particle(int x, int y, int z) {
    this.pos.set(x, y, z);
    this.pixelColor = color(255, 0, 0);
    this.fallRate = random(0.8, 1.0);
  }
 
  void draw() {
    strokeWeight(5);
    stroke(this.pixelColor);
    
    pushMatrix();
    translate(this.pos.x, this.pos.y, this.pos.z);
    point(0, 0, 0);
    popMatrix();
  }
}


ArrayList<Particle> allParticles = new ArrayList<Particle>();


void setup() {
  size(500, 500, P3D);
  background(0);
  
  cam = new PeasyCam(this, 400);
  
  for (int x = 0; x < 20; x++) {
    for (int y = 0; y < 20; y++) {
      for (int z = 0; z < 20; z++) {
        Particle p = new Particle((x-10)*5, (y-10)*5, (z-10)*5);
        p.pixelColor = color(x*12, y*12, z*12);
        allParticles.add(p);
      }  
    }
  }
}


float push = 0;


void draw() {
  background(0);
  
  for (Particle p : allParticles) {
    PVector dir = new PVector(0, 0, 0);
    dir.add(p.pos);
    dir.normalize();
    dir.mult(push);
    p.pos.add(dir);
    if (keyPressed) {
      p.pos.y += p.fallRate;
    }
    p.draw();
  }
  push = sin(frameCount*0.05)*1.5;
}
