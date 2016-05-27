/**
 * Abstract ShipControllers and all sub classes.
 * Keeping all sub classes here to make them easier to navigate in Processing IDE.
 */
import perceptrons.*;
import java.io.*;
import java.util.*;
import java.nio.channels.*;


/**
 * A ship controller. The game should init one of these for every ship.
 * The game should ask the controller to move it's ship each turn before updating the world.
 */
abstract class ShipController
{
   public Ship ship;
   
   ShipController(Ship ship) {
     this.ship = ship;
   }
   
   /** 
    * Called each turn.
    */
   public abstract void turn(int turn);
   
   /** 
    * Called when game begins.
    */
   public void begin() {
   }
   
   /** 
    * Called when game ends so controller can do clean up or what not.
    */
   public void end() {
   }   
}

/**
 * Controls a ship purely randomly.
 */
class RandomShipController extends ShipController
{
  RandomShipController(Ship ship) {
    super(ship);
    ship.myColour = #FF0000;
  }

  /**
   * @override
   */
  void turn(int turn) {
    float fire = random(0,1);
    float direction = random(0,1); 
    if(fire > 0.8) {
      ship.fireProjectile();
    }
    if(direction <= 0.1) {
      ship.steerLeft();
    }
    else if(direction <= 0.2) {
      ship.steerRight();
    }
    else if(direction <= 0.4) {
      ship.applyThrust();
    }
  }
}

/**
 * Controls a ship by listening to mysterious key press events. Suprisingly effective.
 * Processing queues up all events and send them to you after (why after...) each draw().
 * So we latch key presses and only send them through to our ship on turn.
 */
class StdioShipController extends ShipController
{
  boolean fire = false;
  boolean left = false;
  boolean right = false;
  boolean thrust = false;
  float[] lastTurn = new float[4];
  
  StdioShipController(Ship ship) {
    super(ship);
    ship.myColour = #0000FF;
  }
  
  /**
   * @override
   */
  void turn(int turn) {
    if(fire) {
      ship.fireProjectile();
    }
    if(left) {
      ship.steerLeft();
    }
    if(right) {
      ship.steerRight();
    }
    if(thrust) {
      ship.applyThrust();
    }
    lastTurn[0] = fire ? 1.0 : 0.0;
    lastTurn[1] = left ? 1.0 : 0.0;
    lastTurn[2] = right ? 1.0 : 0.0;
    lastTurn[3] = thrust ? 1.0 : 0.0;
    //if(turn%10==0){ printPercept(); }
    fire = left = right = thrust = false;
  }
  
  float[] getLastTurn() {
    return lastTurn;
  }
  
  private void printPercept() {
    float[] in = ship.getPercept();
    System.out.format("[%.2f,%.2f,%.2f,%.2f], [%.2f,%.2f,%.2f,%.2f]\n", in[0], in[1], in[2], in[3], lastTurn[0], lastTurn[1], lastTurn[2], lastTurn[3]); 
  }

  /** 
   * key press handler. Must be hooked up to key presses.
   */
  void keyPressed() {
    if(key == ' ') {
      fire = true;
    }
    if(keyCode == LEFT) {
      left = true;
      right = thrust = false;
    }
    if(keyCode == RIGHT) {
      right = true;
      left = thrust = false;
    }
    if(keyCode == UP) {
      thrust = true;
      left = right = false;
    }
  }
}

/**
 * Controls a ship using a neural network.
 * This controller also derives the inputs to the neural network from the world state.
 * The full world state is too complex, so we reduce it to 4 inputs:
 *  - Distance, heading offset to closest other ship.
 *  - Distance, heading offset to closest bubble.
 * All inputs are floats with a range [-1.0,1.0].
 * The controller will read its neurons config from a file and write the results to file. 
 * The config and results are stored in a serialized JAva data structure.
 * This data structure can be used in.
 */
class NeuralShipController extends ShipController
{
  public final float threshold = 0.0;
  protected EntityWorld world; /** Require a world to generate percept. */
  protected PerceptronNetwork nn;

