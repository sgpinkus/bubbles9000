import java.util.*;

/**
 * A thing in the world. Has position, velocity, and a bounding box. Can also draw itself.
 * The bound box is used for collision detection.
 */
class Entity extends Observable
{
  /** The center of this Entity */
  public PVector loc = new PVector();
  /** The current velocity */
  public PVector vel = new PVector();
  /** Everything is circular and has a bound radius. Make thing simple */
  float r;
  /** Every object has a unique id. This helps to totaly order them */
  int id;
  
  public Entity(PVector loc, PVector vel, float r) {
    this.loc = loc;
    this.vel = vel;
    this.r = r;
  }
  
  public void update() {
    loc = loc.add(vel);
  }
  
  public boolean intersects(Entity e) {
    return this.loc.dist(e.loc) <= (this.r + e.r + 1.0);
  }
  
  public void draw() {
    pushMatrix();
    ellipse(loc.x, loc.y, r*2, r*2);
    popMatrix();
  }
  
  public String toString() {
    return loc.toString();
  }
}
  