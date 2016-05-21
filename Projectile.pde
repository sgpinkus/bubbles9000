class Projectile extends Entity
{
  Ship myShip;
  
  float hue = random(30,70);
  public Projectile(PVector loc, PVector vel, Ship ship) {
    super(loc, vel, 1.5);
    myShip = ship;
  }
  
  void draw() {
    pushMatrix();
    colorMode(RGB);
    fill(0);
    stroke(0);
    ellipse(loc.x, loc.y, r*2, r*2);
    popMatrix();
  }
  
  /**
   * Do collision. Note collision is called on both things involved, in a certain order according to collisionOrder(). 
   * Thus assume e has already taken the hit from the projectile.
   * @see EntityWorld.collisions()
   */
  void collision(Entity e, PVector closing) {
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