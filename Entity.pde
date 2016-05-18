import java.util.*;

/**
 * A thing in the world. Has position, velocity, and a bounding box. Can also draw itself.
 * The bound box is used for collision detection.
 */
class Entity extends Observable
{
  /** The center of this Entity*/
  public PVector loc = new PVector();
  /** The bounding box of this entity */
  public PVector bounds = new PVector();
  public PVector vel = new PVector();
  
  public Entity(PVector loc, PVector vel, PVector bounds) {
    this.loc = loc;
    this.vel = vel;
    this.bounds = bounds;
  }
  
  public void update() {
    loc = loc.add(vel);
  }
  
  public boolean intersects(Entity e) {
    return false;
  }
  
  public PVector[] getBB() {
    PVector lt = new PVector(loc.x - bounds.x/2.0, loc.y - bounds.y/2.0);
    PVector rb = new PVector(loc.x + bounds.x/2.0, loc.y + bounds.y/2.0);
    return new PVector[] {lt, rb};
  }
  
  public void draw() {
    pushMatrix();
    ellipse(loc.x, loc.y, 5, 5);
    popMatrix();
  }
  
  public String toString() {
    return loc.toString();
  }
}
  