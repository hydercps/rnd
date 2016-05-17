class Planet {
  PVector pos = new PVector();
  float size;
  float angle = 0;
  color fill_color = color(0, 0, 0, 0);
  color stroke_color = color(0, 0, 0, 0);
  ArrayList<Planet> satellites = new ArrayList<Planet>();
  Planet parent;
  
  Planet(float size_input) {
    this.size = size_input;
  }
  
  void draw() {
    //fill(this.fill_color);
    stroke(this.stroke_color);
    
    pushMatrix();
    
    ArrayList<Planet> all_planets = new ArrayList<Planet>();
    Planet parent_planet = this.parent;
    while (parent_planet != null) {
      all_planets.add(0, parent_planet);
      parent_planet = parent_planet.parent;
    }
    
    for (Planet p : all_planets) {
      rotate(p.angle);
      translate(p.pos.x, p.pos.y);
    }
    
    if (this.parent != null) {
      this.pos.x = (this.size + this.parent.size) / 2;
    }
    
    rotate(this.angle);
    
    translate(this.pos.x, this.pos.y);
    ellipse(0, 0, this.size, this.size);
    popMatrix();
  }
  
  void addSatellite(Planet sat) {
    this.satellites.add(sat);
    sat.parent = this;
  }
}


//float angle = 0;
Planet planet1 = new Planet(200);
Planet planet2 = new Planet(100);
Planet planet3 = new Planet(50);
Planet planet4 = new Planet(25);
Planet planet5 = new Planet(10);

void setup() {
  size(800, 800);
  background(0);
  noFill();
  rectMode(CENTER);
  //frameRate(1);
  
  planet1.stroke_color = color(255, 0, 0);
  planet2.stroke_color = color(0, 255, 0);
  planet3.stroke_color = color(255, 255, 0);
  planet4.stroke_color = color(255, 255, 255);
  planet5.stroke_color = color(0, 0, 255);
  planet1.addSatellite(planet2);
  planet2.addSatellite(planet3);
  planet3.addSatellite(planet4);
  planet4.addSatellite(planet5);
  
  planet1.pos.set(width/2, height/2);
}

void draw() {
  planet1.draw();
  planet2.draw();
  planet3.draw();
  planet4.draw();
  planet5.draw();
  planet2.angle += 0.01;
  planet3.angle += 0.01;
  planet4.angle += 0.01;
  planet5.angle += 0.05;
}
