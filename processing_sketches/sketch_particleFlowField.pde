ArrayList<Pixel> allPixels = new ArrayList<Pixel>();
ArrayList<PVector> flowField = new ArrayList<PVector>();
ArrayList<ArrayList<PVector>> flowFieldPresets = new ArrayList<ArrayList<PVector>>();
int presetIndex = 0;
int columnCount = 10;
int columnSize;


class Pixel {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  color pixelColor;
  float speed = 1.0;
  boolean active = false;
  float fallRate = 0;
  float speedLimit = 1.0;
  
  Pixel(int x, int y, color inputColor) {
    this.pos.set(x, y);
    this.pixelColor = inputColor;
  }
  
  int getColumnIndex() {
    int index = (int)this.pos.x/columnSize;
    return index;
  }
  
  void draw() {
    stroke(this.pixelColor);
    point(this.pos.x, this.pos.y);
    //ellipse(this.pos.x, this.pos.y, 2, 2);
  }
}


void setup() {
  size(800, 300);
  noFill();
  background(0, 10, 20);
  
  columnSize = width/columnCount;
  
  float[] preset1 = new float[] {0, 0, 0, 0, 0, 1.0, 1.25, -1.0, -1.0, 0.5};
  float[] preset2 = new float[] {0, 0, 0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 0.5};
  float[] preset3 = new float[] {0, 0, 0, -0.4, 1.25, -1.5, 0.25, 0.75, 0.5, 0};
  float[] preset4 = new float[] {0, 0, 0, 0, -1, -0.2, -0.4, 0, 0, 0.75};
  float[] preset5 = new float[] {0, 0, -1.0, -1.25, 1.25, -1.25, 1.25, -1.25, 1.25, -0.25};
  float[] preset6 = new float[] {0, 0, -1.6, 1.4, -1.2, 1.0, -0.8, 0.6, -0.4, 0.2};
  
  addFlowPreset(preset1);
  addFlowPreset(preset2);
  addFlowPreset(preset3);
  addFlowPreset(preset4);
  addFlowPreset(preset5);
  addFlowPreset(preset6);
}


void addFlowPreset(float[] rotateValues) {
  ArrayList<PVector> preset = new ArrayList<PVector>();
  
  for (int i = 0; i < rotateValues.length; i++) {
    PVector direction = new PVector(0, 1);
    direction.rotate(HALF_PI);
    direction.rotate(rotateValues[i]);
    direction.normalize();
    preset.add(direction);
  }
  
  flowFieldPresets.add(preset);
}


void draw() {
  background(0, 10, 20);
  
  for (int x = 0; x < 10; x ++) {
    color pixelColor = color(255);
    float sourceHeight = (height/2)+sin(frameCount/20.0)*20;
    float pinch = 15+(sin(frameCount/30.0)*12);
    Pixel newPixel = new Pixel(width-1, (int)random(sourceHeight-pinch, sourceHeight+pinch), pixelColor);
    newPixel.speed = random(0.05, 0.15);
    newPixel.speedLimit = newPixel.speed * 20;
    newPixel.fallRate = random(0.05, 0.1);
    allPixels.add(newPixel);
  }
  
  for (int i = allPixels.size()-1; i > -1; i--) {
    Pixel p = allPixels.get(i);
    
    if (p.pos.x < (int)random(170, 230)) {
      p.active = true;
    } else if (p.pos.x < 300) {
      if ((int)random(0, 10000) < 10) {
        p.active = true;
      }
    }
    
    if (p.active) {
      PVector gravity = new PVector(0, p.fallRate);
      p.acc.add(gravity);
    } else {
      int index = (int)p.getColumnIndex();
      if (index < 0) { continue; }
      PVector direction = new PVector(flowFieldPresets.get(presetIndex).get(index).x, flowFieldPresets.get(presetIndex).get(index).y); // CRASHES HERE
      direction.normalize();
      //direction.setMag(0.2);
      direction.setMag(p.speed);
      p.acc.add(direction);
    }
    
    p.vel.add(p.acc);
    if (! p.active) {
      if (p.vel.mag() > p.speedLimit) {
        p.vel.setMag(p.speedLimit);
      }
    }
    
    p.pos.add(p.vel);
    p.acc.mult(0);
    
    p.draw();
    
    if (p.pos.x < 0 || p.pos.y > height+100) {
      allPixels.remove(p);
    }
  }
  
  textSize(10);
  textAlign(CENTER);
  text("Click for a new flow.", width/2, height-20);
}


void mousePressed() {
  allPixels.clear();
  presetIndex += 1;
  if (presetIndex > flowFieldPresets.size()-1) { presetIndex = 0; }
}