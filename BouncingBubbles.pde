/**
 * Bounce Bubbles.
 */
 
EntityWorld world;

void setup() {
  println("In setup()");
  size(820, 800);
  frameRate(20);
  PFont font = createFont("Bitstream Vera Sans Mono Bold", 32);
  textFont(font, 14);
  //noLoop();
  setupSystem();
}

void setupSystem() {
  
  world = new EntityWorld(width, height, 40);
  /*
  println(world.wBins + " " + world.binSize);
  Entity et = new Entity(
      new PVector(809,40),
      PVector.random2D().mult(2.0),
      new PVector(random(2,20), random(2,20))
  );  
  println(world.getKey(et));
  println(world.keyToArray(world.getKey(et))[0] + ", " + world.keyToArray(world.getKey(et))[1]);
  exit();
  */
  for(int i = 0; i < 100; i++) {
    Entity e = new Entity(
      new PVector(random(0,width-1), random(0,height)),
      PVector.random2D().mult(2.0),
      new PVector(random(2,world.binSize), random(2,world.binSize))
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