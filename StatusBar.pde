/**
 * Status bar for game.
 * Responsible for drawing and updating the status. 
 * Always draws itself in the bottom 20px.
 */
class StatusBar
{
  final int lineHeight = 20;
  EntityWorld world;
  ArrayList<Ship> ships;
  int myHeight;
  int maxTurns;
 
  StatusBar(EntityWorld world, ArrayList<Ship> ships, int maxTurns) {
    this.world = world;
    this.ships = ships;
    this.maxTurns = maxTurns;
    myHeight = (ships.size()+1)*lineHeight;
  }
  
  void draw(int turn) {
    String statuses = "";
    String status;
    int nShips = ships.size();
    int nLive = 0;
    textAlign(LEFT);
    textSize(14);
    textLeading(lineHeight);
    rectMode(CORNER);
    fill(#FFFFFF);
    rect(0, height-myHeight, width, myHeight); 
    fill(#000000);
    int shipCnt = 1;
    for(Ship a : ships) {
      statuses += String.format("Ship %d: Health=%03d, Score=%04d\n", shipCnt++, a.health, a.score); 
      nLive += a.isLive() ? 1 : 0;
    }
    status = String.format("Turn=%04d/%04d, Live Ships=[%d/%d]\n%s", turn, maxTurns, nLive, nShips, statuses);
    text(status, 1, height-myHeight+lineHeight);
  }
}