  NeuralShipController(Ship ship, EntityWorld world) {
    super(ship);
    this.world = world;
    nn = new PerceptronNetwork(4,4, new Perceptron.Sign(), 0.01f);
    ship.myColour = #FF0000;
  }
  
  /**
   * Configure neural network.
   */
  void setWeights(float[] weights) {
    nn.setWeights(weights);
  }
  
  /**
   * Get outputs from NN and apply them to controls.
   * Order must match the training data order. Should be: <fire, left, right, thrust>
   * @override
   */
  void turn(int turn) {
    float[] outputs = nn.value(ship.getPercept());
    if(outputs[0] >= threshold) {
      ship.fireProjectile();      
    }
    if(outputs[1] >= threshold) {
      ship.steerLeft();
    }
    if(outputs[2] >= threshold) {
      ship.steerRight();
    }
    if(outputs[3] >= threshold) {
      ship.applyThrust();
    }
  }
}

/**
 * Listens to the input of a StdioShipController.  
 * Uses that to do online supervised training on a NeuralShipController.
 */
class OnlineNeuralShipController extends NeuralShipController
{
  public final File configFile = new File("OnlineNeuralShipControllerConfig.json");
  protected StdioShipController trainer;
  public boolean persistent = true;
  
  OnlineNeuralShipController(Ship ship, EntityWorld world, StdioShipController trainer, boolean persistent) {
    super(ship, world);
    this.trainer = trainer;
    this.persistent = persistent;
    ship.myColour = #FFFF00;
    float[] config = loadConfig();
    if(config != null) {
      println("Found config for OnlineNeuralShipController. Assigning.");
      nn.setWeights(config);
    }
    else {
      println("No history for OnlineNeuralShipController. Random assignment.");
    }
  }
  
  void end() {
    if(persistent) {
      saveConfig();
    }
  }
  
  /**
   * Ask the trainer what it did under its conditions and inform our neural ship.
   * @override
   */
  void turn(int turn) {
    if(turn%2 == 0 && trainer.ship.isLive()) {
      float[] percept = trainer.ship.getPercept();
      float[] output = trainer.getLastTurn();
      //trainer.printPercept(percept, output);
      nn.train(percept, output);
    }
    super.turn(turn);
  }
  
  /**
   * Attempt to load. If fail don't throw just give msg.
   */
  float[] loadConfig() { 
    float[] config = null;
    try {
      JSONArray configJson = loadJSONArray(configFile.getAbsolutePath());
      config = configJson.getFloatArray();
    }
    catch(Exception e) {
      println("Could not load config");
    }
    return config;
  }
  
  /**
   * Attempt to save configuration as JSON.
   * Processing says its saves studd "in the sketches directory" where ever that is.
   * Appears to be /home/sam/local/processing-3.0.2/
   */
  void saveConfig() {
    JSONArray config = new JSONArray();
    float[] weights = nn.getWeights();
    for(int i = 0; i < weights.length; i++) {
      config.setFloat(i, weights[i]);
    }
    saveJSONArray(config, configFile.getAbsolutePath());
  }
}

/**
 * This ShipController does not actually do evolutionary imrpovement. 
 * That is done offline. This ship loads a config, uses it, and reports the result to a pool to be used in evolution.
 */
class EvolutionaryNeuralShipController extends NeuralShipController
{
  private File configFile;
  private File resultFile;
  private int configId = 0;
  float[] config;
  
  /**
   * Read in a configuration from a persistent list of configurations.
   * In doing so tell that persistent storage that we have read one. 
   * Require exclusive lock on persistent list to R/W.
   */
  EvolutionaryNeuralShipController(Ship ship, EntityWorld world, File configFile, File resultsFile) {
    super(ship, world);
    this.configFile = configFile;
    this.resultFile = resultsFile;
    loadConfig();
    nn.setWeights(config);
    ship.myColour = #FF8800;
  }
  
  void begin() {
  }
  
  void end() {
    storeResult(nn.getWeights(), configId, ship.score);
  }
  
