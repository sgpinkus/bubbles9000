class Bubble extends Entity
{
  public Bubble(PVector loc, PVector vel, float r) {
    super(loc, vel, r);
  }
  
  void draw() {
    pushMatrix();
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