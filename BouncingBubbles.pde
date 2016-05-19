/**
 * Main of space bubbles game.
 */
EntityWorld world;
ArrayList<Ship> ships = new ArrayList<Ship>();
StdioShipController player1; // Need a reference to a singular human player
StatusBar bar;

void setup() {
  println("In setup()");
  size(680, 620);
  frameRate(20);
  PFont font = createFont("Bitstream Vera Sans Mono Bold", 32);
  textFont(font, 14);
  //noLoop();
  setupSystem();
  //testGetHood();
}

void setupSystem() {
  world = new EntityWorld(width, height-20, 40);
  // Init bubbles.  
  for(int i = 0; i < 20; i++) {
    Bubble e = new Bubble(
      new PVector(random(0,width-1), random(0,height-20)),
      PVector.random2D().mult(2.0),
      random(5,world.binSize/2.01)
    );
    world.add(e);
  }
  // Init ships.
  Ship s = new Ship(
    new PVector(width/2, width/2),
    new PVector(0,0),
    world
  );
  player1 = new StdioShipController(s);
  world.add(s);
  ships.add(s);
  bar = new StatusBar(world, ships);
}

void draw() {
  //println("In draw() " + world.size());
  colorMode(RGB, 255);
  background(255);
  fill(255);
  stroke(0, 0, 0);
  strokeWeight(1.2);
  world.draw();
  bar.draw();
}

/**
 * I know no otherway to hook the event.
 */
void keyPressed() {
  player1.keyPressed();
}