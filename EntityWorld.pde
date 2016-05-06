import java.util.*;

/**
 * Collection of Entities.
 */
class EntityWorld implements Observer
{
  public final int w;
  public final int h;
  public final int binSize;
  public final int wBins;
  public final int hBins;

  HashMap<Entity,Integer> entities = new HashMap();
  HashMap<Integer,ArrayList<Entity>> grid = new HashMap<Integer,ArrayList<Entity>>();
  
  public EntityWorld(int w, int h, int binSize) {
    if(binSize < 5 || binSize > width/2 || binSize > height/2) {
      throw new RuntimeException("Bad bin size.");
    }
    this.w = w;
    this.h = h;
    this.binSize = binSize;
    wBins = (int)Math.ceil((double)w/binSize);
    hBins = (int)Math.ceil((double)h/binSize);
    for(int i = 0 ; i < wBins; i++) {
      for(int j = 0 ; j < hBins; j++) {
        grid.put(j*wBins+i, new ArrayList<Entity>());
      }
    }
  }
  
  /**
   * Add entity.
   */
  public void add(Entity e) {
    int key = getKey(e);
    entities.put(e, key);
    ArrayList<Entity> bucket = getBucket(key);
    bucket.add(e);
  }
  
  /**
   * Remove entity.
   */
  public void remove(Entity e) {
    int key = entities.get(e);
    ArrayList<Entity> bucket = getBucket(key);
    bucket.remove(e);
    entities.remove(e);
  }
  
  /**
   * Update all entities, taking care of bounds and indexes. 
   */
  public void update() {
    List<Entity> _entities = new ArrayList<Entity>(entities.keySet());
    for(int i =0; i < _entities.size(); i++) {
      Entity e = _entities.get(i);
      checkBounds(e);
      e.update();
      updateIndexes(e);
    }
  }
  
  /**
   *
   */
  public void updateIndexes(Entity e) {
    int key = getKey(e);
    if(!entities.get(e).equals(key)) {
      remove(e);
      add(e);
    }
  }
  
  public int getKey(Entity e) {
    int y = ((int)e.loc.y)/binSize;
    int x = ((int)e.loc.x)/binSize;
    return wBins*y+x;
  }
  
  public ArrayList<Entity> getBucket(int key) {
    ArrayList<Entity> bucket = grid.get(key);
    if(bucket == null) {
      bucket = new ArrayList<Entity>();
      grid.put(key,  bucket);
    }
    return bucket;
  }
  
  public int[] keyToArray(int key) {
    return new int[] {key%wBins, key/wBins}; 
  }
  
  public void checkBounds(Entity e) {
    if(e.loc.x <= 0 || e.loc.x >= width) {
       e.vel.x = -1*e.vel.x;
    }
    if(e.loc.y <= 0 || e.loc.y >= height) {
       e.vel.y = -1*e.vel.y;
    }
  }
  
  public void draw() {
    update();
    for(Map.Entry<Integer,ArrayList<Entity>> bucket : grid.entrySet()) {
      int size = bucket.getValue().size();
      if(size > 0) {
        int[] i = keyToArray(bucket.getKey());
        fill(255-size*20); 
        rect(i[0]*binSize, i[1]*binSize, binSize, binSize);
        println("Bucket " + " " + i[0] + " " + i[1] + " " + size);
      }
    }
    for(Entity e : entities.keySet()) {
      println(getKey(e) + ", " + keyToArray(getKey(e))[0] + ", " + keyToArray(getKey(e))[1]); 
      e.draw();
    }
  }

  
  public void update(Observable o, Object arg) {
    Entity target = (Entity)o;
    entities.remove(target);
  }
}