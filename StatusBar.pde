/**
 * Status bar for game.
 * Responsible for drawing and updating the status. 
 * Always draws itself in the bottom 20px.
 */
class StatusBar
{
  EntityWorld world;
  ArrayList<Ship> ships;
 
  StatusBar(EntityWorld world, ArrayList<Ship> ships) {
    this.world = world;
    this.ships = ships;
  }
  
  void draw() {
    String statuses = "";
    String status;
    int nShips = ships.size();
    int nLive = 0;
    textAlign(LEFT);
    rectMode(CORNER);
    fill(#FFFFFF);
    rect(0, height-20, width, 20); 
    fill(#000000);
    int shipCnt = 1;
    for(Ship a : ships) {
      statuses += String.format("Ship %d: Health=%d, Score=%d", shipCnt++, a.health, a.score); 
      nLive += a.isLive() ? 1 : 0;
    }
    status = String.format("[%d/%d]: %s", nLive, nShips, statuses);
    text(status, 1, height-1);
  }
}