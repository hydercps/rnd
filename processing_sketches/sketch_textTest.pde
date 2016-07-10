/*
- Invert bg color
- Collect random points from image instead
- Don't move directly to target for more interesting motion
*/

ArrayList<Sprite> sprites = new ArrayList<Sprite>();
ArrayList<String> labels = new ArrayList<String>();
int wordIndex = 0;
int pixelSteps = 5;
boolean drawAsPoints = false;


class Sprite {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);
  float closeEnoughTarget = 50;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float spriteSize = 5;
  color spriteColor = color(80, 0, 0);
  boolean kill = false;
  
  color currentColor = color(0);
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;
  
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
  
  void draw() {
    color c = lerpColor(this.currentColor, this.targetColor, this.colorWeight);
    
    if (drawAsPoints) {
      stroke(c);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(c);
      ellipse(this.pos.x, this.pos.y, this.spriteSize, this.spriteSize);
    }
    
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }
}


PVector generateRandomPos(int originX, int originY, float mag) {
    PVector randomPos = new PVector(random(0, width), random(0, height));
    PVector originPos = new PVector(originX, originY);
    PVector dir = PVector.sub(randomPos, originPos);
    dir.normalize();
    dir.mult(mag);
    originPos.add(dir);
    return originPos;
}


void newWord(String word) {
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
  //image(pg, 0, 0);
  
  color newColor = color(random(0.0, 255.0), random(0.0, 255.0), random(0.0, 255.0));
  
  ArrayList<Integer> indexArray = new ArrayList<Integer>();
  for (int i = 0; i < sprites.size(); i++) { indexArray.add(i); }
  
  for (int y = 0; y < height; y+=pixelSteps) {
    for (int x = 0; x < width; x+=pixelSteps) {
      int index = x+width*y;

      if (pg.pixels[index] != 0) {
        Sprite newSprite;

        if (indexArray.size() > 0) {
          int i = (int)random(0, indexArray.size()); 
          newSprite = sprites.get(indexArray.get(i));
          indexArray.remove(i);
          newSprite.kill = false;
        } else {
          newSprite = new Sprite();
          
          PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
          newSprite.pos.x = randomPos.x;
          newSprite.pos.y = randomPos.y;

          newSprite.maxSpeed = random(2.0, 6.0);
          newSprite.maxForce = newSprite.maxSpeed*0.025;
          newSprite.spriteSize = random(2, 8);
          newSprite.colorBlendRate = random(0.003, 0.03);

        sprites.add(newSprite);
      }
        
        newSprite.currentColor = lerpColor(newSprite.currentColor, newSprite.targetColor, newSprite.colorWeight);
        newSprite.targetColor = newColor;
        newSprite.colorWeight = 0;
        
        newSprite.target.x = x;
        newSprite.target.y = y;
      }
    }
  }
  
  // Kill off any leftover particles
  for (int i = 0; i < indexArray.size(); i++) {
    int index = indexArray.get(i);
    Sprite sprite = sprites.get(index);
    PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
    sprite.target.x = randomPos.x;
    sprite.target.y = randomPos.y;
    sprite.kill = true;
    sprite.currentColor = lerpColor(sprite.currentColor, sprite.targetColor, sprite.colorWeight);
    sprite.targetColor = color(0);
    sprite.colorWeight = 0;
  }
}


void setup() {
  size(700, 300);
  background(255);
  
  labels.add("JAVA");
  labels.add("Python <3");
  labels.add("C++");
  labels.add("THANKS :-)");
  labels.add("");
  
  newWord(labels.get(wordIndex));
}


void mousePressed() {
  if (mouseButton == LEFT) {
    wordIndex += 1;
    if (wordIndex > labels.size()-1) { wordIndex = 0; }
    newWord(labels.get(wordIndex));
  }
}


void draw() {
  fill(255, 100);
  noStroke();
  rect(0, 0, width*2, height*2);
  
  if (mousePressed && mouseButton == RIGHT) {
    fill(255, 0, 0, 15);
    ellipse(mouseX, mouseY, 100, 100);
  }
  
  float steps = 255.0 / sprites.size();
  for (int x = sprites.size()-1; x > -1; x--) {
    Sprite sprite = sprites.get(x);
    sprite.move();
    
    sprite.draw();
    if (sprite.kill) {
      if (sprite.pos.x < 0 || sprite.pos.x > width || sprite.pos.y < 0 || sprite.pos.y > height) {
        sprites.remove(sprite);
      }
    }
  }
}


void mouseDragged() {
  if (mouseButton == RIGHT) {
    for (Sprite sprite : sprites) {
      if (dist(sprite.pos.x, sprite.pos.y, mouseX, mouseY) < 50) {
        if (sprite.kill) { continue; }
        PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
        sprite.target.x = randomPos.x;
        sprite.target.y = randomPos.y;
        sprite.kill = true;
        sprite.currentColor = lerpColor(sprite.currentColor, sprite.targetColor, sprite.colorWeight);
        sprite.targetColor = color(0);
        sprite.colorWeight = 0;
      }
    }
  }
}


void keyPressed() {
  drawAsPoints = (! drawAsPoints);
}
