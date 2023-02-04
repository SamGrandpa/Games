PImage floor1, floor2, leftWall, rightWall, endRoad, obstacle1, Sun, Moon, Earth, UFO, Eye;
PShape alien;

void setup() {
  size(640, 640, P3D);
  frameRate(60);
  colorMode(RGB, 1.0f);

  frustum(-1.0f, 1.0f, 1.0f, -1.0f, 2.0f, 20.0f);
  
  resetMatrix();
  textureMode(NORMAL); // you want this!
  Earth = loadImage("assets/Earth.jpg");
  Moon = loadImage("assets/Moon.jpg");
  UFO = loadImage("assets/UFO.png");
  Eye = loadImage("assets/Eye.png");
  floor1 = loadImage("assets/light.jpg");
  floor2 = loadImage("assets/light1.jpg");
  leftWall = loadImage("assets/night1.png");
  rightWall = loadImage("assets/night2.jpg");
  endRoad = loadImage("assets/Mars.png");

  textureWrap(REPEAT);
  
  Rotator head = new Rotator(new float[]{0,180,0}, new float[]{0,0,0}, new float[]{0,1,0}, 0, -30, 30, 1);
  Rotator rightShoulder = new Rotator(new float[]{0,90,0}, new float[]{0,0,0}, new float[]{1,0,0}, 30, -30, 30, 1);
  Rotator rightElbow = new Rotator(new float[]{0,-90,0}, new float[]{0,0.075f,0}, new float[]{1,0,0}, 30, -30, 30, 1);
  Rotator leftShoulder = new Rotator(new float[]{0,90,0}, new float[]{0,0,0}, new float[]{1,0,0}, -30, -30, 30, 1);
  Rotator leftElbow = new Rotator(new float[]{0,-90,0}, new float[]{0,0.075f,0}, new float[]{1,0,0}, -30, -30, 30, 1);
  Rotator rightThigh = new Rotator(new float[]{90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, -30, -30, 30, 1);
  Rotator rightKnee = new Rotator(new float[]{-90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, 0, 0, 45, 0.75f);
  Rotator leftThigh = new Rotator(new float[]{90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, 30, -30, 30, 1);
  Rotator leftKnee = new Rotator(new float[]{-90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, 45, 0, 45, 0.75f);
  rotators = new Rotator[] {
    head,
    rightShoulder,
    rightElbow,
    leftShoulder,
    leftElbow,
    rightThigh,
    rightKnee,
    leftThigh,
    leftKnee
  };
  robot = new Structure(
            new Shape[] {
              new Shape(new float[] {0.1f,0.15f,0.1f}, head),
              //new Shape("dodecahedron.obj", new float[] {0.2, 0.2, 0.2}, head),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.06f, -0.125f, 0.06f}, rightElbow)},
                  new float[][] {{-0.058f, -0.15f, -0.001f}},
                  new float[] {0.125f, 0.075f, 0.075f}, rightShoulder),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.06f, -0.125f, 0.06f}, leftElbow)},
                  new float[][] {{0.058f, -0.15f, -0.001f}},
                  new float[] {0.125f, 0.075f, 0.075f}, leftShoulder),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.1f, 0.15f, 0.1f}, rightKnee)},
                  new float[][] {{0.0f, -0.3f, 0.0f}},
                  new float[] {0.1f, 0.15f, 0.1f}, rightThigh),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.1f, 0.15f, 0.1f}, leftKnee)},
                  new float[][] {{0.0f, -0.3f, 0.0f}},
                  new float[] {0.1f, 0.15f, 0.1f}, leftThigh)
            }, new float[][] {
              {0, 0.4f, 0 },
              {-0.25f, 0.15f, 0},
              {0.25f, 0.15f, 0},
              {-0.15f, -0.3f, 0 },
              {0.15f, -0.3f, 0 }
            },
            new float[] {0.15f,0.25f,0.15f}, null);
            
            
    alien = loadShape("data/10469_GrayAlien_v01.obj");
}

