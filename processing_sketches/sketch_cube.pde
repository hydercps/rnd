/*
- Rotate camera
- Explosion by distance
*/

//import peasy.*;
//PeasyCam cam;


class Particle {
  PVector pos = new PVector(0, 0, 0);
  PVector vel = new PVector(0, 0, 0);
  color pixelColor;
  float fallRate = 0;
  boolean active = false;
  
  Particle(int x, int y, int z) {
    this.pos.set(x, y, z);
    this.pixelColor = color(255, 0, 0);
    this.fallRate = random(0.5, 5.0);
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
  size(800, 800, P3D);
  background(0);
  
  //cam = new PeasyCam(this, 400);
  
  int meshWidth = 14;
  int meshHeight = 14;
  int meshDepth = 14;
  int spacing = 10;
  
  for (int x = 0; x < meshWidth; x++) {
    for (int y = 0; y < meshHeight; y++) {
      for (int z = 0; z < meshDepth; z++) {
        Particle p = new Particle((x-meshWidth/2)*spacing+width/2, (y-meshHeight/2)*spacing+height/2, (z-meshDepth/2)*spacing);
        p.pixelColor = color(x*12, y*12, z*12);
        allParticles.add(p);
      }  
    }
  }
  
  explosionPos = new PVector(-width/2, -height/2, 0);
}


float push = 0;
PVector explosionPos;

void draw() {
  background(0);
  
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
      dir.mult(push);
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
    float distance = dist(-explosionPos.x, -explosionPos.y, p.pos.x, p.pos.y);
    if (distance > 50) {
      continue;
    }
    PVector dir = new PVector(explosionPos.x, explosionPos.y, explosionPos.z);
    dir.add(p.pos);
    dir.normalize();
    dir.mult(p.fallRate);
    p.vel.add(dir);
    p.active = true;
  }
}
