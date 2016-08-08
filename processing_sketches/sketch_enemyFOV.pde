/*
* Show curved fov
- Rotate fov with enemy
- Have many enemies
*/

PVector player;
PVector enemy;
PVector dir;
float sightDistance = 300;
float sightAngle = 45;


void setup() {
 size(800, 800);
 player = new PVector(0, 0);
 enemy = new PVector(width/2, 200);
 dir = new PVector(0, 1.0);
}


void draw() {
 background(255);
 noStroke();
 
 player.x = mouseX;
 player.y = mouseY;
 
 // Get vector to player
 PVector dir2 = new PVector(player.x, player.y);
 dir2.sub(enemy);
 dir2.normalize();
 
 // Check angle
 PVector ray1 = new PVector(dir.x, dir.y);
 ray1.normalize();
 PVector ray2 = new PVector(dir2.x, dir2.y);
 ray2.normalize();
 float angle = degrees(acos(ray1.dot(ray2)));
 
 float distance = dist(player.x, player.y, enemy.x, enemy.y);
 
 boolean inVision = false;
 
 fill(0);
 textAlign(LEFT);
 textSize(12);
 text("Angle=" + angle, 10, 30);
 
 textSize(12);
 text("Dist=" + distance, 10, 50);
 
 if (angle < 45) {
   if (distance < sightDistance) {
     inVision = true;
     fill(0);
     textSize(50);
     textAlign(CENTER);
     text("!", enemy.x, enemy.y-20);
   }
 }
 
 if (inVision) {
   fill(255, 0, 0, 20);
 } else {
   fill(0, 0, 255, 20);
 }
 pushMatrix();
 translate(enemy.x, enemy.y);
 rotate(radians(90));
 translate(-enemy.x, -enemy.y);
 arc(enemy.x, enemy.y, sightDistance*2, sightDistance*2, radians(-sightAngle), radians(sightAngle));
 popMatrix();
 
 fill(0, 255, 0);
 ellipse(player.x, player.y, 20, 20);
 
 fill(255, 0, 0);
 ellipse(enemy.x, enemy.y, 20, 20);
}
