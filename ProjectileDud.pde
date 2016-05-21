/**
 * A dud projectile that hits but does no damage.
 * Note class doesnt extend Projectile vice versa because of weird processing implementation contraints.
 * @todo probably should be base class of projectile...
 */
class ProjectileDud extends Entity
{
  Ship myShip;

  public ProjectileDud(PVector loc, PVector vel, Ship ship) {
    super(loc, vel, 5);
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