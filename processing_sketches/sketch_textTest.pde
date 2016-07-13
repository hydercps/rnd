/*
Particles text effects
     
Controls:
- Left-click button to get a new word.
- Hold right-click button to interact with the particles.
- Press any key to toggle draw styles.

Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Global variables
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<String> labels = new ArrayList<String>();
int wordIndex = 0;
int pixelSteps = 8; // Amount of pixels to skip
boolean drawAsPoints = false;


class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);
  float closeEnoughTarget = 50;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float particleSize = 5;
  color particleColor = color(80, 0, 0);
  boolean isKilled = false;
  
  color currentColor = color(0);
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;
  
  void move() {
    // Check if particle should be slowing down
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
    
    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
  
  void draw() {
    color c = lerpColor(this.currentColor, this.targetColor, this.colorWeight);
    
    if (drawAsPoints) {
      stroke(c);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(c);
      ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
    }
    
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }
  
  void kill() {
    if (! this.isKilled) {
      PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
      this.target.x = randomPos.x;
      this.target.y = randomPos.y;
      
      this.currentColor = lerpColor(this.currentColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;
      
      this.isKilled = true;
    }
  }
}


// Picks a random position from a point's radius
PVector generateRandomPos(int originX, int originY, float mag) {
    PVector randomPos = new PVector(random(0, width), random(0, height));
    PVector originPos = new PVector(originX, originY);
    PVector dir = PVector.sub(randomPos, originPos);
    dir.normalize();
    dir.mult(mag);
    originPos.add(dir);
    return originPos;
}


void nextWord(String word) {
  // Draw word in memory
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(100);
  pg.textAlign(CENTER);
  PFont font = createFont("Arial Bold", 100);
  pg.textFont(font);
  pg.text(word, width/2, height/2);
  pg.endDraw();
  pg.loadPixels();
  
  // Next color for all pixels to change to
  color newColor = color(random(0.0, 255.0), random(0.0, 255.0), random(0.0, 255.0));
  
  int particleCount = particles.size();
  int particleIndex = 0;
  
  ArrayList<Integer> coordsIndexes = new ArrayList<Integer>();
  for (int i = 0; i < (width*height)-1; i+= pixelSteps) { coordsIndexes.add(i); }
  
  for (int i = 0; i < coordsIndexes.size(); i++) {
    int randomIndex = (int)random(0, coordsIndexes.size());
    int index = coordsIndexes.get(randomIndex);
    coordsIndexes.remove(randomIndex);
    
    if (pg.pixels[index] != 0) {
      int x = index % width;
      int y = index / width;
      
      Particle newParticle;

      if (particleIndex < particleCount) {
        newParticle = particles.get(particleIndex);
        newParticle.isKilled = false;
        particleIndex += 1;
      } else {
        newParticle = new Particle();
        
        PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
        newParticle.pos.x = randomPos.x;
        newParticle.pos.y = randomPos.y;

        newParticle.maxSpeed = random(2.0, 6.0);
        newParticle.maxForce = newParticle.maxSpeed*0.025;
        newParticle.particleSize = random(2, 8);
        newParticle.colorBlendRate = random(0.003, 0.03);

        particles.add(newParticle);
      }
      
      newParticle.currentColor = lerpColor(newParticle.currentColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = newColor;
      newParticle.colorWeight = 0;
      
      newParticle.target.x = x;
      newParticle.target.y = y;
    }
  }
  
  // Kill off any leftover particles
  if (particleIndex < particleCount) {
    for (int i = particleIndex; i < particleCount; i++) {
      Particle particle = particles.get(i);
      particle.kill();
    }
  }
}


void setup() {
  size(700, 300);
  background(255);
  
  labels.add("JAVA");
  labels.add("Python <3");
  labels.add("C++");
  labels.add("Bye :-)");
  labels.add("");
  
  nextWord(labels.get(wordIndex));
}


void draw() {
  // Background & motion blur
  fill(255, 100);
  noStroke();
  rect(0, 0, width*2, height*2);
  
  // Display kill radius if right-click is being held
  if (mousePressed && mouseButton == RIGHT) {
    fill(255, 0, 0, 15);
    ellipse(mouseX, mouseY, 100, 100);
  }
  
  float steps = 255.0 / particles.size();
  
  for (int x = particles.size()-1; x > -1; x--) {
    // Simulate and draw pixels
    Particle particle = particles.get(x);
    particle.move();
    particle.draw();
    
    // Remove any dead pixels out of bounds
    if (particle.isKilled) {
      if (particle.pos.x < 0 || particle.pos.x > width || particle.pos.y < 0 || particle.pos.y > height) {
        particles.remove(particle);
      }
    }
  }
}


// Show next word
void mousePressed() {
  if (mouseButton == LEFT) {
    wordIndex += 1;
    if (wordIndex > labels.size()-1) { wordIndex = 0; }
    nextWord(labels.get(wordIndex));
  }
}


// Kill pixels that are in range
void mouseDragged() {
  if (mouseButton == RIGHT) {
    for (Particle particle : particles) {
      if (dist(particle.pos.x, particle.pos.y, mouseX, mouseY) < 50) {
        particle.kill();
      }
    }
  }
}


// Toggle draw modes
void keyPressed() {
  drawAsPoints = (! drawAsPoints);
}
