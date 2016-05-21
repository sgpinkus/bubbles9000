/**
 * A ship entity that can fly around by changin its heading and moment.
 */
class Ship extends Entity
{
  final float sterringIncrement = PI/16.0;
  final float dampening = 0.98;
  private EntityWorld world; /** Require a world to seed with projectiles. */
  private PVector heading = new PVector(0,1); /** Heading */
  private int score = 0;
  /** View stuff */
  color myColour = #888888;
  boolean thrusting = false;
  
  public Ship(PVector loc, PVector vel, EntityWorld world) {
    super(loc, vel, 7.0);
    this.world = world;
  }
  
  void update() {
    super.update();
    vel.mult(dampening);
  }
  
  void draw() {
    pushMatrix();
    colorMode(RGB, 255);
    translate(loc.x,loc.y);
    rotate(-heading.heading());
    if(thrusting) {
      fill(#BBBB00);
      ellipse(-r,0,8,8);
      thrusting = false;
    }
    fill(myColour);
    stroke(128);
    triangle(-r, -r, r*1.5, 0, -r, r);
    popMatrix();
  }
  
  /**
   * Do collision. Collision hurt least if your pointing at the thing you hit. Allows for ramming.
   */
  void collision(Entity e, PVector closing) {
    if(e.isMassive()) {
      float dot = closing.dot(heading.normalize()); // varies between +- closing.mag(). Max if parellel and same direction.
      float impact = -1.0*dot + closing.mag();
      impact = map(impact, 0, 2.0*closing.mag(), 2, 12);
      //System.out.format("DotFactrp=%.2f, Impact=%.2f, ClosingMag=%.2f\n", dot/closing.mag(), impact, closing.mag());  
      addHealth((int)-impact);
    }
  }
  
  void addScore(int score) {
    this.score += score;
  }
  
  void steerLeft() {
    heading.rotate(PI/16.0);
  }
  
  void steerRight() {
    heading.rotate(-PI/16.0);
  }
  
  void applyThrust() {
    PVector fixedHeading = heading.copy();
    fixedHeading.y = -1.0*fixedHeading.y;
    vel = vel.add(fixedHeading);
    thrusting = true;
  }
  
  void fireProjectile() {
    PVector fixedHeading = new PVector(heading.x, -heading.y);
    Projectile missile = new Projectile(loc.copy(), fixedHeading.copy().mult(10), this);
    world.add(missile);
  }  
}