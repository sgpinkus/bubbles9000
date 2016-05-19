/**
 * Controls a ship by listenign to mysterious key press events.
 * Suprisingly effective.
 */
class StdioShipController
{
  Ship myShip;
  
  StdioShipController(Ship ship) {
    myShip  = ship;
  }
  
  /** 
   * key press handler. Must be hooked up to key presses.
   */
  void keyPressed() {
    if(key == ' ') {
      myShip.fireProjectile();
    }
    if(keyCode == LEFT) {
      myShip.steerLeft();
    }
    if(keyCode == RIGHT) {
      myShip.steerRight();
    }
    if(keyCode == UP) {
      myShip.applyThrust();
    }
  }
}