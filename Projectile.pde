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
  
  void collision(Entity e) {
    if(e instanceof Bubble && e.health < 2) {
      myShip.addScore(100);
    }
    kill();
  }
  
  boolean isMassive() {
    return false;
  }
}