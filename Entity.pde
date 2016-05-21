import java.util.*;

/**
 * A thing in the world. Has position, velocity, and a bounding box. Can also draw itself.
 * Also encapsulates concept of health, aliveness and, massiveness. Athough not relevant to all entities common to many.
 */
abstract class Entity extends Observable
{
  /** The of this Entity */
  public PVector loc = new PVector();
  /** The current velocity */
  public PVector vel = new PVector();
  /** Everything is circular and has a bound radius. Make thing simple */
  float r;
  /** Every object has a unique id. This helps to totally order them */
  int id;
  /** Health. */
  int health = 100;
  
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
   * Handle collision with another object, `other`.
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
    return this.loc.dist(e.loc) <= (this.r + e.r + 1.0);
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
  
  public void kill() {
    health = 0;
  }
   
  public String toString() {
    return loc.toString();
  }
}
  