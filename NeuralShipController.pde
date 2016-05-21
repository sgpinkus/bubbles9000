import perceptrons.*;

/**
 * Controls a ship using a neural network.
 * This controller also derives the inputs to the neural network from the world state.
 * The full world state is too complex, so we reduce it to 4 inputs:
 *  - Distance, heading offset to closest other ship.
 *  - Distance, heading offset to closest bubble.
 * All inputs are floats with a range [-1.0,1.0].
 * The controller will read its neurons config from a file and write the results to file. 
 * The config and results are stored in a serialized JAva data structure.
 * This data structure can be used in.
 */
class NeuralShipController extends ShipController
{
  private EntityWorld world; /** Require a world to generate percept. */
  PerceptronNetwork nn;

  NeuralShipController(Ship ship, EntityWorld world) {
    super(ship);
    this.world = world;
    nn = new PerceptronNetwork(4,4);
    ship.myColour = #FF0000;
  }
  
  /**
   * @override.
   */
  void begin() {
  }
  
  /**
   * @override.
   */
  void end() {
  }
  
  /**
   * Get outputs from NN and apply them to controls.
   * Order must match the training data order. Should be: <fire, left, right, thrust>
   * @override
   */
  void turn(int turn) {
    float[] outputs = nn.value(getPercept());
    if(outputs[0] >= 0.5) {
      ship.fireProjectile();      
    }
    if(outputs[1] >= 0.5) {
      ship.steerLeft();
    }
    if(outputs[2] >= 0.5) {
      ship.steerRight();
    }
    if(outputs[3] >= 0.5) {
      ship.applyThrust();
    }
  }
  
  /**
   * Generate a percept based on our ships environment,
   * Currently that percept is vector of length 4 described above.
   * Order is <ship_dist, ship_angle, bubble_dist, bubble_angle>
   * @todo Pretty inefficient search for nearest objects but is fine in current app..
   */
  float[] getPercept() {
    float[] percept = {0.0, 0.0, 0.0, 0.0};
    Bubble closestBubble = null;
    Ship closestShip = null;
    float minBubbleDistance = 10.0e5;
    float minShipDistance = 10.0e5;
    for(Entity e : world) {
      if(e.equals(this)) {
        continue;
      }
      float distanceTo = ship.loc.dist(e.loc);
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
      percept[0] = map(minShipDistance, 0, world.w, 1.0, 0.0);
      percept[1] = constrain(map(_angleBetween(ship.heading, closestShip.loc.copy().sub(ship.loc)), -PI, PI, -1.0, 1.0), -PI+(PI/8), PI-(PI/8));  
    }
    if(closestBubble != null) {
      percept[2] = map(minBubbleDistance, 0, world.w, 1.0, 0.0);
      percept[3] = constrain(map(_angleBetween(ship.heading, closestBubble.loc.copy().sub(ship.loc)), -PI, PI, -1.0, 1.0), -PI+(PI/8), PI-(PI/8));
    }
    return percept;
  }
}