final float MAX_JUMP = 0.75f;
final float ROAD_BEGIN = -2.0f;
final float ROAD_END = 16f;
final float WALL_H = 4f;
final float OBS_H = 0.5f;
final float SQSIZE = 0.8f;
final float HALF_BODY = 0.3f;

int cameraAngle = 0;

Structure robot;
Rotator[] rotators;
float robotX, robotY, robotZ, currX, currZ, speedX, speedZ, angle, frame;
float cameraX, cameraY;
float obs1_nearZ = 1.2;
float obs2_nearZ = 4.4;
float obs3_nearZ = 7.6;
float obs4_nearZ = 10.8;
float obs5_nearZ = 14;
float obs4X;
float obsSpeedX = 0.015f;
boolean jump, falling, moveL, moveR, hitWall, hitBoxX, hitBoxZ, freeLookOn;
float t = 1;

void draw() {
  background(0.05, 0.05, 0.1);
  fill(1, 0, 0);
  //stroke(1, 1, 1);
  //strokeWeight(5.5);
    noStroke();

  resetMatrix();
  translate(robotX, robotY, robotZ);
  
  resetMatrix();
  if (cameraAngle == 0) {
    // third-person perspective
    translate(0, -1, -3.5);
    rotateX(radians(10));
    rotateY(radians(180));
  } else if (cameraAngle == 1) {
    // first-person perspective
    translate(robotX, -robotY-1, -1.4);     
    rotateX(radians(10));
    rotateY(radians(180));
    
    if (freeLookOn) {
      cameraX = -(mouseY - 320)/8.0f;
      cameraY = (mouseX-320)/8.0f; 
      if (hitWall && moveR) {
        if (cameraY > 5) {
          cameraY = 5;  
        }
      }
      else if (hitWall && moveL) {
        if (cameraY > -5) {
          cameraY = -5;  
        }
      }
      rotateX(radians(cameraX));
      rotateY(radians(cameraY));
    }
  }

  pushMatrix();
  translate(robotX, robotY, 0); 
  robot.draw();
  popMatrix();
  
  speedZ = 0.015f;
  //collison test
  if (robotY < OBS_H) {
    if ( (robotZ > obs1_nearZ  && robotZ < obs1_nearZ+SQSIZE  && robotX < 2-2*SQSIZE+HALF_BODY && robotX > -2+2*SQSIZE-HALF_BODY) ||
         (robotZ > obs2_nearZ  && robotZ < obs2_nearZ+SQSIZE  && robotX < 2+HALF_BODY && robotX > 2-SQSIZE-HALF_BODY) ||
         (robotZ > obs2_nearZ  && robotZ < obs2_nearZ+SQSIZE  && robotX < 2-2*SQSIZE+HALF_BODY && robotX > -2+2*SQSIZE-HALF_BODY) ||
         (robotZ > obs2_nearZ  && robotZ < obs2_nearZ+SQSIZE  && robotX < -2+SQSIZE+HALF_BODY && robotX > -2-HALF_BODY) ||
         (robotZ > obs3_nearZ  && robotZ < obs3_nearZ+SQSIZE  && robotX < 2-2*SQSIZE+HALF_BODY && robotX > -2+2*SQSIZE-HALF_BODY)) {
      if ((jump && robotY + 0.1f > OBS_H) || (falling && robotY + 0.1f > OBS_H)) {
        robotY = OBS_H;
        hitBoxZ = false;
      }
      else {
        hitBoxZ = true;
      }
    }
    else {
      hitBoxZ = false;  
    }
    
    if (( robotZ > obs1_nearZ && robotZ < obs1_nearZ+SQSIZE && 
          ((robotX < 2-2*SQSIZE+HALF_BODY + 0.01f && robotX > 2-2*SQSIZE && moveR) || 
           (robotX < -2+2*SQSIZE-HALF_BODY && robotX > -2+2*SQSIZE-HALF_BODY - 0.01f && moveL) )) 
       || ( robotZ > obs2_nearZ && robotZ < obs2_nearZ+SQSIZE && 
          ((robotX > 2-SQSIZE-HALF_BODY - 0.01f && robotX < 2-SQSIZE-HALF_BODY && moveL) || 
          (robotX < -2+SQSIZE+HALF_BODY + 0.01f && robotX > -2+SQSIZE+HALF_BODY && moveR) ||
           (robotX < 2-2*SQSIZE+HALF_BODY + 0.01f && robotX > 2-2*SQSIZE+HALF_BODY && moveR) ||
           (robotX > -2+2*SQSIZE-HALF_BODY-0.01f && robotX < -2+2*SQSIZE-HALF_BODY && moveL) ))
       || ( robotZ > obs3_nearZ && robotZ < obs3_nearZ+SQSIZE &&
          ((robotX < 2-2*SQSIZE+HALF_BODY + 0.01f && robotX > 2-2*SQSIZE && moveR) || 
           (robotX < -2+2*SQSIZE-HALF_BODY && robotX > -2+2*SQSIZE-HALF_BODY - 0.01f && moveL) )) )
    {
        hitBoxX = true;
    }
    else {
      hitBoxX = false;  
    }
   }
  
  // Robot jump
  if (jump && !falling) {
    if (robotY >= 0.0f && robotY < MAX_JUMP) {
      robotY += 0.015f;
    }
  }
  else {
    robotY -= 0.015f;
    falling = true;
  }
  
  if (robotY < 0) {
    robotY = 0.0f;  
    jump = false;
    falling = false;
  }

  //limit robot jump
  if (robotY > MAX_JUMP) {
    jump = false;  
  }
  
  //Robot's movement on the x-axis
  if ( (robotX > 2.0f-HALF_BODY && moveL) || (robotX < -2+HALF_BODY && moveR) ) {
    hitWall = true; 
  }
  else {
    hitWall = false;  
  }
  
  if (hitWall || hitBoxX) {
    speedX = 0;
  }
  else {
    if (moveL) {
      speedX = 0.015f; 
    }
    else if (moveR) {
      speedX = -0.015f;
    }
  }

  robotX += speedX;
  
  if (hitBoxZ) {
    speedZ = 0;
  }
  else {
    speedZ = 0.015f;
  }

  robotZ += speedZ;

  if ((robotZ > obs4_nearZ  && robotZ < obs4_nearZ+SQSIZE/2.0f  && robotX < 2-2*SQSIZE+HALF_BODY+obs4X && robotX > -2+2*SQSIZE-HALF_BODY+obs4X) ||
      (robotZ > obs5_nearZ  && robotZ < obs5_nearZ+SQSIZE/2.0f  && robotX < 2-2*SQSIZE+HALF_BODY-obs4X && robotX > -2+2*SQSIZE-HALF_BODY-obs4X)) {
    robotX = 0;
    robotZ = ROAD_BEGIN+2f;
    
    println("You were captured by aliens and they sent you to their base on the backside of the Moon");
  }
  
  if (robotZ > ROAD_END) {
    robotX = 0;
    robotZ = ROAD_BEGIN+2f;
    println("Congrats! You made your journey to the Mars.");  
  }
  
  pushMatrix();
  
  translate(0, -0.75f, -robotZ);
  //begin of the road
  drawSurface(2, -2, WALL_H, 0, ROAD_BEGIN, ROAD_BEGIN, endRoad);
  //end of the road
  drawSurface(2, -2, WALL_H, 0, ROAD_END, ROAD_END, endRoad);
  //left wall
  drawSurface(2, 2, WALL_H, 0, -2, ROAD_END, leftWall);
  //right wall
  drawSurface(-2, -2, WALL_H, 0,  -2, ROAD_END, rightWall);

  //obstacles
  drawObject(2-2*SQSIZE, -2+2*SQSIZE, OBS_H, 0, obs1_nearZ, obs1_nearZ+SQSIZE, Moon);
  
  drawObject(2, 2-SQSIZE, OBS_H, 0, obs2_nearZ, obs2_nearZ+SQSIZE, UFO);
  drawObject(2-2*SQSIZE, -2+2*SQSIZE, OBS_H, 0, obs2_nearZ, obs2_nearZ+SQSIZE, Earth);
  drawObject(-2, -2+SQSIZE, OBS_H, 0, obs2_nearZ, obs2_nearZ+SQSIZE, UFO);
  
  drawObject(2-2*SQSIZE, -2+2*SQSIZE, OBS_H, 0, obs3_nearZ, obs3_nearZ+SQSIZE, Eye);

  //Moving obstacle
  if ((obs4X > 2.0f-SQSIZE/2.0f && obsSpeedX > 0) || (obs4X < -2.0f+SQSIZE/2.0f && obsSpeedX < 0)) {
    obsSpeedX = -obsSpeedX;  
  }
  obs4X += obsSpeedX;
  
  pushMatrix();
  translate(obs4X, robotY, obs4_nearZ);
  rotateY(radians((mylerp(frame, 0, -360))));
  rotateY(radians(180));
  rotateX(radians(-90));
  scale(0.02);
  shape(alien, 0, 0);
  rotateX(90);
  //translate(obs4X, 0, 0);
  //drawObject(2-2*SQSIZE, -2+2*SQSIZE, OBS_H, 0, obs4_nearZ, obs4_nearZ+SQSIZE, floor2);
  popMatrix();
  
  pushMatrix();
  translate(-obs4X, robotY, obs5_nearZ);
  rotateY(radians((mylerp(frame, 0, 360))));
  rotateY(radians(180));
  rotateX(radians(-90));
  scale(0.02);
  shape(alien, 0, 0);
  rotateX(90);
  popMatrix();
  
  frame += 0.01f;
  if (frame > 1) {
    frame = 0;  
  }
  
  //floor
  boolean dark = true;
  for (float x = -2; x < 2; x+=SQSIZE) {
    for (float z = -2; z < ROAD_END; z+=SQSIZE) {
      if (dark) {
        beginShape(QUADS);
        texture(floor1);
        vertex(x, 0, z, 0, 1);
        vertex(x+SQSIZE, 0, z, 1, 1);
        vertex(x+SQSIZE, 0, z+SQSIZE, 1, 0);
        vertex(x, 0, z+SQSIZE, 0, 0);
        endShape();
      } else {
        beginShape(QUADS);
        texture(floor2);
        vertex(x, 0, z, 0, 1);
        vertex(x+SQSIZE, 0, z, 1, 1);
        vertex(x+SQSIZE, 0, z+SQSIZE, 1, 0);
        vertex(x, 0, z+SQSIZE, 0, 0);
        endShape();
      }
      dark = !dark;
    }
    //dark = !dark;
  }
  popMatrix();
  
  for (Rotator r: rotators) {
    r.update(1);
  }
}

