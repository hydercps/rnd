/*
Blue Wave 3d
 
Controls:
- Mouse X controls frequency.
- Mouse Y controls amplitude.
 
Author: Jason Labbe
Site: jasonlabbe3d.com
*/


float freq = 10;
float amp = 50;
float w = 20;
float h = 20;

float rotx = -0.25;
float roty = 0.5;
float zoom = 0;

void setup() {
  size(640, 450, P3D);
  background(0);
  rectMode(CENTER);
  noStroke();
}

void mouseMoved() {
  rotx = -(mouseY-height/2)/160.0;
  roty = (mouseX-width/2)/160.0;
}


void mouseDragged() {
  zoom = mouseX-width/2;
}


void draw() {
  background(0);
  //fill(0, 0, 50, 40);
  //rect(0, 0, width*2, height*2);
  
  float widthOffset = width/2-100;
  float heightOffset = height/2;
  
  noFill();
  
  pushMatrix();
  translate(widthOffset, heightOffset, zoom);
  rotateX(rotx);
  rotateY(roty);
  for (int z = 0; z < 20; z++) {
    translate(0, 0, z*0.5);
    for (int i = 0; i < 25; i++) {
      // Middle blue
      stroke(230, 255, 255, 255);
      rect(widthOffset-i*10, sin((frameCount+i*3)/freq)*(amp*1), 2, 2);
      //stroke(255, 240, 240, 255);
      //point(widthOffset-i*10, sin((frameCount+i*3)/freq)*(amp*1), z*5);
      for (int x = 1; x < 8; x++) {
        // Top blue
        stroke(200-(x*20), 255, 255, 200-(x*25));
        rect(widthOffset-i*10, -(x*10) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), 2, 2);
        //stroke(255, 240-(x*20), 240-(x*20), 255-(x*10));
        //point(widthOffset-i*10, -(x*10) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
        
        // Bottom blue
        stroke(200-(x*20), 255, 255, 200-(x*25));
        rect(widthOffset-i*10, (x*10) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), 2, 2);
        //stroke(255, 240-(x*20), 240-(x*20), 255-(x*10));
        //point(widthOffset-i*10, (x*10) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
        
        // Top purple
        stroke(255, 200-(x*20), 255, 15);
        rect(widthOffset-i*10, -(x*12) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), 2, 2);
        //stroke(255, 200-(x*20), 255, 100);
        //point(widthOffset-i*10.5-5, -(x*12) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
        
        // Bottom purple
        stroke(255, 200-(x*20), 255, 15);
        rect(widthOffset-i*10, (x*12) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), 2, 2);
        //stroke(255, 200-(x*20), 255, 100);
        //point(widthOffset-i*10.5-5, (x*12) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
      }
    }
  }
  popMatrix();
}


/*void mouseMoved() {
  freq = 10 * (1.0-mouseX/(float)width+1);
  amp = 50 * (1.0-mouseY/(float)height+1);
}*/
