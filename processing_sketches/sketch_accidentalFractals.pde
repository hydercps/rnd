/*
Solar system sketcher

Controls:
- Mouse click to start a new solar system
- Any key to toggle between draw styles

Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Global variables
ArrayList<Planet> allPlanets = new ArrayList<Planet>();
boolean drawFill = false;
float r = 0;
float g = 0;
float b = 0;


class Planet {
  ArrayList<Planet> satellites = new ArrayList<Planet>();
  Planet parent;
  PVector pos = new PVector();
  float size = 0;
  float sizeRate = 0;
  float angle = 0;
  float angleRate = 0.1;
  boolean reverseAngleRate = false;
  color mainColor = color(0, 0, 0, 0);
  boolean renderable = false;
  
  Planet(float sizeInput) {
    this.size = sizeInput;
  }
  
  /**
   * Apply its world position and displays it.
   */
  void draw() {
    // Determine draw style
    if (drawFill) {
      fill(this.mainColor);
      noStroke();
    } else {
      stroke(this.mainColor);
      noFill();
    }
    
    noStroke();
    fill(0, 255, 255);
    
    pushMatrix();
    
    // Collect this planet's hierarchy
    ArrayList<Planet> planetHierarchy = new ArrayList<Planet>();
    
    Planet parentPlanet = this.parent;
    while (parentPlanet != null) {
      planetHierarchy.add(0, parentPlanet);
      parentPlanet = parentPlanet.parent;
    }
    
    // Work down the hierarchy and each parent's transformations
    for (Planet planet : planetHierarchy) {
      rotate(planet.angle);
      translate(planet.pos.x, planet.pos.y);
    }
    
    // Move out the planet so it rests along side its parent
    if (this.parent != null) {
      this.pos.x = (this.size + this.parent.size) / 2;
    }
    
    rotate(this.angle);
    translate(this.pos.x, this.pos.y);
    if (this.renderable) {
      //ellipse(0, 0, this.size, this.size);
      rect(0, 0, this.size, this.size);
    }
    
    popMatrix();
    
    // Rotate for next iteration
    /*if (this.parent != null) {
      if (this.reverseAngleRate) {
        this.angle -= this.angleRate;
      } else {
        this.angle += this.angleRate;
      }
    }*/
    
    // Scale for next iteration
    /*if (this.sizeRate != 0) {
      this.size -= this.sizeRate; 
    }*/
  }
  
  /**
   * Adds new planets to itself that will orbit it.
   * Args:
   *   planetCount: The number of new satellites to add.
   * Returns:
   *   A list of the new planets.
   */
  ArrayList<Planet> addSatellites(int planetCount) {
    ArrayList<Planet> newSatellites = new ArrayList<Planet>();
    
    // Determine some common values the new planets will have
    //float newSize = random(10, 150);
    float newSize = this.size / 2;
    
    float newSizeRate = random(0.01, 0.2);
    
    color newColor = color(random(0,255), 
                           random(0,255), 
                           random(0,255),
                           255);
    
    float newAngleRate = random(0.001, 0.03);
    
    boolean newReverseAngleRate = false;
    if (int( random(2) ) == 1) { newReverseAngleRate = true; }
    
    for (int i = 0; i < planetCount; i++) {
      // Create a new planet with its own starting angle
      Planet newPlanet = new Planet(newSize);
      newPlanet.parent = this;
      //newPlanet.sizeRate = newSizeRate;
      newPlanet.mainColor = newColor;
      float startAngle = radians( (360/planetCount)*(i+1) );
      newPlanet.angle = startAngle;
      //newPlanet.angleRate = newAngleRate;
      //newPlanet.reverseAngleRate = newReverseAngleRate;
      this.satellites.add(newPlanet);
      newSatellites.add(newPlanet);
    }
    
    return newSatellites;
  }
}


void setup() {
  size(800, 800);
  rectMode(CENTER);
  //reset();
  frameRate(3);
}

int n = 1;
void draw() {
  if (n > 6) { return; }
  println(n);
  allPlanets.clear();
  background(0);
  drawTip();
  createSolarSystem(n, 6);
  n += 1;
  for (Planet p : allPlanets) {
    p.draw();
  }
}


int fractalIndex = 0;

void mousePressed() {
  n = 1;
  fractalIndex +=1;
  if (fractalIndex > 5) { fractalIndex = 0; }
  //reset();
}


void keyPressed() {
  drawFill = ! drawFill;
}


/** Displays control tips on top of the screen. */
void drawTip() {
  textSize(11);
  textAlign(CENTER);
  fill(255);
  String tip = "Click anywhere for a new solar system.\n";
  tip += "Press any key to toggle between draw styles.";
  text(tip, width/2, 30);
}


/** Clears current solar system and creates a new one. */
void reset() {
  allPlanets.clear();
  background(0);
  drawTip();
  
  if (fractalIndex == 0) { createSolarSystem(7, 2); }
  else if (fractalIndex == 1) { createSolarSystem(7, 3); }
  else if (fractalIndex == 2) { createSolarSystem(7, 4); }
  else if (fractalIndex == 3) { createSolarSystem(6, 5); }
  else if (fractalIndex == 4) { createSolarSystem(6, 6); }
  else if (fractalIndex == 5) { createSolarSystem(5, 8); }
  
  for (Planet p : allPlanets) {
    p.draw();
  }
}


/**
 * Creates a solar system.
 * Args:
 *   nestedCount: The amount of levels of planets to create.
 *   minSatCount: The minimum amount of satellites a planet should have.
 *   maxSatCount: The maximum amount of satellites a planet should have.
 */
void createSolarSystem(int nestedCount, int satCount) {
  allPlanets.clear();
  
  // Create the first planet in the window's center
  Planet masterPlanet = new Planet(200);
  masterPlanet.pos.set(width/2, height/2);
  masterPlanet.sizeRate = random(0.1, 0.25);
  masterPlanet.mainColor = color(255, 255, 255, 255 );
  
  ArrayList<Planet> newPlanets = new ArrayList<Planet>();
  newPlanets.add(masterPlanet);
  
  for (int i = 0; i < nestedCount; i++) {
    ArrayList<Planet> tempSatellites = new ArrayList<Planet>();
    
    for (Planet p : newPlanets) {
      /*int satelliteCount = int( random(minSatCount, maxSatCount) );
      if (satelliteCount == 0) {
        continue; 
      }*/
      
      ArrayList<Planet> satellites = p.addSatellites(satCount);
      tempSatellites.addAll(satellites);
    }
    
    if (i == nestedCount-2) {
      for (Planet p : tempSatellites) {
        p.renderable = true;
      }
    }
    
    allPlanets.addAll(newPlanets);
    
    newPlanets.clear();
    newPlanets = tempSatellites;
  }
}
