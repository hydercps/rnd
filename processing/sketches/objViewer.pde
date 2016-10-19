/*
To do:
  - Use alt instead of ctrl.
  - Set rotate pivot in center of model.
*/

Mesh mesh;
boolean showPoints = false;
boolean showEdges = false;
boolean showFaces = true;

PVector mouseClick = new PVector();

PVector rotStart = new PVector();
PVector posStart = new PVector();
PVector zoomStart = new PVector();

float rotx = -45;
float roty = 0;
float posx = 0;
float posy = 0;
float zoom = 0;


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
    lights();
    
    pushMatrix();
    translate(width/2, height/2);
    translate(posx, posy, zoom);
    rotateY(radians(rotx));
    rotateX(radians(-roty));
    
    // Show faces
    if (showEdges) {
      strokeWeight(1);
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
  
  // Works in processing
  void read(String path, boolean mirrorX, boolean mirrorY, boolean mirrorZ) {
    BufferedReader reader;
    String line;
    
    reader = createReader(path);
    line = nextLine(reader);
    
    while (line != null) {
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
      
      line = nextLine(reader);
    }
  }
  
  // Works in Javascript
  void _read(String path, boolean mirrorX, boolean mirrorY, boolean mirrorZ) {
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


String nextLine(BufferedReader reader) {
  try {
    String line = reader.readLine();
    return line;
  } catch (IOException e) {
    e.printStackTrace();
  }
  return null;
}


void setup() {
  size(500, 500, P3D);
  
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


void mousePressed() {
  rotStart.set(rotx, roty);
  posStart.set(posx, posy);
  zoomStart.set(zoom, zoom);
  mouseClick.set(mouseX, mouseY);
}


void mouseWheel(MouseEvent event) {
  float dir = -event.getCount();
  if (keyPressed && keyCode == CONTROL) {
    dir *= 20;
  }
  else { 
    dir *= 5;
  }
  zoom += dir;
}


void mouseDragged() {
  if (keyPressed && keyCode == CONTROL) {
    if (mouseButton == LEFT) {
      rotx = rotStart.x+(mouseX-mouseClick.x);
      roty = rotStart.y+(mouseY-mouseClick.y);
    } else if (mouseButton == CENTER) {
      posx = posStart.x+(mouseX-mouseClick.x);
      posy = posStart.y+(mouseY-mouseClick.y);
    } else if (mouseButton == RIGHT) {
      zoom = zoomStart.x+(mouseX-mouseClick.x);
    }
  }
}
