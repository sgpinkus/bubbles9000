import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import java.util.*; 
import perceptrons.*; 
import java.io.*; 
import java.util.*; 
import java.nio.channels.*; 

import perceptrons.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Bubbles9000 extends PApplet {

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

public void setup() {
  println("In setup()");
   // Should be size(_width, _height+additionalHeight). Non literals not allowed. 800 = 3 ships.
  frameRate(20);
  PFont font = createFont("Bitstream Vera Sans Mono Bold", 32);
  textFont(font, 14);
  setupSystem();
}

/**
 * Set up the world.
 */
public void setupSystem() {
  world = new EntityWorld(_width, _height, binSize);
  // Init bubbles.  
  seedRandomBubbles(numBubbles);
  // Init ships.
  PVector shipPosition = new PVector(width*0.3f, 0);
  for(int i = 0; i < shipConfig.length; i++) {
    int shipType = shipConfig[i];
    shipPosition.rotate((PI*2.0f)*(1.0f/shipConfig.length));
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
        s.myColour = 0xff44FF00;
        break;
      }
      case trainedEvoNeuralShip: {
        println("Add computer player.");
        NeuralShipController controller = new NeuralShipController(s, world);
        shipControllers.add(controller);
        setWeights(controller, neuralConfigFile2);
        controller.begin();
        s.myColour = 0xffFF22BB;
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
public void setWeights(NeuralShipController c, String jsonResource) {
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
public void seedRandomBubbles(int n) {
  for(int i = 0; i < n; i++) {
    Bubble e = new Bubble(
      new PVector(random(0,_width-1), random(0,_height-1)),
      PVector.random2D().mult(2.0f),
      random(10,world.binSize/2.01f)
    );
    world.add(e);
  }
}

/**
 * Tick the world.
 */
public void draw() {
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
  strokeWeight(1.2f);
  world.draw();
  bar.draw(turn); 
}

/**
 * Finish up.
 * Display game over and tell ship controllers game is over so they can do things like write stats.
 */
public void end() {
  for(ShipController c : shipControllers) {
    c.end();
  }
  drawGameOver();
  gameOver = true;
}

public void doExit() {
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
public void drawGameOver() {
  textAlign(CENTER);
  rectMode(CENTER);  // Set rectMode to CENTER
  fill(0xffFFFFFF);
  rect(width/2, height/2, 150, 50);
  fill(0xff000000);
  text("Game Over", width/2, height/2);
}

/**
 * Send events to controller. Hack. I know no other way to hook these events..
 */
public void keyPressed() {
  if(player != null) {
    StdioShipController ioShip =(StdioShipController)shipControllers.get(0);
    ioShip.keyPressed();
  }
}
/**
 * A bubble entity.
 * These just bounce around until popped.
 */
class Bubble extends Entity
{
  final float minRadius = 10.0f;
  final float maxRadius = 40.0f;
  float hue = random(50,100);
  PImage bubbleImage = loadImage("bubble100x100.png");
  
  public Bubble(PVector loc, PVector vel, float r) {
    super(loc, vel, r);
    r = max(min(r, maxRadius), minRadius); // Silently constraint r.
    setHealth((int)((r-minRadius)/(maxRadius-minRadius)*getHealth()));
  }
  
  public void draw() {
    pushMatrix();
    colorMode(HSB, 100);
    imageMode(CENTER);
    fill(hue, hue, hue, 20);
    stroke(hue, hue, hue, 20);
    strokeWeight(0);
    image(bubbleImage, loc.x, loc.y, r*2, r*2);
    ellipse(loc.x, loc.y, r*2, r*2);
    popMatrix();
  }
  
  /**
   * Process impact of collision on this bubble.
   * @todo account for force.
   */
  public void collision(Entity e, PVector closing) {
    if(e.isMassive()) {
      addHealth(-10); 
    }
  }
  
  /**
   * Health and radius a correlated, so we need to adjust radius to reflect health.
   */
  public void addHealth(int fruit) {
    super.addHealth(fruit);
    radiusHealth();
  }
  
  public void radiusHealth() {
    r = map(getHealth(), 0, 100, minRadius, maxRadius);
  }
}
/**
 * The ghost of a ship that has just beed killed.
 */
class DeadShip extends Entity
{
  private final int deathHealth = 15;
  private PVector heading = new PVector(0,1); /** Heading */
  
  public DeadShip(PVector loc, PVector vel, PVector heading) {
    super(loc, vel, 7.0f); 
    this.heading = heading;
    setHealth(deathHealth);
  }
  
  public void update() {
    super.update();
  }
  
  /**
   * Draw fade away to white.
   */
  public void draw() {
    float greyness = 128.0f+(128.0f*(1.0f-getHealth()/(float)deathHealth));  
    pushMatrix();
    colorMode(RGB, 255);
    translate(loc.x,loc.y);
    rotate(-heading.heading());
    fill(greyness);
    stroke(greyness);
    triangle(-r, -r, r*1.5f, 0, -r, r);
    popMatrix();
    addHealth(-1);
  }
  
  /**
   * Do collision. Collision hurt least if your pointing at the thing you hit. Allows for ramming.
   */
  public void collision(Entity e, PVector closing) {
  }
  
  public boolean isMassive() {
    return false;
  }
}


/**
 * A thing in the world. Has position, velocity, and a bounding box. Can also draw itself.
 * Also encapsulates concept of health, aliveness and, massiveness. Athough not relevant to all entities common to many.
 */
abstract class Entity extends Observable
{
  /** Every object has a unique id. This helps to totally order them */
  public int id;
  /** The of this Entity */
  public PVector loc = new PVector();
  /** The current velocity */
  public PVector vel = new PVector();
  /** Everything is circular and has a bound radius. Make thing simple */
  protected float r;
  /** Health. */
  private int health = 100;
  
  /**
   * New entity at locaction `loc`, with velocity `vel`, and radius `r`.
   */
  public Entity(PVector loc, PVector vel, float r) {
    this.loc = loc;
    this.vel = vel;
    this.r = r;
    this.id = (new Random()).nextInt(Integer.MAX_VALUE/2-1)+1;
  }
  
  /** 
   * Draw.
   */
  public abstract void draw();
  
  /** 
   * Handle collision with another object, `e`.
   * Updating velocity is handled at a higher level. Don't do that here.
   */
  public abstract void collision(Entity e, PVector closing);
  
  /**
   * @return an int indicating what order collision() should be called. Larger => latter.
   */
  public int collisionOrder() {
    return 0;
  }
  
  /**
   * Update self. Called everytick before draw.
   */
  public void update() {
    loc = loc.add(vel);
  }
  
  /**
   * Does this object intersect `e`.
   */
  public boolean intersects(Entity e) {
    return this.loc.dist(e.loc) <= (this.r + e.r + 1.0f);
  }
  
  /**
   * Is this thing massive? Non massive things shouldn't bounce off other things. 
   * However non massive things should still get a collsion event.
   */
  public boolean isMassive() {
    return true;
  }
  
  /**
   * Is this Entity is ~~a live so to speak.
   * Provides a way for entities to tell work to remove them.
   */
  public boolean isLive() {
    return health > 0;
  }
  
  public void addHealth(int fruit) {
    health = max(min(100, health+fruit), 0);
    if(health == 0) {
      kill();
    }
  }
  
  public int getHealth() {
    return health;
  }
  
  public void setHealth(int h) {
    health = max(min(100, h), 0);
  }
  
  /**
   * After this is called the object should not be isLive().
   * The object should be removed from the world by it's container.
   */
  public void kill() {
    health = 0;
  }
   
  public String toString() {
    return loc.toString();
  }
}
  


/**
 * Collection of Entities.
 * This class is responsible for update the location of all it's entities, and mapping that location to a grid bin.
 * the grid of bins allows this classs to implement the getHood() method efficiently.
 * Also handles collision detection on each update().
 */
class EntityWorld implements Observer, Iterable<Entity>
{
  private int maxId = 0; 
  public final int w;
  public final int h;
  public final int binSize;
  public final int wBins;
  public final int hBins;

  HashMap<Entity,Integer> entities = new HashMap();
  HashMap<Integer,ArrayList<Entity>> grid = new HashMap<Integer,ArrayList<Entity>>();
  HashMap<Class,Integer> types = new HashMap();
  
  public EntityWorld(int w, int h, int binSize) {
    if(binSize < 5 || binSize > w/2 || binSize > h/2) {
      throw new RuntimeException("Bad bin size.");
    }
    this.w = w;
    this.h = h;
    this.binSize = binSize;
    wBins = (int)Math.ceil((double)w/binSize);
    hBins = (int)Math.ceil((double)h/binSize);
    for(int i = 0 ; i < wBins; i++) {
      for(int j = 0 ; j < hBins; j++) {
        grid.put(j*wBins+i, new ArrayList<Entity>());
      }
    }
  }
  
  /**
   * Add entity.
   * @todo throw if e's bounds don't fit in a bin.
   */
  public void add(Entity e) {
    int key = getKey(e);
    entities.put(e, key);
    ArrayList<Entity> bucket = getBucket(key);
    bucket.add(e);
    e.addObserver(this);
    e.id = ++maxId;
    addClass(e.getClass());
  }
  
  /**
   * Remove entity.
   */
  public void remove(Entity e) {
    int key = entities.get(e);
    ArrayList<Entity> bucket = getBucket(key);
    bucket.remove(e);
    entities.remove(e);
    removeClass(e.getClass());
  }
  
  public int size() {
    return entities.size();
  }
  
  private void addClass(Class c) {
    if(types.get(c) == null) {
      types.put(c, 1);
    }
    else {
      types.put(c, types.get(c)+1);
    }
  }
  
  private void removeClass(Class c) {
    types.put(c, types.get(c)-1);
  }
  
  public int countClass(Class c) {
    int count = 0;
    if(types.get(c) != null) {
      count = types.get(c);
    }
    return count;
  }
  
  /**
   * Update all entities, taking care of bounds and indexes. 
   */
  public void update() {
    List<Entity> _entities = new ArrayList<Entity>(entities.keySet());
    for(int i = _entities.size()-1; i >= 0; i--) {
      Entity e = _entities.get(i);
      checkBounds(e);
      collisions(e);
      e.update();
      if(!e.isLive()) {
        remove(e);
      }
      else {
        updateIndexes(e); // Must come after e.update().
      }
    }
  }

  /**
   * Get the neighbourhood (9 bins) of e.
   */
  public ArrayList<Entity> getHood(Entity e) {
    ArrayList<Entity> nHood = new ArrayList<Entity>();
    if(entities.get(e) == null) {
      throw new RuntimeException();
    }
    int[] c = keyToArray(getKey(e));
    for(int i = c[1]-1; i <= c[1]+1; i++) {
      for(int j = c[0]-1; j <= c[0]+1; j++) {
        nHood.addAll(getBucket(arrayToKey(new int []{j,i})));
      }
    }
    return nHood;
  }
  
  /**
   * Get the bin key of e
   */
  public int getKey(Entity e) {
    int y = ((int)e.loc.y)/binSize;
    int x = ((int)e.loc.x)/binSize;
    return wBins*y+x;
  }
  
  /**
   * Get the bin corresponding to key.
   */
  public ArrayList<Entity> getBucket(int key) {
    ArrayList<Entity> bucket = grid.get(key);
    if(bucket == null) {
      bucket = new ArrayList<Entity>();
      grid.put(key,  bucket);
    }
    return bucket;
  }
  
  /**
   * Turn an integer bin key back into a 2tuple coordinate.
   */
  public int[] keyToArray(int key) {
    return new int[] {key%wBins, key/wBins}; 
  }
  
  /**
   * Turn a 2tuple into a bin key.
   */
  public int arrayToKey(int[] c) {
    return c[1]*wBins + c[0]; 
  }
  
  /**
   * Check if e out of bound, and *modify* trajectory if so.
   */
  private void checkBounds(Entity e) {
    if(e.loc.x <= 0 || e.loc.x >= w) {
       if(e.isMassive()) 
         e.vel.x = -1*e.vel.x;
       else
         e.kill();
    }
    if(e.loc.y <= 0 || e.loc.y >= h) {
      if(e.isMassive())
        e.vel.y = -1*e.vel.y;
      else
        e.kill();
    }
  }
  
  /**
   * Finds all colliding objects and adjusts their velocities accordingly.
   * Just assumes every thing has the same mass.
   */
  private void collisions(Entity e) {
    for(Entity n : getHood(e)) {
      if(e.intersects(n) && e.id < n.id) {
        PVector incident = n.loc.copy().sub(e.loc).normalize();
        PVector[] componentsE = project(incident, e.vel);
        PVector projE = componentsE[0];
        PVector perpE = componentsE[1];
        PVector[] componentsN = project(incident, n.vel);
        PVector projN = componentsN[0];
        PVector perpN = componentsN[1];
        // Determine the speed of n along the incident vector between e and n. Iff its -ve they are colliding.
        PVector closing = projE.copy().sub(projN);
        if(closing.dot(incident) > 0) {
          //System.out.format("Collision detected: %s, %s\n", projE, projN);
          if(e.isMassive() && n.isMassive()) {
            e.vel = perpE.add(projE.sub(closing));
            n.vel = perpN.add(projN.add(closing));
          }
          Entity first = e;
          Entity second = n;
          PVector firstClosing = closing.copy();
          if(e.collisionOrder() > n.collisionOrder()) {
            first = n;
            second = e;
            firstClosing.mult(-1.0f);
          }
          first.collision(second, firstClosing.mult(-1.0f));
          second.collision(first, firstClosing.mult(-1.0f));
        }
      }
    }
  }
  
  /**
   * Ensure the Entity is in the correct bin.
   */
  private void updateIndexes(Entity e) {
    int key = getKey(e);
    if(!entities.get(e).equals(key)) {
      remove(e);
      add(e);
    }
  }
  
  /**
   * Draw the grid and delegate draw to all contained entities.
   */
  public void draw() {
    for(Map.Entry<Integer,ArrayList<Entity>> bucket : grid.entrySet()) {
      int size = bucket.getValue().size();
      if(size > 0) {
        int[] i = keyToArray(bucket.getKey());
        fill(255-size*20); 
        rect(i[0]*binSize, i[1]*binSize, binSize, binSize);
        //println("Bucket " + " " + i[0] + " " + i[1] + " " + size);
      }
    }
    for(Entity e : entities.keySet()) {
      //println(getKey(e) + ", " + keyToArray(getKey(e))[0] + ", " + keyToArray(getKey(e))[1]); 
      e.draw();
    }
  }
  
  public Iterator<Entity> iterator() {
    return entities.keySet().iterator();
  }

  /**
   * Callback for Entity events.
   */
  public void update(Observable o, Object arg) {
    println("NOTIFCATION!!");
    Entity target = (Entity)o;
    remove(target);
  }
}
/**
 * A projectile fired from a ship.
 * The projectile knows it origin ship so it can report a hit back to it.
 */
class Projectile extends Entity
{
  Ship myShip;
   
  public Projectile(PVector loc, PVector vel, Ship ship) {
    super(loc, vel, 5);
    myShip = ship;
  }
  
  public void draw() {
    pushMatrix();
    colorMode(RGB);
    fill(0);
    stroke(0);
    ellipse(loc.x, loc.y, r/2, r/2);
    popMatrix();
  }
  
  /**
   * Do collision. Note collision is called on both things involved, in a certain order according to collisionOrder(). 
   * Thus assume e has already taken the hit from the projectile.
   * @see EntityWorld.collisions()
   */
  public void collision(Entity e, PVector closing) {
    e.addHealth(-8);
    if(e instanceof Bubble && !e.isLive()) {
      myShip.addScore(100);
    }
    else if(e instanceof Ship && !e.isLive()) {
      myShip.addScore(1000);
    }
    kill();
  }
  
  public int collisionOrder() {
    return 100;
  }
  
  public boolean isMassive() {
    return false;
  }
}

/**
 * A dud projectile that hits but does no damage.
 * @todo probably should be base class of projectile...
 */
class ProjectileDud extends Projectile
{
  Ship myShip;

  public ProjectileDud(PVector loc, PVector vel, Ship ship) {
    super(loc, vel, ship);
    myShip = ship;
  }
  
  public void draw() {
    pushMatrix();
    colorMode(RGB);
    fill(0xff888888);
    stroke(0xff888888);
    ellipse(loc.x, loc.y, r/2, r/2);
    popMatrix();
  }
  
  /**
   * Do collision. Note collision is called on both things involved, in a certain order according to collisionOrder(). 
   * Thus assume e has already taken the hit from the projectile.
   * @see EntityWorld.collisions()
   */
  public void collision(Entity e, PVector closing) {
    kill();
  }
  
  public int collisionOrder() {
    return 100;
  }
  
  public boolean isMassive() {
    return false;
  }
}
/**
 * A ship entity that can fly around by changing its heading and moment.
 */
class Ship extends Entity
{
  final float sterringIncrement = PI/16.0f;
  final float viewField = PI-(PI/8); /** Actually 1/2 the FoV */
  final float dampening = 0.98f;
  private EntityWorld world; /** Require a world to seed with projectiles. */
  private PVector heading = new PVector(0,1); /** Heading */
  private int score = 0;
  private boolean shadowMode = false; /** In shadow mode thrust does not move and ship fires duds. */
  private int shootCounter = 0;
  /** View stuff */
  int myColour = 0xff888888;
  boolean thrusting = false;
  
  public Ship(PVector loc, PVector vel, EntityWorld world) {
    super(loc, vel, 7.0f);
    this.world = world;
  }
  
  public void update() {
    super.update();
    vel.mult(dampening);
  }
  
  public void draw() {
    pushMatrix();
    colorMode(RGB, 255);
    translate(loc.x,loc.y);
    rotate(-heading.heading());
    if(thrusting) {
      fill(0xffDFB700);
      ellipse(-r,0,8,8);
      thrusting = false;
    }
    fill(myColour);
    stroke(128);
    triangle(-r, -r, r*1.5f, 0, -r, r);
    popMatrix();
  }
  
  /**
   * Do collision. Collision hurt least if your pointing at the thing you hit. Allows for ramming.
   */
  public void collision(Entity e, PVector closing) {
    if(e.isMassive()) {
      float dot = closing.dot(heading.normalize()); // varies between +- closing.mag(). Max if parellel and same direction.
      float impact = -1.0f*dot + closing.mag();
      impact = map(impact, 0, 2.0f*closing.mag(), 1, 8);
      //System.out.format("DotFactrp=%.2f, Impact=%.2f, ClosingMag=%.2f\n", dot/closing.mag(), impact, closing.mag());  
      addHealth((int)-impact);
    }
  }
 
  public int getScore() {
    return this.score;
  }
  
  public void addScore(int score) {
    this.score += score;
  }
  
  public void setScore(int score) {
    this.score = score;
  }
  
  public void kill() {
    super.kill();
    score = 0;
    world.add(new DeadShip(loc, vel, heading));
  }
  
  public void setShadowMode(boolean setting) {
    shadowMode = setting;
  }
  
  public void steerLeft() {
    heading.rotate(sterringIncrement);
  }
  
  public void steerRight() {
    heading.rotate(-sterringIncrement);
  }
  
  public void applyThrust() {
    thrusting = true;
    if(!shadowMode) {
      float velMag = vel.mag();
      PVector fixedHeading = heading.copy().mult(1.0f/(1.0f+velMag));
      fixedHeading.y = -1.0f*fixedHeading.y;
      vel = vel.add(fixedHeading);
    }
  }
  
  public void fireProjectile()  {
    if(shootCounter++%2 ==0) {
      PVector fixedHeading = new PVector(heading.x, -heading.y);
      Entity missile = null;
      if(shadowMode) {
        missile = new ProjectileDud(loc.copy(), fixedHeading.copy().mult(10), this);
      }
      else {
        missile = new Projectile(loc.copy().add(fixedHeading.copy().mult(r*1.4f)), fixedHeading.copy().mult(12), this);
      }
      world.add(missile);
    }
  }
  
  /**
   * Generate a percept based on our ships environment,
   * Currently that percept is vector of length 4 described above.
   * Order is <ship_dist, ship_angle, bubble_dist, bubble_angle>
   * @todo Pretty inefficient search for nearest objects but is fine in current app..
   * @input ship Not necessarily our ship.
   */
  public float[] getPercept() {
    float[] percept = {0.0f, 0.0f, 0.0f, 0.0f};
    Bubble closestBubble = null;
    Ship closestShip = null;
    float minBubbleDistance = 10.0e5f;
    float minShipDistance = 10.0e5f;
    for(Entity e : world) {
      if(e.id == id) {
        continue;
      }
      float distanceTo = loc.dist(e.loc);
      if(e instanceof Bubble && distanceTo < minBubbleDistance) { 
        closestBubble = (Bubble)e;
        minBubbleDistance = distanceTo;
      }
      else if(e instanceof Ship && distanceTo < minShipDistance) {
        closestShip = (Ship)e;
        minShipDistance = distanceTo;
      }  
    }
    if(closestShip != null) {
      PVector to = closestShip.loc.copy().sub(loc);
      to.y = to.y*-1.0f;
      percept[0] = map(minShipDistance, 0, world.w/2.0f, 1.0f, 0.0f);
      percept[1] = map(constrain(_angleBetween(heading,to), -viewField, viewField), -viewField, viewField, -1.0f, 1.0f);
    }
    if(closestBubble != null) {
      PVector to = closestBubble.loc.copy().sub(loc);
      to.y = to.y*-1.0f;
      percept[2] = map(minBubbleDistance, 0, world.w/2.0f, 1.0f, 0.0f);
      percept[3] = map(constrain(_angleBetween(heading,to),-viewField, viewField), -viewField, viewField, -1.0f, 1.0f);
    }
    return percept;
  }
}
/**
 * Abstract ShipControllers and all sub classes.
 * Keeping all sub classes here to make them easier to navigate in Processing IDE.
 */






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
    ship.myColour = 0xffFF0000;
  }

  /**
   * @override
   */
  public void turn(int turn) {
    float fire = random(0,1);
    float direction = random(0,1); 
    if(fire > 0.8f) {
      ship.fireProjectile();
    }
    if(direction <= 0.1f) {
      ship.steerLeft();
    }
    else if(direction <= 0.2f) {
      ship.steerRight();
    }
    else if(direction <= 0.4f) {
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
    ship.myColour = 0xff0000FF;
  }
  
  /**
   * @override
   */
  public void turn(int turn) {
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
    lastTurn[0] = fire ? 1.0f : 0.0f;
    lastTurn[1] = left ? 1.0f : 0.0f;
    lastTurn[2] = right ? 1.0f : 0.0f;
    lastTurn[3] = thrust ? 1.0f : 0.0f;
    //if(turn%10==0){ printPercept(); }
    fire = left = right = thrust = false;
  }
  
  public float[] getLastTurn() {
    return lastTurn;
  }
  
  private void printPercept() {
    float[] in = ship.getPercept();
    System.out.format("[%.2f,%.2f,%.2f,%.2f], [%.2f,%.2f,%.2f,%.2f]\n", in[0], in[1], in[2], in[3], lastTurn[0], lastTurn[1], lastTurn[2], lastTurn[3]); 
  }

  /** 
   * key press handler. Must be hooked up to key presses.
   */
  public void keyPressed() {
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
  public final float threshold = 0.0f;
  protected EntityWorld world; /** Require a world to generate percept. */
  protected PerceptronNetwork nn;

  NeuralShipController(Ship ship, EntityWorld world) {
    super(ship);
    this.world = world;
    nn = new PerceptronNetwork(4,4, new Perceptron.Sign(), 0.01f);
    ship.myColour = 0xffFF0000;
  }
  
  /**
   * Configure neural network.
   */
  public void setWeights(float[] weights) {
    nn.setWeights(weights);
  }
  
  /**
   * Get outputs from NN and apply them to controls.
   * Order must match the training data order. Should be: <fire, left, right, thrust>
   * @override
   */
  public void turn(int turn) {
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
    ship.myColour = 0xffFFFF00;
    float[] config = loadConfig();
    if(config != null) {
      println("Found config for OnlineNeuralShipController. Assigning.");
      nn.setWeights(config);
    }
    else {
      println("No history for OnlineNeuralShipController. Random assignment.");
    }
  }
  
  public void end() {
    if(persistent) {
      saveConfig();
    }
  }
  
  /**
   * Ask the trainer what it did under its conditions and inform our neural ship.
   * @override
   */
  public void turn(int turn) {
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
  public float[] loadConfig() { 
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
  public void saveConfig() {
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
    ship.myColour = 0xffFF8800;
  }
  
  public void begin() {
  }
  
  public void end() {
    storeResult(nn.getWeights(), configId, ship.score);
  }
  
  /**
   * Load an array of neural net weights from persistent storage.
   * Instance properties `config` and `configId` will be set after calling this method.
   * { configs: [ { config: [[]], configId: <int>, score: <float>, runs: <int> } ], index: <int> }
   */
  public void loadConfig() {
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
  public JSONObject initializeConfigs() {
    JSONObject obj = new JSONObject();
    JSONArray configs = new JSONArray();
    for(int i = 0; i < 5; i++) {
      JSONObject configObject = new JSONObject();
      JSONArray configArray = new JSONArray();
      for(int j = 0; j < nn.nWeights; j++) {
        configArray.setFloat(j,random(-1.0f, 1.0f));
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
  public void storeResult(float[] config, int configId, float score) {
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
  
  public JSONObject findJsonConfig(JSONArray arr, int id) {
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
  public FileLock getLock(File file) {
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
/**
 * Status bar for game.
 * Responsible for drawing and updating the status. 
 * Always draws itself in the bottom 20px.
 */
class StatusBar
{
  final int lineHeight = 20;
  EntityWorld world;
  ArrayList<ShipController> controllers;
  int myHeight;
  int maxTurns;
 
  StatusBar(EntityWorld world, ArrayList<ShipController> controllers, int maxTurns) {
    this.world = world;
    this.controllers = controllers;
    this.maxTurns = maxTurns;
    myHeight = (controllers.size()+1)*lineHeight;
  }
  
  public void draw(int turn) {
    String statuses = "";
    String status;
    int nShips = controllers.size();
    int nLive = 0;
    textAlign(LEFT);
    textSize(14);
    textLeading(lineHeight);
    rectMode(CORNER);
    fill(0xffFFFFFF);
    rect(0, height-myHeight, width, myHeight); 
    int shipCnt = 1;
    pushMatrix();
    translate(0,height-myHeight+lineHeight);
    for(ShipController a : controllers) {
      String statusLine = String.format("Ship %d: Health=%03d, Score=%04d\n", shipCnt++, a.ship.getHealth(), a.ship.getScore()); 
      nLive += a.ship.isLive() ? 1 : 0;
      fill(a.ship.myColour);
      text(statusLine, 1, 0);
      translate(0, lineHeight);
    }
    status = String.format("Turn=%04d/%04d, Live Ships=[%d/%d]\n", turn, maxTurns, nLive, nShips);
    fill(0xff000000);
    text(status, 1, 0);
    popMatrix();
  }
}

/**
 * Find the parallel and perpendicular components of b wrt a.
 */
public PVector[] project(PVector aIn, PVector bIn) {
  PVector a = aIn.copy().normalize();
  PVector b = bIn.copy();
  PVector proj = a.copy().mult(a.dot(b)/a.mag());
  PVector tang = b.copy().sub(proj);
  return new PVector[] {proj, tang};
}

/**
 * Get the angle between but maintain a sign (unlike processing).
 * clockwise a to b is -ve.
 */
public float _angleBetween(PVector aIn, PVector bIn) {
  PVector a = aIn.copy().rotate(-aIn.heading());
  PVector b = bIn.copy().rotate(-aIn.heading());
  float angle = PVector.angleBetween(a,b);
  if(b.y < 0) {
    angle *= -1.0f;
  }
  return angle;
}
  public void settings() {  size(720,840); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Bubbles9000" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