float mylerp(float t, float a, float b) {
  return (1 - t) * a + t * b;  
}

void drawSurface(float leftX, float rightX, float topY, float botY, float nearZ, float farZ, PImage t) {
  beginShape(QUADS);
  texture(t);
  vertex(leftX, botY, nearZ, 0, 1);
  vertex(rightX, botY, farZ, 1, 1);
  vertex(rightX, topY, farZ, 1, 0);
  vertex(leftX, topY, nearZ, 0, 0);
  endShape();
}

void drawObject(float leftX, float rightX, float topY, float botY, float nearZ, float farZ, PImage t) {
  //top
  beginShape(QUADS);
  texture(t);
  vertex(leftX, topY, nearZ, 0, 1);
  vertex(rightX, topY, nearZ, 1, 1);
  vertex(rightX, topY, farZ, 1, 0);
  vertex(leftX, topY, farZ, 0, 0);
  endShape();
  
  //front
  drawSurface(leftX, rightX, topY, botY, nearZ, nearZ, t);
  //back
  drawSurface(leftX, rightX, topY, botY, farZ, farZ, t);
  //left
  drawSurface(leftX, leftX, topY, botY, nearZ, farZ, t);
  //right
  drawSurface(rightX, rightX, topY, botY, nearZ, farZ, t);
}

