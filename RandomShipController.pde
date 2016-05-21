/**
 * Controls a ship randomly.
 */
class RandomShipController extends ShipController
{
  RandomShipController(Ship ship) {
    super(ship);
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
   * @override
   */
  void turn(int turn) {
    float fire = random(0,1);
    float direction = random(0,1); 
    if(fire > 0.8) {
      ship.fireProjectile();
    }
    if(direction <= 0.1) {
      ship.steerLeft();
    }
    else if(direction <= 0.2) {
      ship.steerRight();
    }
    else if(direction <= 0.4) {
      ship.applyThrust();
    }
  }
}