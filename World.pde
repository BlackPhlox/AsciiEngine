class World{
  int w,h;
  int gridSize;
  int layers = 15;
  
  boolean showGrid;
  boolean showLine;
  
  Box2DProcessing box2d;
  
  HashSet<Tile> tiles;
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  PApplet p;
  World(PApplet p, int gridSize,int w, int h){
    this.p = p;
    this.w = w;
    this.h = h;
    this.gridSize = gridSize;
    textSize(gridSize);
    setupPhysics();
    tiles = new HashSet<Tile>();
    for(int y = 0; y < h; y++){
      for(int x = 0; x < w; x++){
        new GhostTile(this,TileType.FLOOR,x,y);
        if(x == 10 && y % 1 == 0) new GhostTile(this,TileType.ROOF,x,y);
        if(x == 5 && y % 2 == 0) new GhostTile(this,TileType.BLOCK,x,y);
        if(x == 8 && y % 4 == 0) new GhostTile(this,TileType.TREE,x,y);
        if(x == 20 && y == 8) new GhostTile(this,TileType.LADDER,x,y);
        if(x == 20 && y == 10) new GhostTile(this,TileType.SQUARE,x,y);
      }
    }
  }
  
  void setupPhysics(){
    // Initialize box2d physics and create the world
    box2d = new Box2DProcessing(p);
    box2d.createWorld();
  
    // Turn on collision listening!
    box2d.listenForCollisions();
    box2d.setGravity(0,0);
  }
  
  void displayBackground(){
    //layers = mouseX;
  }
  
  void displayForeground(){
    for(Tile t : tiles){
      t.display();
    }
  }
  
  void displayParticles(){
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.display();
    // Particles that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    if (p.done()) {
      particles.remove(i);
    }
  }
}
}
