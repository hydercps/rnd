/*
* Get more white color in the middle
* Get better noise motion
- Replace PeasyCam
*/

import peasy.*;
PeasyCam cam;

ArrayList<Particle> allParticles = new ArrayList<Particle>();

class Particle { 
  PVector pos = new PVector(0, 0, 0);
  PVector vel = new PVector(0, 0, 0);
  int startTime = 0;
  float particleSize = 1;
  float offsetY = 0;
  float offsetZ = 0;
  float variance = 0;
  int timeOffset = 0;
  float killOffset = 0;
  float speed = 0;
  float hitSpeed = 0;
  boolean dynamic = false;
  color particleColor;
  int source;
  int dir = 1;
}

void setup() {
  size(800, 500, P3D);
  ellipseMode(CENTER);
  noiseSeed(0);
  cam = new PeasyCam(this, 500);
}


float sourceX = 0;
float push = 0;


void draw() {
  background(0);
  
  if(keyPressed) {
    push += 0.5;
  } else {
    push = max(0, push-0.5);
  }
  
  sourceX = width/2+push;
  
  for (int x = 0; x < 10; x++) {
    Particle newParticle = new Particle();
    newParticle.particleSize = random(1, 5);
    newParticle.startTime = frameCount;
    newParticle.offsetY = random(-10.0, 10.0);
    newParticle.offsetZ = random(-25.0, 25.0);
    newParticle.variance = random(-50.0, 50.0);
    newParticle.timeOffset = (int)random(-25, 25);
    newParticle.speed = random(1.0, 5.0);
    newParticle.hitSpeed = random(0.2, 0.4);
    newParticle.killOffset = random(-50.0, 50.0);
    //newParticle.pos.y = height/2+newParticle.offsetY+noise(newParticle.timeOffset)*newParticle.variance;
    newParticle.pos.y = (height/2)+newParticle.offsetY+noise(newParticle.timeOffset*0.03)*newParticle.variance;
    newParticle.pos.z = newParticle.offsetZ;
    
    if (x % 2 == 0) {
      newParticle.dir = -1;
      newParticle.source = 1;
      newParticle.pos.x = width;
      newParticle.speed *= -1;
      float centerDist = dist(newParticle.pos.x, newParticle.pos.y, newParticle.pos.z, width, height/2, 0);
      newParticle.particleColor = color(255, 255-centerDist*10, 255); // 255, 0, 255
    } else {
      newParticle.dir = 1;
      newParticle.source = 0;
      newParticle.pos.x = 0;
      float centerDist = dist(newParticle.pos.x, newParticle.pos.y, newParticle.pos.z, 0, height/2, 0);
      newParticle.particleColor = color(255-centerDist*10, 255-centerDist*5, 255); // 50, 100, 255
    }
    
    allParticles.add(newParticle);
  }
  
  for (int x = allParticles.size()-1; x > -1; x--) {
    Particle p = allParticles.get(x);
    
    strokeWeight(p.particleSize);
    stroke(p.particleColor);
    point(p.pos.x, p.pos.y, p.pos.z);
    
    //noFill();
    //stroke(p.particleColor, 200);
    //rect(p.pos.x, p.pos.y, p.particleSize, p.particleSize);
    
    if (p.dynamic) {
      p.pos.add(p.vel);
    } else {
      p.pos.x += p.speed;
      p.pos.y = (height/2)+p.offsetY+noise((frameCount-p.startTime)*0.03)*p.variance;
    }
    
    if (! p.dynamic) {
      boolean turnDynamic = false;
      float offset = 1;
      if (p.source == 0 && p.pos.x > sourceX-offset) {
        turnDynamic = true;
      } else if (p.source == 1 && p.pos.x < sourceX+offset) {
        turnDynamic = true;
      }
      
      if (turnDynamic) {
        PVector source = new PVector(sourceX-(offset*p.dir), height/2, 0);
        PVector dir = new PVector(p.pos.x, p.pos.y, p.pos.z);
        dir.sub(source);
        dir.normalize();
        //*-p.dir
        dir.mult(-p.hitSpeed*2.5);
        p.vel.x = dir.x;
        p.vel.y = dir.y;
        p.vel.z = dir.z;
        p.dynamic = true;
      }
    }
    
    if (p.dynamic) {
      float distance = dist(p.pos.x, p.pos.y, p.pos.z, sourceX, height/2, 0);
      if (distance > 200+p.killOffset) {
        allParticles.remove(p);
      }
    }
  }
  //println(allParticles.size());
}