  /**
   * Load an array of neural net weights from persistent storage.
   * Instance properties `config` and `configId` will be set after calling this method.
   * { configs: [ { config: [[]], configId: <int>, score: <float>, runs: <int> } ], index: <int> }
   */
  void loadConfig() {
    println("Loading config from " + configFile.getAbsolutePath());
    FileLock fl = getLock(configFile);
    JSONObject obj = null;
    if(!(configFile.length() > 0)) {
      obj = initializeConfigs();
    }
    else {
      obj = loadJSONObject(configFile.getAbsolutePath());
    }
    int pointer = obj.getInt("index");
    JSONArray configs = obj.getJSONArray("configs");
    JSONObject config = configs.getJSONObject(pointer);
    obj.setInt("index", (pointer+1)%configs.size());
    saveJSONObject(obj, configFile.getAbsolutePath());
    try {
      fl.release();
    }
    catch(Exception e) {
      throw new RuntimeException("I give up");
    }
    configId = pointer;
    this.config = config.getJSONArray("config").getFloatArray(); 
  }
  
  /**
   * Randomly initialize an array of arrays of floats.
   */
  JSONObject initializeConfigs() {
    JSONObject obj = new JSONObject();
    JSONArray configs = new JSONArray();
    for(int i = 0; i < 5; i++) {
      JSONObject configObject = new JSONObject();
      JSONArray configArray = new JSONArray();
      for(int j = 0; j < nn.nWeights; j++) {
        configArray.setFloat(j,random(-1.0, 1.0));
      }
      configObject.setJSONArray("config", configArray);
      configObject.setInt("configId", i);
      configObject.setDouble("score", 0.0f);
      configObject.setInt("runs", 0);
      configs.setJSONObject(configs.size(), configObject);
    }
    obj.setInt("index",0);
    obj.setJSONArray("configs",configs);
    return obj;
  }
  
  /**
   * Store the config and score pair.
   * If an existing result pool DNE create it.s
   */
  void storeResult(float[] config, int configId, float score) {
    println("Saving results list to " + resultFile.getAbsolutePath());
    FileLock fl = getLock(resultFile);
    
    // Load list.
    JSONArray arr = null;
    JSONObject obj;
    if(resultFile.length() > 0) {
      obj = loadJSONObject(resultFile.getAbsolutePath());
      arr = obj.getJSONArray("configs");
    }
    else {
      obj = new JSONObject();
      arr = new JSONArray();
      obj.setJSONArray("configs", arr);
      obj.setInt("index", 0);
    }
    
    // Buld config object
    JSONObject result = findJsonConfig(arr, configId);
    JSONArray configJson = new JSONArray();
    for(int i = 0; i < config.length; i++) {
      configJson.setFloat(i,config[i]);
    }
    result.setJSONArray("config", configJson);
    result.setInt("configId", configId);
    result.setFloat("score", score);
    
    // Save result.
    saveJSONObject(obj, resultFile.getAbsolutePath());
    try {
      fl.release();
    }
    catch(Exception e) {
      throw new RuntimeException("I give up");
    }
  }
  
  JSONObject findJsonConfig(JSONArray arr, int id) {
    JSONObject result = null;
    /*for(int i = 0; i< arr.size(); i++) {
      JSONObject next = arr.getJSONObject(i);
      if(next.getInt("configId") == id) {
        result = next;
      }
    }*/
    if(result == null) {
      result = new JSONObject();
      arr.setJSONObject(arr.size(),result);
    }
    return result;
  }
  
  /**
   * Wrapper to lock some file, hide all the try catch BS.
   */
  FileLock getLock(File file) {
    FileOutputStream fos = null;
    FileLock fl = null;
    try {
      fos = new FileOutputStream(file, true);
    }
    catch(Exception e) {
      throw new RuntimeException(String.format("Could not open data file '%s'", file));
    }
    try {
      fl = fos.getChannel().lock();
    }
    catch(Exception e) {
      throw new RuntimeException(String.format("Could not lock data file '%s': '%s'", configFile.getAbsolutePath(), e.getMessage()));
    }
    return fl;
  }
}