class Bubble extends Entity
{
  float hue = random(30,70);
  public Bubble(PVector loc, PVector vel, float r) {
    super(loc, vel, r);
  }
  
  void draw() {
    pushMatrix();
    colorMode(HSB, 100);
    fill(hue, hue, hue, health);
    stroke(hue, hue, hue);
    ellipse(loc.x, loc.y, r*2, r*2);
    popMatrix();
  }
  
  void collision(Entity e) {
    this.r -= 1.0;
    if(r < 4.0) {
      kill();
    }
  }
}