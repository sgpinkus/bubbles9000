/**
 * Controls a ship by listening to mysterious key press events. Suprisingly effective.
 * Processing queues up all events and send them to you after (why after...) each draw().
 * So we latch key presses and only send them through to our ship on turn.
 */
class StdioShipController extends ShipController
{
  boolean fire = false;
  boolean left = false;
  boolean right = false;
  boolean thrust = false;
  float[] lastTurn = new float[4];
  
  StdioShipController(Ship ship) {
    super(ship);
    ship.myColour = #0000FF;
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
   * @override
   */
  void turn(int turn) {
    if(fire) {
      ship.fireProjectile();
    }
    if(left) {
      ship.steerLeft();
    }
    if(right) {
      ship.steerRight();
    }
    if(thrust) {
      ship.applyThrust();
    }
    lastTurn[0] = fire ? 1.0 : 0.0;
    lastTurn[1] = left ? 1.0 : 0.0;
    lastTurn[2] = right ? 1.0 : 0.0;
    lastTurn[3] = thrust ? 1.0 : 0.0;
    if(turn%10==0)
      printPercept();
    fire = left = right = thrust = false;
  }
  
  float[] getLastTurn() {
    return lastTurn;
  }
  
  private void printPercept() {
    float[] in = ship.getPercept();
    System.out.format("[%.2f,%.2f,%.2f,%.2f], [%.2f,%.2f,%.2f,%.2f]\n", in[0], in[1], in[2], in[3], lastTurn[0], lastTurn[1], lastTurn[2], lastTurn[3]); 
  }

  /** 
   * key press handler. Must be hooked up to key presses.
   */
  void keyPressed() {
    if(key == ' ') {
      fire = true;
    }
    if(keyCode == LEFT) {
      left = true;
      right = thrust = false;
    }
    if(keyCode == RIGHT) {
      right = true;
      left = thrust = false;
    }
    if(keyCode == UP) {
      thrust = true;
      left = right = false;
    }
  }
}