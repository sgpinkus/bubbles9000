/**
 * A ship controller. The game init one of these for every ship.
 * Then asks the controller to move it's ship each turn before updating the world.
 */
abstract class ShipController
{
   Ship ship;
   
   ShipController(Ship ship) {
     this.ship = ship;
   }
   
   /** Called when game begins. */
   public abstract void begin();
   /** Called when game ends so controller can do clean up or what not. */
    public abstract void end();
   /** Called each turn. */
   public abstract void turn(int turn);
}