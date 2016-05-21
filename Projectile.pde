class Projectile extends Entity
{
  Ship myShip;
   
  public Projectile(PVector loc, PVector vel, Ship ship) {
    super(loc, vel, 5);
    myShip = ship;
  }
  
  void draw() {
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
  void collision(Entity e, PVector closing) {
    e.addHealth(-10);
    if(e instanceof Bubble && !e.isLive()) {
      myShip.addScore(100);
    }
    else if(e instanceof Ship && !e.isLive()) {
      myShip.addScore(500);
      ((Ship)e).addScore(-500);
    }
    kill();
  }
  
  public int collisionOrder() {
    return 100;
  }
  
  boolean isMassive() {
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
  
  void draw() {
    pushMatrix();
    colorMode(RGB);
    fill(#888888);
    stroke(#888888);
    ellipse(loc.x, loc.y, r/2, r/2);
    popMatrix();
  }
  
  /**
   * Do collision. Note collision is called on both things involved, in a certain order according to collisionOrder(). 
   * Thus assume e has already taken the hit from the projectile.
   * @see EntityWorld.collisions()
   */
  void collision(Entity e, PVector closing) {
    kill();
  }
  
  public int collisionOrder() {
    return 100;
  }
  
  boolean isMassive() {
    return false;
  }
}