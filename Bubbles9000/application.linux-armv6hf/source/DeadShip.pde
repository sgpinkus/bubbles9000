/**
 * The ghost of a ship that has just beed killed.
 */
class DeadShip extends Entity
{
  private final int deathHealth = 15;
  private PVector heading = new PVector(0,1); /** Heading */
  
  public DeadShip(PVector loc, PVector vel, PVector heading) {
    super(loc, vel, 7.0); 
    this.heading = heading;
    setHealth(deathHealth);
  }
  
  void update() {
    super.update();
  }
  
  /**
   * Draw fade away to white.
   */
  void draw() {
    float greyness = 128.0f+(128.0f*(1.0-getHealth()/(float)deathHealth));  
    pushMatrix();
    colorMode(RGB, 255);
    translate(loc.x,loc.y);
    rotate(-heading.heading());
    fill(greyness);
    stroke(greyness);
    triangle(-r, -r, r*1.5, 0, -r, r);
    popMatrix();
    addHealth(-1);
  }
  
  /**
   * Do collision. Collision hurt least if your pointing at the thing you hit. Allows for ramming.
   */
  void collision(Entity e, PVector closing) {
  }
  
  boolean isMassive() {
    return false;
  }
}