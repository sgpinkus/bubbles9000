/**
 * Controls a ship by listening to mysterious key press events. Suprisingly effective.
 * Processing queues up all events and send them to you after (why after...) each draw().
 * So we latchkey presses and only send them through to our ship on turn.
 */
class StdioShipController extends ShipController
{
  boolean fire = false;
  boolean left = false;
  boolean right = false;
  boolean thrust = false;
  
  
  StdioShipController(Ship ship) {
    super(ship);
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
    fire = left = right = thrust = false;
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