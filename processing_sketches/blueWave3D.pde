/*
Blue Wave 3d
 
Controls:
- Mouse X controls frequency.
- Mouse Y controls amplitude.
 
Author: Jason Labbe
Site: jasonlabbe3d.com
*/

//import peasy.*;
//PeasyCam cam;

float freq = 10;
float amp = 50;
float w = 20;
float h = 20;


void setup() {
  size(640, 450, P3D);
  background(0);
  rectMode(CENTER);
  noStroke();
  //cam = new PeasyCam(this, 400);
}


void draw() {
  background(0);
  //fill(0, 0, 50, 40);
  //rect(0, 0, width*2, height*2);
  float rotx = (mouseY/360.0)*PI+PI;
  float roty = (mouseX/420.0)*PI-PI;
  float rotz = 0*PI/36;

  for (int z = 0; z < 20; z++) {
    pushMatrix();
    translate(width/4, 0, 0);
    rotateX(rotx);
    rotateY(roty);
    rotateZ(rotz);
    for (int i = 0; i < 25; i++) {
      // Middle blue
      stroke(230, 255, 255, 255);
      point(i*10, (height/2)+sin((frameCount+i*3)/freq)*(amp*1), z*5);
      
      for (int x = 1; x < 8; x++) {
        // Top blue
        stroke(200-(x*20), 255, 255, 255-(x*30));
        //rect(i*20, (height/2-(x*20)) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), w*(1-(x*0.075)), h*(1-(x*0.075)), 25-(x*3.5));
        point(i*10, (height/2-(x*10)) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
        
        // Bottom blue
        stroke(200-(x*20), 255, 255, 255-(x*30));
        //rect(i*20, (height/2+(x*20)) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), w*(1-(x*0.075)), h*(1-(x*0.075)), 25-(x*3.5));
        point(i*10, (height/2+(x*10)) + sin((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
        
        // Top purple
        stroke(255, 200-(x*20), 255, 100);
        //rect(i*20+10, (height/2-(x*20)) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), w*(x*0.125), h*(x*0.125), 25-(x*3.5));
        point(i*10.5-5, (height/2-(x*12)) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
        
        // Bottom purple
        stroke(255, 200-(x*20), 255, 100);
        //rect(i*20+10, (height/2+(x*20)) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), w*(x*0.125), h*(x*0.125), 25-(x*3.5));
        point(i*10.5-5, (height/2+(x*12)) + cos((frameCount+i*3)/freq) * (amp*(1-(x*0.13))), z*5);
      }
    }
    popMatrix();
  }
}


/*void mouseMoved() {
  freq = 10 * (1.0-mouseX/(float)width+1);
  amp = 50 * (1.0-mouseY/(float)height+1);
}*/
