/**
 * A ship entity that can fly around by changin its heading and moment.
 */
class Ship extends Entity
{
  /** Require a world to seed with projectiles. */
  EntityWorld world;
  /** Heading */
  PVector heading = new PVector(0,1);
  color myColour;
  
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
  
  void draw() {
    pushMatrix();
    translate(loc.x,loc.y);
    colorMode(RGB, 255);
    fill(myColour);
    stroke(myColour);
    rotate(-heading.heading());
    triangle(-r, -r, r, 0, -r, r);
    popMatrix();
  }
  
  void collision(Entity e) {
    addHealth(-1);
  }
  
  void steerLeft() {
  }
  
  void steerRight() {
  }
  
  void applyThrust() {
  }
  
  void fireProjectile() {
  }  
}