void drawUnitCube() {
  float[][] verts = {
      { -1, -1, -1 },  // llr
      { -1, -1, 1 },  // llf
      { -1, 1, -1 },  // lur
      { -1, 1, 1 },  // luf
      { 1, -1, -1 },  // rlr
      { 1, -1, 1 },  // rlf
      { 1, 1, -1 },  // rur
      { 1, 1, 1 }     // ruf
  };
  
  int[][] faces = {
      { 1, 5, 7, 3 }, // front
      { 4, 0, 2, 6 }, // rear
      { 3, 7, 6, 2 }, // top
      { 0, 4, 5, 1 }, // bottom
      { 0, 1, 3, 2 }, // left
      { 5, 4, 6, 7 }, // right
  };
  
  beginShape(QUADS);
  for (int[] face: faces) {
    for (int i: face) {
      vertex(verts[i][0], verts[i][1], verts[i][2]);
    }
  }
  endShape();
}

void mouseClicked() {
  if (cameraAngle == 1) {
      freeLookOn = !freeLookOn;
  }
  else {
    freeLookOn = false;  
  }
}

void keyPressed() {
  if (key == ENTER) {
    cameraAngle++;
    if (cameraAngle == 2) {
      cameraAngle = 0;
    }
  
  }
  if (key == ' ') {
    jump = true;
  } 
  else if (key == 'a') {
    moveL = true;
    moveR = false;
  } 
  else if (key == 'd') {
    moveR = true;
    moveL = false;
  }
}

