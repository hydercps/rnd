/*
- Switch to new letters
- Remove sprites if there are too many
- Add new sprites if there aren't enough
*/

ArrayList<Sprite> sprites = new ArrayList<Sprite>();


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
}


void setup() {
  size(500, 500);
  background(255);
  
  PGraphics pg = createGraphics(width, height);
  
  pg.beginDraw();
  
  pg.fill(0);
  pg.textSize(100);
  pg.textAlign(CENTER);
  PFont font = createFont("Arial Bold", 100);
  pg.textFont(font);
  pg.text("JAVA.", width/2, height/2);
  
  pg.endDraw();
  
  pg.loadPixels();
  //image(pg, 0, 0);
  
  for (int y = 0; y < height; y+=5) {
    for (int x = 0; x < width; x+=5) {
      int index = x+width*y;
      if (pg.pixels[index] != 0) {
        Sprite newSprite = new Sprite();
        
        PVector randomPos = generateRandomPos();
        //newSprite.pos.set(randomPos.x, randomPos.y);
        newSprite.pos.x = randomPos.x;
        newSprite.pos.y = randomPos.y;
        
        //newSprite.target.set(x, y);
        newSprite.target.x = x;
        newSprite.target.y = y;
        newSprite.maxSpeed = random(2.0, 6.0);
        newSprite.maxForce = newSprite.maxSpeed*0.025;
        newSprite.spriteSize = random(2, 8);
        sprites.add(newSprite);
      }
    }
  }
}


PVector generateRandomPos() {
    PVector randomPos = new PVector(random(0, width), random(0, height));
    PVector originPos = new PVector(width/2, height/2);
    PVector dir = PVector.sub(randomPos, originPos);
    dir.normalize();
    dir.mult((width+height)/2);
    originPos.add(dir);
    return originPos;
}


void draw() {
  colorMode(RGB);
  fill(255, 100);
  noStroke();
  rect(0, 0, width*2, height*2);
  
  colorMode(HSB);
  
  float steps = 255.0 / sprites.size();
  for (int x = 0; x < sprites.size(); x++) {
    sprites.get(x).move();
    
    noStroke();
    color currentColor = color(x*0.07, 220, 220);
    fill(currentColor);
    //fill(sprites.get(x).spriteColor);
    ellipse(sprites.get(x).pos.x, sprites.get(x).pos.y, sprites.get(x).spriteSize, sprites.get(x).spriteSize);
  }
}
