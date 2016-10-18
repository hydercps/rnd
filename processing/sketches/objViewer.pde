//import peasy.*;

//PeasyCam cam;
Mesh mesh;
boolean showPoints = false;
boolean showEdges = false;
boolean showFaces = true;


class Face {
  ArrayList<Integer> posIndexes;
  ArrayList<Integer> normalIndexes;
  
  Face(ArrayList<Integer> _posIndexes, ArrayList<Integer> _normalIndexes) {
    this.posIndexes = _posIndexes;
    this.normalIndexes = _normalIndexes;
  }
}


class Mesh {
  ArrayList<float[]> vertexes = new ArrayList<float[]>();
  ArrayList<float[]> vertexNormals = new ArrayList<float[]>();
  ArrayList<Face> faces = new ArrayList<Face>();
  
  void display(float offset) {
    //lights();
    
    pushMatrix();
    translate(width/2, height/2);
    rotateY(radians(mouseX*0.5));
    rotateZ(radians(mouseY*0.5));
    
    // Show faces
    if (showEdges) {
      strokeWeight(2);
      stroke(200);
    } else {
      noStroke();
    }
    
    if (showFaces) {
      fill(100);
    } else {
      noFill();
    }
    
    //colorMode(HSB);
    
    for (int i = 0; i < this.faces.size(); i++) {
      //float val = map(i, 0, this.faces.size()-1, 0, 50);
      //fill(val+100, 255, 255);
      
      Face face = this.faces.get(i);
      
      beginShape();
      for (int x = 0; x < face.posIndexes.size(); x++) {
        int normalIndex = face.normalIndexes.get(x);
        float[] n = this.vertexNormals.get(normalIndex);
        normal(n[0], n[1], n[2]);
        
        int vertIndex = face.posIndexes.get(x);
        float[] pos = this.vertexes.get(vertIndex);
        vertex(pos[0]*offset, pos[1]*offset, pos[2]*offset);
      }
      endShape();
    }
    
    //colorMode(RGB);
    
    // Show points
    if (showPoints) {
      strokeWeight(3);
      stroke(255, 255, 0);
      for (int i = 0; i < this.vertexes.size()-1; i++) {
        //float val = map(i, 0, this.faces.size()-1, 0, 50);
        //stroke(val+100, 255, 255);
        
        float[] pos = this.vertexes.get(i);
        point(pos[0]*offset, pos[1]*offset, pos[2]*offset);
      }
    }
    
    popMatrix();
  }
  
  void read(String path, boolean mirrorX, boolean mirrorY, boolean mirrorZ) {
    String lines[] = loadStrings(path);
    
    for (int j = 0; j < lines.length; j++) {
      String line = lines[j];
      
      if (line.startsWith("v ")) { // Get vertex positions
        String[] lineSplit = split(line, " ");
        
        float x = float(lineSplit[1]);
        float y = float(lineSplit[2]);
        float z = float(lineSplit[3]);
        
        if (mirrorX) {
          x = -x;
        }
        
        if (mirrorY) {
          y = -y;
        }
        
        if (mirrorZ) {
          z = -z;
        }
        
        float[] vertPos = {x, y, z};
        this.vertexes.add(vertPos);
      } else if (line.startsWith("vn ")) { // Get vertex normals
        String[] lineSplit = split(line, " ");
        float[] vertNormals = {float(lineSplit[1]), float(lineSplit[2]), float(lineSplit[3])};
        this.vertexNormals.add(vertNormals);
      } else if (line.startsWith("f ")) { // Get face data
        String[] lineSplit = split(line, " ");
        
        ArrayList<Integer> posIndexes = new ArrayList<Integer>();
        ArrayList<Integer> normalIndexes = new ArrayList<Integer>();
        
        for (int i = 1; i < lineSplit.length; i++) {
          String[] valueSplit = split(lineSplit[i], "/");
          posIndexes.add(int(valueSplit[0])-1);
          normalIndexes.add(int(valueSplit[valueSplit.length-1])-1);
        }
        
        this.faces.add(new Face(posIndexes, normalIndexes));
      }
    }
  }
}


void setup() {
  size(500, 500, P3D);
  
  //cam = new PeasyCam(this, 300);
  
  mesh = new Mesh();
  mesh.read("dummy.obj", false, true, false);
}


void draw() {
  background(0);
  mesh.display(1);
}


void keyPressed() {
  if (keyCode == 69) {
    showEdges = ! showEdges;
  } else if (keyCode == 80) {
    showPoints = ! showPoints;
  } else if (keyCode == 70) {
    showFaces = ! showFaces;
  }
}
