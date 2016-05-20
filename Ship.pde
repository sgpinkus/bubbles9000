/**
 * A ship entity that can fly around by changin its heading and moment.
 */
class Ship extends Entity
{
  final float sterringIncrement = PI/16.0;
  final float dampening = 0.99;
  EntityWorld world; /** Require a world to seed with projectiles. */
  PVector heading = new PVector(0,1); /** Heading */
  int score = 0;
  /** View stuff */
  color myColour;
  boolean thrusting = false;
  
  public Ship(PVector loc, PVector vel, EntityWorld world) {
    super(loc, vel, 7.0);
    this.world = world;
    init(); 
  }
  
  private void init() {
    switch(id%6) {
      case 0: 
        myColour = #FF0000;
        break;
      case 1:
        myColour = #FFFF00;
        break;
      case 2:
        myColour = #00FF00;
        break;
      default:
        myColour = #00FFFF;
    }
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
    stroke(myColour);
    triangle(-r, -r, r*1.5, 0, -r, r);
    popMatrix();
  }
  
  /**
   * Do collision. Collision hurt least to most from frontn to back 
   */
  void collision(Entity e, PVector closing) { 
    float impact = closing.dot(heading.normalize()) + closing.mag();
    impact = map(impact, 0, 2.0*closing.mag(), 3, 9);
    println("Collision with closing " + closing.mag() + " Gives " + impact);
    addHealth((int)-impact);
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