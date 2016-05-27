/**
 * Main entry point for Space Bubbles 9000 game. Configures a game then runs it until end.
 * All game entites are kept in the EntityWorld data structures.
 */
final int maxTurns = 1000;
/** These ints are type identifiers to ship types and or configs. */
final int stdioShip = 0;
final int trainedShip = 1;
final int neuralShip = 2;
final int evoNeuralShip = 3;
final int trainedEvoNeuralShip = 4;
/** Arrangement of ships. Note you can't have trainedShip without stdioShio  */
//final int[] shipConfig = {stdioShip, trainedShip};
//final int[] shipConfig = {neuralShip, neuralShip, trainedEvoNeuralShip};
//final int[] shipConfig = {neuralShip, evoNeuralShip, neuralShip, evoNeuralShip, neuralShip, evoNeuralShip};
final int[] shipConfig = {stdioShip, neuralShip, trainedEvoNeuralShip, neuralShip, trainedEvoNeuralShip};
final int numBubbles = 20; /** Starting number of bubble */
final int additionalHeight = (shipConfig.length+1)*20;
final int _width = 720;
final int _height = _width;
final int binSize = 40;
final File evoConfigFile = new File("/tmp/config-pool.json"); /** Input file used by EvolutionaryNeuralShipController. Only used in training */
final File evoResultFile = new File("/tmp/result-pool.json"); /** Output file used by EvolutionaryNeuralShipController. Only used in training */
/** These files represent read only configs that are the results of training */
final String neuralConfigFile1 = "OnlineNeuralShipControllerConfig.json"; /** File holds a set of trained neuron weights. */
final String neuralConfigFile2 = "EvoNeuralShipControllerConfig.json"; /** File holds a set of trained neuron weights. */

EntityWorld world;
ArrayList<ShipController> shipControllers = new ArrayList<ShipController>();
ArrayList<Ship> ships = new ArrayList<Ship>(); 
StdioShipController player = null; 
StatusBar bar;
int turn = 0;
boolean gameOver = false;

void setup() {
  println("In setup()");
  size(720,840); // Should be size(_width, _height+additionalHeight). Non literals not allowed. 800 = 3 ships.
  frameRate(20);
  PFont font = createFont("Bitstream Vera Sans Mono Bold", 32);
  textFont(font, 14);
  setupSystem();
}

/**
 * Set up the world.
 */
void setupSystem() {
  world = new EntityWorld(_width, _height, binSize);
  // Init bubbles.  
  seedRandomBubbles(numBubbles);
  // Init ships.
  PVector shipPosition = new PVector(width*0.3, 0);
  for(int i = 0; i < shipConfig.length; i++) {
    int shipType = shipConfig[i];
    shipPosition.rotate((PI*2.0)*(1.0/shipConfig.length));
    Ship s = new Ship((new PVector(width/2, height/2)).add(shipPosition), new PVector(0,0), world);
    world.add(s);
    ships.add(s);
    switch(shipType) {
      case stdioShip: { 
        println("Add human player.");
        player = new StdioShipController(s);
        shipControllers.add(player);
        player.begin();
        break;
      }
      case trainedShip: {
        println("Add computer player. Attach human trainer.");
        ShipController controller = new OnlineNeuralShipController(s, world, player, true);
        shipControllers.add(controller);
        controller.begin();
        break;
      }
      case neuralShip: {
        println("Add computer player.");
        NeuralShipController controller = new NeuralShipController(s, world);
        setWeights(controller, neuralConfigFile1);
        shipControllers.add(controller);
        controller.begin();
        s.myColour = #44FF00;
        break;
      }
      case trainedEvoNeuralShip: {
        println("Add computer player.");
        NeuralShipController controller = new NeuralShipController(s, world);
        shipControllers.add(controller);
        setWeights(controller, neuralConfigFile2);
        controller.begin();
        s.myColour = #FF22BB;
        break;
      }
      case evoNeuralShip: {
        println("Add computer player.");
        EvolutionaryNeuralShipController controller = new EvolutionaryNeuralShipController(s, world, evoConfigFile, evoResultFile);
        shipControllers.add(controller);
        controller.begin();
        break;
      }
    }
  }
  // Status bar.
  bar = new StatusBar(world, shipControllers, maxTurns);
}

/**
 * Set weights of NeuralShipController from some predefined JSON resource.
 * The resource must be in the data/ dir. In fact Processing will check "the sketches dir" too..
 * If can't be loaded dont fail. Assignment will be random.
 */
void setWeights(NeuralShipController c, String jsonResource) {
  println("Loading from " + jsonResource);
  try {
    JSONArray jsonArray = loadJSONArray(jsonResource);
    c.setWeights(jsonArray.getFloatArray());
  }
  catch(Exception e) {
    println("Could not load neuron weights resource. Ship will be random.");
  }
}

/**
 * Randomly place `n` new bubbbles in the world.
 */
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
  if(maxTurns == turn++ || world.countClass(Ship.class) == 0) {
    end();
    return;
  }
  else if(gameOver) {
    doExit();
  }
  for(ShipController c : shipControllers) {
    if(c.ship.isLive())
      c.turn(turn);
  }
  if(world.countClass(Bubble.class) < shipConfig.length+numBubbles-10) {
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
  gameOver = true;
}

void doExit() {
  try {
      Thread.sleep(5000);                 //1000 milliseconds is one second.
  } catch(InterruptedException ex) {
      Thread.currentThread().interrupt();
  }
  System.exit(0);
}

/**
 * Draw "Game Over".
 */
void drawGameOver() {
  textAlign(CENTER);
  rectMode(CENTER);  // Set rectMode to CENTER
  fill(#FFFFFF);
  rect(width/2, height/2, 150, 50);
  fill(#000000);
  text("Game Over", width/2, height/2);
}

/**
 * Send events to controller. Hack. I know no other way to hook these events..
 */
void keyPressed() {
  if(player != null) {
    StdioShipController ioShip =(StdioShipController)shipControllers.get(0);
    ioShip.keyPressed();
  }
}