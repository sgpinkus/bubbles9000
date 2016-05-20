import java.util.*;

/**
 * Collection of Entities.
 * This class is responsible for update the location of all it's entities, and mapping that location to a grid bin.
 * the grid of bins allows this classs to implement the getHood() method efficiently.
 * Also handles collision detection on each update().
 */
class EntityWorld implements Observer, Iterable<Entity>
{
  public final int w;
  public final int h;
  public final int binSize;
  public final int wBins;
  public final int hBins;

  HashMap<Entity,Integer> entities = new HashMap();
  HashMap<Integer,ArrayList<Entity>> grid = new HashMap<Integer,ArrayList<Entity>>();
  
  public EntityWorld(int w, int h, int binSize) {
    if(binSize < 5 || binSize > w/2 || binSize > h/2) {
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
   * @todo throw if e's bounds don't fit in a bin.
   */
  public void add(Entity e) {
    int key = getKey(e);
    entities.put(e, key);
    ArrayList<Entity> bucket = getBucket(key);
    bucket.add(e);
    e.addObserver(this);
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
  
  public int size() {
    return entities.size();
  }
  
  /**
   * Update all entities, taking care of bounds and indexes. 
   */
  public void update() {
    List<Entity> _entities = new ArrayList<Entity>(entities.keySet());
    for(int i = _entities.size()-1; i >= 0; i--) {
      Entity e = _entities.get(i);
      checkBounds(e);
      collisions(e);
      e.update();
      if(!e.isLive()) {
        remove(e);
      }
      else {
        updateIndexes(e); // Must come after e.update().
      }
    }
  }

  /**
   * Get the neighbourhood (9 bins) of e.
   */
  public ArrayList<Entity> getHood(Entity e) {
    ArrayList<Entity> nHood = new ArrayList<Entity>();
    if(entities.get(e) == null) {
      throw new RuntimeException();
    }
    int[] c = keyToArray(getKey(e));
    for(int i = c[1]-1; i <= c[1]+1; i++) {
      for(int j = c[0]-1; j <= c[0]+1; j++) {
        nHood.addAll(getBucket(arrayToKey(new int []{j,i})));
      }
    }
    return nHood;
  }
  
  /**
   * Get the bin key of e
   */
  public int getKey(Entity e) {
    int y = ((int)e.loc.y)/binSize;
    int x = ((int)e.loc.x)/binSize;
    return wBins*y+x;
  }
  
  /**
   * Get the bin corresponding to key.
   */
  public ArrayList<Entity> getBucket(int key) {
    ArrayList<Entity> bucket = grid.get(key);
    if(bucket == null) {
      bucket = new ArrayList<Entity>();
      grid.put(key,  bucket);
    }
    return bucket;
  }
  
  /**
   * Turn an integer bin key back into a 2tuple coordinate.
   */
  public int[] keyToArray(int key) {
    return new int[] {key%wBins, key/wBins}; 
  }
  
  /**
   * Turn a 2tuple into a bin key.
   */
  public int arrayToKey(int[] c) {
    return c[1]*wBins + c[0]; 
  }
  
  /**
   * Check if e out of bound, and *modify* trajectory if so.
   */
  private void checkBounds(Entity e) {
    if(e.loc.x <= 0 || e.loc.x >= w) {
       if(e.isMassive()) 
         e.vel.x = -1*e.vel.x;
       else
         e.kill();
    }
    if(e.loc.y <= 0 || e.loc.y >= h) {
      if(e.isMassive())
        e.vel.y = -1*e.vel.y;
      else
        e.kill();
    }
  }
  
  /**
   * Finds all colliding objects and adjusts their velocities accordingly.
   * Just assumes every thing has the same mass.
   */
  private void collisions(Entity e) {
    for(Entity n : getHood(e)) {
      if(e.intersects(n) && e.id < n.id) {
        PVector incident = n.loc.copy().sub(e.loc).normalize();
        PVector[] componentsE = project(incident, e.vel);
        PVector projE = componentsE[0];
        PVector perpE = componentsE[1];
        PVector[] componentsN = project(incident, n.vel);
        PVector projN = componentsN[0];
        PVector perpN = componentsN[1];
        // Determine the speed of n along the incident vector between e and n. Iff its -ve they are colliding.
        PVector closing = projE.copy().sub(projN);
        if(closing.dot(incident) > 0) {
          //System.out.format("Collision detected: %s, %s\n", projE, projN);
          if(e.isMassive() && n.isMassive()) {
            e.vel = perpE.add(projE.sub(closing));
            n.vel = perpN.add(projN.add(closing));
          }
          Entity first = e;
          Entity second = n;
          PVector firstClosing = closing.copy();
          if(e.collisionOrder() > n.collisionOrder()) {
            first = n;
            second = e;
            firstClosing.mult(-1.0);
          }
          first.collision(second, firstClosing.mult(-1.0));
          second.collision(first, firstClosing.mult(-1.0));
        }
      }
    }
  }
  
  /**
   * Ensure the Entity is in the correct bin.
   */
  private void updateIndexes(Entity e) {
    int key = getKey(e);
    if(!entities.get(e).equals(key)) {
      remove(e);
      add(e);
    }
  }
  
  /**
   * Draw the grid and delegate draw to all contained entities.
   */
  public void draw() {
    for(Map.Entry<Integer,ArrayList<Entity>> bucket : grid.entrySet()) {
      int size = bucket.getValue().size();
      if(size > 0) {
        int[] i = keyToArray(bucket.getKey());
        fill(255-size*20); 
        rect(i[0]*binSize, i[1]*binSize, binSize, binSize);
        //println("Bucket " + " " + i[0] + " " + i[1] + " " + size);
      }
    }
    for(Entity e : entities.keySet()) {
      //println(getKey(e) + ", " + keyToArray(getKey(e))[0] + ", " + keyToArray(getKey(e))[1]); 
      e.draw();
    }
  }
  
  public Iterator<Entity> iterator() {
    return entities.keySet().iterator();
  }

  /**
   * Callback for Entity events.
   */
  public void update(Observable o, Object arg) {
    println("NOTIFCATION!!");
    Entity target = (Entity)o;
    remove(target);
  }
}