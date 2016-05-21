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
  public final float threshold = 0.25;
  protected EntityWorld world; /** Require a world to generate percept. */
  protected PerceptronNetwork nn;

  NeuralShipController(Ship ship, EntityWorld world) {
    super(ship);
    this.world = world;
    nn = new PerceptronNetwork(4,4, new Perceptron.Sign());
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
    float[] outputs = nn.value(ship.getPercept());
    if(outputs[0] >= threshold) {
      ship.fireProjectile();      
    }
    if(outputs[1] >= threshold) {
      ship.steerLeft();
    }
    if(outputs[2] >= threshold) {
      ship.steerRight();
    }
    if(outputs[3] >= threshold) {
      ship.applyThrust();
    }
  }
}