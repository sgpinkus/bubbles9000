/**
 * Our test suite.
 */
 
void testGetHood() {
  world = new EntityWorld(width, height, 40);
  for(int i = 0; i < 100; i++) {
    Entity e = new Entity(
      new PVector(random(0,width-1), random(0,height)),
      PVector.random2D().mult(2.0),
      random(2,world.binSize/2.01)
    );
    world.add(e);
  }
  for(Entity e : world) {
    System.out.format("E=%s; K=%s; NUM HOOD=%s; SELF=%s\n", e, world.getKey(e), world.getHood(e).size(), world.getHood(e).contains(e));
  }
}