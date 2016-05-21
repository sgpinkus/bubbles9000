/**
 * Main of space bubbles game.
 */
final int maxTurns = 6000;
final boolean stdioShip = true;
final boolean trainShip = true;
final int numShips = 2;
final int numBubbles = 20;
final int additionalHeight = (numShips+1)*20;
final int _width = 720;
final int _height = _width;
final int binSize = 40;
EntityWorld world;
ArrayList<ShipController> shipControllers = new ArrayList<ShipController>();
ArrayList<Ship> ships = new ArrayList<Ship>(); 
StdioShipController player = null; 
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
  seedRandomBubbles(numBubbles);
  // Init ships.
  PVector shipPosition = new PVector(width*0.3, 0);
  for(int i = 0; i < numShips; i++) {
    shipPosition.rotate((PI*2.0)*(1.0/numShips));
    Ship s = new Ship((new PVector(width/2, height/2)).add(shipPosition), new PVector(0,0), world);
    world.add(s);
    ships.add(s);
    if(stdioShip && shipControllers.size() == 0) {
      println("Add human player.");
      player = new StdioShipController(s);
      shipControllers.add(player);
      player.begin();
    }
    else if(stdioShip && trainShip && shipControllers.size() == 1) {
      println("Add computer player. Attach human trainer.");
      ShipController controller = new OnlineNeuralShipController(s, world, player);
      shipControllers.add(controller);
      controller.begin();
    }
    else {
      println("Add computer player.");
      ShipController controller = new NeuralShipController(s, world);
      shipControllers.add(controller);
      controller.begin();
    }
  }
  // Status bar.
  bar = new StatusBar(world, ships, maxTurns);
}

void seedRandomBubbles(int n) {
  for(int i = 0; i < n; i++) {
    Bubble e = new Bubble(
      new PVector(random(0,_width-1), random(0,_height-1)),
      PVector.random2D().mult(2.0),
      random(10,world.binSize/2.01)
    );
    world.add(e);
  }
}

/**
 * Tick the world.
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
  if(world.countClass(Bubble.class) < numShips+numBubbles-10) {
    seedRandomBubbles((int)random(1,10));
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