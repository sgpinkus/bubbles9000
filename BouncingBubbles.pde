/**
 * Main of space bubbles game.
 */
final int maxTurns = 600;
final boolean stdioShip = true;
final int totalShips = 3;
final int additionalHeight = (totalShips+1)*20;
final int _width = 720;
final int _height = _width;
final int binSize = 40;
EntityWorld world;
ArrayList<ShipController> shipControllers = new ArrayList<ShipController>();
ArrayList<Ship> ships = new ArrayList<Ship>(); 
StatusBar bar;
int turn = 0;

void setup() {
  println("In setup()");
  size(720, 800); // When processing is better size(_width, _height)
  frameRate(20);
  PFont font = createFont("Bitstream Vera Sans Mono Bold", 32);
  textFont(font, 14);
  //noLoop();
  setupSystem();
  //testGetHood();
}

void setupSystem() {
  world = new EntityWorld(_width, _height, binSize);
  // Init bubbles.  
  for(int i = 0; i < 20; i++) {
    Bubble e = new Bubble(
      new PVector(random(0,width-1), random(0,height-20)),
      PVector.random2D().mult(2.0),
      random(10,world.binSize/2.01)
    );
    world.add(e);
  }
  // Init ships.
  PVector shipPosition = new PVector(width*0.3, width*0.3);
  for(int i = 0; i < totalShips; i++) {
    shipPosition.rotate((PI*2)*(i/totalShips));
    Ship s = new Ship((new PVector(width/2, height/2)).add(shipPosition), new PVector(0,0), world);
    ShipController controller;
    world.add(s);
    ships.add(s);
    if(stdioShip && shipControllers.size() == 0) {
      controller = new StdioShipController(s);
    }
    else {
      controller = new RandomShipController(s);
    }
    shipControllers.add(controller);
    controller.begin();
  }
  // Status bar.
  bar = new StatusBar(world, ships, maxTurns);
}

/**
 * Draw. Or rather tick the world.
 */
void draw() {
  if(maxTurns == turn++) {
    end();
    return;
  }
  for(ShipController c : shipControllers) {
    if(c.ship.isLive())
      c.turn(turn);
  }
  world.update();
  colorMode(RGB, 255);
  background(255);
  fill(255);
  stroke(0, 0, 0);
  strokeWeight(1.2);
  world.draw();
  bar.draw(turn); 
}

/**
 * Finish up.
 * Display game over and tell ship controllers game is over so they can do things like write stats.
 */
void end() {
  for(ShipController c : shipControllers) {
    c.end();
  }
  drawGameOver();
  noLoop();
}

void drawGameOver() {
  textAlign(CENTER);
  rectMode(CENTER);  // Set rectMode to CENTER
  fill(#FFFFFF);
  rect(width/2, height/2, 150, 50);
  fill(#000000);
  text("Game Over", width/2, height/2);
}


/**
 * Hack. I know no other way to hook these events..
 */
void keyPressed() {
  if(stdioShip) {
    StdioShipController ioShip =(StdioShipController)shipControllers.get(0);
    ioShip.keyPressed();
  }
}