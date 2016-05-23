/**
 * A bubble entity.
 * These just bounce around until popped.
 */
class Bubble extends Entity
{
  final float minRadius = 10.0;
  final float maxRadius = 40.0;
  float hue = random(50,100);
  PImage bubbleImage = loadImage("bubble100x100.png");
  
  public Bubble(PVector loc, PVector vel, float r) {
    super(loc, vel, r);
    r = max(min(r, maxRadius), minRadius); // Silently constraint r.
    health = (int)((r-minRadius)/(maxRadius-minRadius)*health);
  }
  
  void draw() {
    pushMatrix();
    colorMode(HSB, 100);
    imageMode(CENTER);
    fill(hue, hue, hue, 20);
    stroke(hue, hue, hue, 20);
    strokeWeight(0);
    image(bubbleImage, loc.x, loc.y, r*2, r*2);
    ellipse(loc.x, loc.y, r*2, r*2);
    popMatrix();
  }
  
  /**
   * Process impact of collision on this bubble.
   * @todo account for force.
   */
  void collision(Entity e, PVector closing) {
    if(e.isMassive()) {
      addHealth(-10); 
    }
  }
  
  /**
   * Health and radius a correlated, so we need to adjust radius to reflect health.
   */
  void addHealth(int fruit) {
    super.addHealth(fruit);
    radiusHealth();
  }
  
  void radiusHealth() {
    r = map(health, 0, 100, minRadius, maxRadius);
  }
}