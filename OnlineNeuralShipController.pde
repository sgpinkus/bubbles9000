/**
 * Listens to the input of a StdioShipController, and use that to do reinforcement training on a NeuralShipController.
 */
class OnlineNeuralShipController extends NeuralShipController
{
  protected StdioShipController trainer;
  
  OnlineNeuralShipController(Ship ship, EntityWorld world, StdioShipController trainer) {
    super(ship, world);
    this.trainer = trainer;
    //ship.setShadowMode(true);
  }
  
  /**
   * Ask the trainer what it did under its conditions and inform our neural ship.
   * @override
   */
  void turn(int turn) {
    if(turn%2 == 0 && trainer.ship.isLive()) {
      float[] percept = trainer.ship.getPercept();
      float[] output = trainer.getLastTurn();
      //printTraining(percept, output);
      nn.train(percept, output);
    }
    super.turn(turn);
  }
  
  private void printTraining(float[] in, float[] out) {
    System.out.format("[%.2f,%.2f,%.2f,%.2f], [%.2f,%.2f,%.2f,%.2f]\n", in[0], in[1], in[2], in[3], out[0], out[1], out[2], out[3]); 
  }
}