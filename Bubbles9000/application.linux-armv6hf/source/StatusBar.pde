/**
 * Status bar for game.
 * Responsible for drawing and updating the status. 
 * Always draws itself in the bottom 20px.
 */
class StatusBar
{
  final int lineHeight = 20;
  EntityWorld world;
  ArrayList<ShipController> controllers;
  int myHeight;
  int maxTurns;
 
  StatusBar(EntityWorld world, ArrayList<ShipController> controllers, int maxTurns) {
    this.world = world;
    this.controllers = controllers;
    this.maxTurns = maxTurns;
    myHeight = (controllers.size()+1)*lineHeight;
  }
  
  void draw(int turn) {
    String statuses = "";
    String status;
    int nShips = controllers.size();
    int nLive = 0;
    textAlign(LEFT);
    textSize(14);
    textLeading(lineHeight);
    rectMode(CORNER);
    fill(#FFFFFF);
    rect(0, height-myHeight, width, myHeight); 
    int shipCnt = 1;
    pushMatrix();
    translate(0,height-myHeight+lineHeight);
    for(ShipController a : controllers) {
      String statusLine = String.format("Ship %d: Health=%03d, Score=%04d\n", shipCnt++, a.ship.getHealth(), a.ship.getScore()); 
      nLive += a.ship.isLive() ? 1 : 0;
      fill(a.ship.myColour);
      text(statusLine, 1, 0);
      translate(0, lineHeight);
    }
    status = String.format("Turn=%04d/%04d, Live Ships=[%d/%d]\n", turn, maxTurns, nLive, nShips);
    fill(#000000);
    text(status, 1, 0);
    popMatrix();
  }
}