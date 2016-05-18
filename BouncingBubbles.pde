/**
 * Bounce Bubbles.
 */
 
EntityWorld world;

void setup() {
  println("In setup()");
  size(400, 400);
  frameRate(20);
  PFont font = createFont("Bitstream Vera Sans Mono Bold", 32);
  textFont(font, 14);
  //noLoop();
  setupSystem();
  //testGetHood();
}

void setupSystem() {
  world = new EntityWorld(width, height, 40);
  for(int i = 0; i < 20; i++) {
    Entity e = new Entity(
      new PVector(random(0,width-1), random(0,height)),
      PVector.random2D().mult(2.0),
      random(5,world.binSize/2.01)
    );
    world.add(e);
  }
}

void draw() {
  println("In draw()");
  background(255);
  fill(255);
  stroke(0, 0, 0);
  strokeWeight(1.2);
  world.draw();
}