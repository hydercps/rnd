import peasy.*;

class Face {
  ArrayList<Integer> posIndexes;
  ArrayList<Integer> normalIndexes;
  
  Face(ArrayList<Integer> _posIndexes, ArrayList<Integer> _normalIndexes) {
    this.posIndexes = _posIndexes;
    this.normalIndexes = _normalIndexes;
  }
}


class Mesh {
  ArrayList<float[]> vertexes;
  ArrayList<float[]> vertexNormals;
  ArrayList<int[]> faces;
  
  Mesh(ArrayList<float[]> _vertexes, ArrayList<float[]> _vertexNormals, ArrayList<int[]> _faces) {
    this.vertexes = _vertexes;
    this.vertexNormals = _vertexNormals;
    this.faces = _faces;
  }
  
  void display(float offset) {
    
  }
}


PeasyCam cam;
ArrayList<float[]> vertexes = new ArrayList<float[]>();
ArrayList<float[]> vertexNormals = new ArrayList<float[]>();
ArrayList<Face> faces = new ArrayList<Face>();
float offset = 10;

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
  colorMode(HSB);
  
  cam = new PeasyCam(this, 300);
  
  BufferedReader reader;
  String line;
  
  reader = createReader("C:\\Users\\GreenCell\\Desktop\\crazyMesh.obj");
  line = nextLine(reader);
  
  while (line != null) {
    if (line.startsWith("v ")) {
      // Get vertex data
      String[] lineSplit = split(line, " ");
      float[] vertPos = {float(lineSplit[1]), float(lineSplit[2]), float(lineSplit[3])};
      vertexes.add(vertPos);
    } else if (line.startsWith("vn ")) {
      // Get vertex normals
      String[] lineSplit = split(line, " ");
      float[] vertNormals = {float(lineSplit[1]), float(lineSplit[2]), float(lineSplit[3])};
      vertexNormals.add(vertNormals);
    } else if (line.startsWith("f ")) {
      // Get face data
      // Normals should always be last in the list
      
      String[] lineSplit = split(line, " ");
      
      ArrayList<Integer> posIndexes = new ArrayList<Integer>();
      ArrayList<Integer> normalIndexes = new ArrayList<Integer>();
      
      int[] faceInfo = new int[lineSplit.length-1];
      for (int i = 1; i < lineSplit.length; i++) {
        String[] valueSplit = split(lineSplit[i], "/");
        int vertIndex = int(valueSplit[0])-1;
        faceInfo[i-1] = vertIndex;
        posIndexes.add(vertIndex);
        
        int normalIndex = int(valueSplit[valueSplit.length-1])-1;
        normalIndexes.add(normalIndex);
      }
      
      Face face = new Face(posIndexes, normalIndexes);
      faces.add(face);
    }
    
    line = nextLine(reader);
  }
}

void draw() {
  background(0);
  
  lights();
  
  // Show faces
  noStroke();
  
  for (int i = 0; i < faces.size(); i++) {
    float val = map(i, 0, faces.size()-1, 0, 50);
    fill(val+100, 255, 255);
    //fill(100);
    
    Face face = faces.get(i);
    
    beginShape();
    for (int x = 0; x < face.posIndexes.size(); x++) {
      int normalIndex = face.normalIndexes.get(x);
      float[] n = vertexNormals.get(normalIndex);
      normal(n[0], n[1], n[2]);
      
      int vertIndex = face.posIndexes.get(x);
      float[] pos = vertexes.get(vertIndex);
      vertex(pos[0]*offset, pos[1]*offset, pos[2]*offset);
    }
    endShape();
  }
  
  // Show points
  /*strokeWeight(2);
  for (int i = 0; i < vertexes.size()-1; i++) {
    float val = map(i, 0, faces.size()-1, 0, 50);
    stroke(val, 100, 255);
    
    float[] pos = vertexes.get(i);
    point(pos[0]*offset, pos[1]*offset, pos[2]*offset);
  }*/
}
