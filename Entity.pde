import java.util.*;

/**
 * A thing in the world. Has position, velocity, and a bounding box. Can also draw itself.
 * The bound box is used for collision detection.
 */
class Entity extends Observable
{
  public PVector loc = new PVector();
  public PVector vel = new PVector();
  public PVector bounds = new PVector();
  
  public Entity(PVector loc, PVector vel, PVector bounds) {
    this.loc = loc;
    this.vel = vel;
    this.bounds = bounds;
  }
  
  public void update() {
    loc = loc.add(vel);
  }
  
  public void draw() {
    pushMatrix();
    ellipse(loc.x, loc.y, 5, 5);
    popMatrix();
  }
}
  