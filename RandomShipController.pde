/**
 * Controls a ship by listening to mysterious key press events. Suprisingly effective.
 * Processing queues up all events and send them to you after (why after...) each draw().
 * So we latchkey presses and only send them through to our ship on turn.
 */
class RandomShipController extends ShipController
{
  RandomShipController(Ship ship) {
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
    float fire = random(0,1);
    float direction = random(0,1); 
    if(fire > 0.8) {
      ship.fireProjectile();
    }
    if(direction <= 0.2) {
      ship.applyThrust();
    }
    else if(direction <= 0.4) {
      ship.steerRight();
    }
    if(direction <= 0.6) {
      ship.steerLeft();
    }
  }
}