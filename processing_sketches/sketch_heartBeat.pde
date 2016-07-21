/*
Sometimes crashes when click and dragging

Heart beat
 
 Controls:
 - Left-click explode heart.
 - Right-click reset heart.
 - Up & down arrow keys to change amount of points (hold down if it's too slow)
 
 Inspired by Ilyas Shafigin's Heart Wings sketch (http://www.openprocessing.org/sketch/377004)
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 
 
Left-click to break my heart </3 then right-click to mend it <3

If it's running too slowly you can keep pressing the down arrow key to decrease the amount of points.

This sketch draws and performs much better in Java mode, so I had to decrease some values so it's more playable.
 */


// Global variables
ArrayList<Particle> allParticles = new ArrayList<Particle>();
float pulsateMult = 0;
PVector explosionPos;
PVector gravity = new PVector(0, 0.1, 0);
float angleSteps = 2.0;


class Particle {
  PVector pos = new PVector(0, 0, 0);
  PVector vel = new PVector(0, 0, 0);
  int zDepth = 0;
  color pixelColor;
  float explosionMult = 0;
  boolean active = false;

  Particle(float x, float y, float z) {
    this.pos.set(x, y, z);
    this.explosionMult = random(0.5, 8.0);
  }

  void draw() {
    strokeWeight(2);
    stroke(this.pixelColor);

    // Crashes on OP
    pushMatrix();
    translate(this.pos.x, this.pos.y, this.pos.z);
    rotate(45);
    rect(0, 0, 3, 3);
    popMatrix();
    
    /*pushMatrix();
    rect(this.pos.x, this.pos.y, 3, 3);
    popMatrix();*/
  }
}


// Code for getting heart shape by Ilyas Shafigin
void createHeart(int heartSize, int depthAmount, int spacing) {
  frameCount = 0;
  allParticles.clear();

  for (int z = 0; z < depthAmount; z++) {
    for (float angle = -90; angle < 90; angle += angleSteps) {
      float t = angle*2.0;
      float x = 16*pow(sin(radians(t)), 3);
      float y = -13*cos(radians(t)) + 5*cos(radians(2*t)) + 2*cos(radians(3*t)) + cos(radians(4*t));

      Particle particle = new Particle(x*heartSize+width/2, y*heartSize+height/2, z*spacing);
      particle.pixelColor = color(30+z*20, 0, z*5);
      particle.zDepth = z+1;
      allParticles.add(particle);
    }
  }
}


void setup() {
  size(640, 640, P3D);
  noFill();

  explosionPos = new PVector(0, 0, 0);

  createHeart(6, 15, 10);
}


void draw() {
  background(30);

  for (Particle particle : allParticles) {
    if (particle.active) {
      // Particle is dynamic
      particle.vel.add(gravity);

      if (particle.pos.x == width/2) { 
        // This is just so there aren't any particles going straight down the middle
        particle.vel.x += random(-0.15, 0.15);
      }

      particle.pos.add(particle.vel);
    } else {
      // Particle is passive and should keep pulsating
      PVector dir = new PVector(-width/2, -height/2, 0);
      dir.add(particle.pos);
      dir.normalize();
      dir.mult(pulsateMult*particle.zDepth*0.05+cos(frameCount*0.05)*1.5);
      particle.pos.add(dir);
    }

    particle.draw();
  }

  pulsateMult = sin(frameCount*0.05)*1.5;

  // Display text
  // This doesn't show up in js mode
  stroke(255);
  textAlign(CENTER);
  textSize(10);
  text("Left-click to break my heart </3 then right-click to mend it <3", width/2, height-30, -10);
}


void mousePressed() {
  // Explode heart
  if (mouseButton == LEFT) {
    explosionPos.x = -mouseX;
    explosionPos.y = -mouseY;

    for (Particle particle : allParticles) {
      if (particle.active) {
        continue;
      }

      PVector dir = new PVector(particle.pos.x, particle.pos.y, particle.pos.z);
      dir.add(explosionPos);
      dir.normalize();
      dir.mult(particle.explosionMult);
      particle.vel.add(dir);
      particle.active = true;
    }
  } else if (mouseButton == RIGHT) {
    createHeart(6, 15, 10);
  }
}


void keyPressed() {
  if (keyCode == 38) {
    // Up arrow to increate points
    angleSteps = max(1.0, angleSteps-0.5);
    createHeart(6, 15, 10);
  } else if (keyCode == 40) {
    // Down arrow to decrease points
    angleSteps = min(5.0, angleSteps+0.5);
    createHeart(6, 15, 10);
  }
}