class Face {
  private int[] indices;
  private float[] colour;

  public Face(int[] indices, float[] colour) {
    this.indices = new int[indices.length];
    this.colour = new float[colour.length];
    System.arraycopy(indices, 0, this.indices, 0, indices.length);
    System.arraycopy(colour, 0, this.colour, 0, colour.length);
  }

  public void draw(ArrayList<float[]> vertices, boolean useColour) {
    if (useColour) {
      if (colour.length == 3)
        fill(colour[0], colour[1], colour[2]);
      else
        fill(colour[0], colour[1], colour[2], colour[3]);
    }

    if (indices.length == 1) {
      beginShape(POINTS);
    } else if (indices.length == 2) {
      beginShape(LINES);
    } else if (indices.length == 3) {
      beginShape(TRIANGLES);
    } else if (indices.length == 4) {
      beginShape(QUADS);
    } else {
      beginShape(POLYGON);
    }

    for (int i: indices) {
      vertex(vertices.get(i)[0], vertices.get(i)[1], vertices.get(i)[2]);
    }

    endShape();
  }
}

class Shape {
  // set this to NULL if you don't want outlines
  public float[] line_colour;

  protected ArrayList<float[]> vertices;
  protected ArrayList<Face> faces;
  
  private float[] scale;
  private Rotator rotator;

  public Shape(float[] scale, Rotator rotator) {
    // you could subclass Shape and override this with your own
    init(scale, rotator);

    // default shape: cube
    vertices.add(new float[] { -1.0f, -1.0f, 1.0f });
    vertices.add(new float[] { 1.0f, -1.0f, 1.0f });
    vertices.add(new float[] { 1.0f, 1.0f, 1.0f });
    vertices.add(new float[] { -1.0f, 1.0f, 1.0f });
    vertices.add(new float[] { -1.0f, -1.0f, -1.0f });
    vertices.add(new float[] { 1.0f, -1.0f, -1.0f });
    vertices.add(new float[] { 1.0f, 1.0f, -1.0f });
    vertices.add(new float[] { -1.0f, 1.0f, -1.0f });

    faces.add(new Face(new int[] { 0, 1, 2, 3 }, new float[] { 1.0f, 0.0f, 0.0f } ));
    faces.add(new Face(new int[] { 0, 3, 7, 4 }, new float[] { 1.0f, 1.0f, 0.0f } ));
    faces.add(new Face(new int[] { 7, 6, 5, 4 }, new float[] { 1.0f, 0.0f, 1.0f } ));
    faces.add(new Face(new int[] { 2, 1, 5, 6 }, new float[] { 0.0f, 1.0f, 0.0f } ));
    faces.add(new Face(new int[] { 3, 2, 6, 7 }, new float[] { 0.0f, 0.0f, 1.0f } ));
    faces.add(new Face(new int[] { 1, 0, 4, 5 }, new float[] { 0.0f, 1.0f, 1.0f } ));
  }

