/**
 * A ship entity that can fly around by changing its heading and moment.
 */
class Ship extends Entity
{
  final float sterringIncrement = PI/16.0;
  final float viewField = PI-(PI/8); /** Actually 1/2 the FoV */
  final float dampening = 0.98;
  private EntityWorld world; /** Require a world to seed with projectiles. */
  private PVector heading = new PVector(0,1); /** Heading */
  private int score = 0;
  private boolean shadowMode = false; /** In shadow mode thrust does not move and ship fires duds. */
  private int shootCounter = 0;
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
      fill(#DFB700);
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
      impact = map(impact, 0, 2.0*closing.mag(), 1, 8);
      //System.out.format("DotFactrp=%.2f, Impact=%.2f, ClosingMag=%.2f\n", dot/closing.mag(), impact, closing.mag());  
      addHealth((int)-impact);
    }
  }
  
  void addScore(int score) {
    this.score += score;
  }
  
  public void kill() {
    super.kill();
    score = 0;
  }
  
  void setShadowMode(boolean setting) {
    shadowMode = setting;
  }
  
  void steerLeft() {
    heading.rotate(sterringIncrement);
  }
  
  void steerRight() {
    heading.rotate(-sterringIncrement);
  }
  
  void applyThrust() {
    thrusting = true;
    if(!shadowMode) {
      float velMag = vel.mag();
      PVector fixedHeading = heading.copy().mult(1.0/(1.0+velMag));
      fixedHeading.y = -1.0*fixedHeading.y;
      vel = vel.add(fixedHeading);
    }
  }
  
  void fireProjectile()  {
    if(shootCounter++%2 ==0) {
      PVector fixedHeading = new PVector(heading.x, -heading.y);
      Entity missile = null;
      if(shadowMode) {
        missile = new ProjectileDud(loc.copy(), fixedHeading.copy().mult(10), this);
      }
      else {
        missile = new Projectile(loc.copy(), fixedHeading.copy().mult(10), this);
      }
      world.add(missile);
    }
  }
  
  /**
   * Generate a percept based on our ships environment,
   * Currently that percept is vector of length 4 described above.
   * Order is <ship_dist, ship_angle, bubble_dist, bubble_angle>
   * @todo Pretty inefficient search for nearest objects but is fine in current app..
   * @input ship Not necessarily our ship.
   */
  float[] getPercept() {
    float[] percept = {0.0, 0.0, 0.0, 0.0};
    Bubble closestBubble = null;
    Ship closestShip = null;
    float minBubbleDistance = 10.0e5;
    float minShipDistance = 10.0e5;
    for(Entity e : world) {
      if(e.id == id) {
        continue;
      }
      float distanceTo = loc.dist(e.loc);
      if(e instanceof Bubble && distanceTo < minBubbleDistance) { 
        closestBubble = (Bubble)e;
        minBubbleDistance = distanceTo;
      }
      else if(e instanceof Ship && distanceTo < minShipDistance) {
        closestShip = (Ship)e;
        minShipDistance = distanceTo;
      }  
    }
    if(closestShip != null) {
      PVector to = closestShip.loc.copy().sub(loc);
      to.y = to.y*-1.0;
      percept[0] = map(minShipDistance, 0, world.w/2.0, 1.0, 0.0);
      percept[1] = map(constrain(_angleBetween(heading,to), -viewField, viewField), -viewField, viewField, -1.0, 1.0);
    }
    if(closestBubble != null) {
      PVector to = closestBubble.loc.copy().sub(loc);
      to.y = to.y*-1.0;
      percept[2] = map(minBubbleDistance, 0, world.w/2.0, 1.0, 0.0);
      percept[3] = map(constrain(_angleBetween(heading,to),-viewField, viewField), -viewField, viewField, -1.0, 1.0);
    }
    return percept;
  }
}