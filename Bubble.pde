class Bubble extends Entity
{
  final float minRadius = 10.0;
  float hue = random(50,100);
  PImage bubbleImage = loadImage("bubble100x100.png");

  
  public Bubble(PVector loc, PVector vel, float r) {
    super(loc, vel, r);
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
  
  void collision(Entity e, PVector closing) {
    this.r -= 2.0;
    if(r < minRadius) {
      kill();
    }
  }
}