  protected void init(float[] scale, Rotator rotator) {
    vertices = new ArrayList<float[]>();
    faces = new ArrayList<Face>();

    line_colour = new float[] { 1,1,1 };
    if (null == scale) {
      this.scale = new float[] { 1,1,1 };
    } else {
      this.scale = new float[] { scale[0], scale[1], scale[2] };
    }
    
    this.rotator = rotator;
  }

  public void rotate() {
    if (rotator != null) {
      translate(rotator.origin[0], rotator.origin[1], rotator.origin[2]);
      if (rotator.axis[0] > 0)
        rotateX(radians(rotator.angle));
      else if (rotator.axis[1] > 0)
        rotateY(radians(rotator.angle));
      else
        rotateZ(radians(rotator.angle));
      translate(-rotator.origin[0], -rotator.origin[1], -rotator.origin[2]);
    }
  }
  
  public void draw() {
    pushMatrix();
    scale(scale[0], scale[1], scale[2]);
    if (rotator != null && rotator.orientation != null) {
      rotateX(radians(rotator.orientation[0]));
      rotateY(radians(rotator.orientation[1]));
      rotateZ(radians(rotator.orientation[2]));
    }
    for (Face f: faces) {
      if (line_colour == null) {
        noStroke();
        f.draw(vertices, true);
      } else {
        stroke(line_colour[0], line_colour[1], line_colour[2]);
        f.draw(vertices, true);
      }
    }
    popMatrix();
  }
}

class Structure extends Shape {
  // this array can include other structures...
  private Shape[] contents;
  private float[][] positions;

  public Structure(Shape[] contents, float[][] positions, float[] scale, Rotator rotator) {
    super(scale, rotator);
    init(contents, positions);
  }

  private void init(Shape[] contents, float[][] positions) {
    this.contents = new Shape[contents.length];
    this.positions = new float[positions.length][3];
    System.arraycopy(contents, 0, this.contents, 0, contents.length);
    for (int i = 0; i < positions.length; i++) {
      System.arraycopy(positions[i], 0, this.positions[i], 0, 3);
    }
  }

  public void draw() {
    super.draw();
    for (int i = 0; i < contents.length; i++) {
      pushMatrix();
      translate(positions[i][0], positions[i][1], positions[i][2]);
      contents[i].rotate();
      contents[i].draw();
      popMatrix();
    }
  }
}

class Rotator {
  public float[] orientation;
  public float[] origin;
  public float[] axis;
  public float angle, startAngle, endAngle, vAngle;
  boolean up;
  
  public Rotator(float[] orientation, float[] origin, float[] axis, float angle, float startAngle, float endAngle, float vAngle) {
    this.orientation = new float[] {orientation[0], orientation[1], orientation[2]};
    this.origin = new float[] {origin[0], origin[1], origin[2]};
    this.axis = new float[] {axis[0], axis[1], axis[2]};
    this.angle = angle;
    this.startAngle = startAngle;
    this.endAngle = endAngle;
    this.vAngle = vAngle;
    this.up = true;
  }
  
  public void update(float elapsed) {
    if (up) {
      angle += elapsed * vAngle;
      if (angle > endAngle) {
        angle = endAngle - Math.abs(angle - endAngle);
        up = false;
      }
    } else {
      angle -= elapsed * vAngle;
      if (angle < startAngle) {
        angle = startAngle + Math.abs(angle - startAngle);
        up = true;
      }
    }
  }
}
