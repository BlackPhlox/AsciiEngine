class World{
  int w,h;
  int gridSize;
  int layers = 15;
  
  float scl = 1;
  
  boolean showGrid;
  boolean showLine;
  
  Box2DProcessing box2d;
  Player player;
  
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
  
  void drawWorld(){
    background(0);
    Vec2 pp = world.box2d.getBodyPixelCoord(player.body);
    pushMatrix();
      translate(-(width * (scl - 1) / 2),-(height * (scl - 1) / 2));
      scale(scl);
      pushMatrix();
        translate(-pp.x+width/2, -pp.y+height/2);
        world.displayBackground();
        world.player.display();
        world.displayParticles();
        world.displayForeground();
      popMatrix();
    popMatrix();
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
  
  void inputMovement(){
    if(player != null) {
    PVector delta = new PVector();
    if (goNorth) delta.y += (player.walkSpeed * player.walkSpeedMult);
    if (goSouth) delta.y -= (player.walkSpeed * player.walkSpeedMult);
    if (goEast)  delta.x += (player.walkSpeed * player.walkSpeedMult);
    if (goWest)  delta.x -= (player.walkSpeed * player.walkSpeedMult);
    if (player.crouching){
      delta.x *= player.crouchSpeedRedux;
      delta.y *= player.crouchSpeedRedux;
    } else if (player.running && player.stamina > 0 && player.penalty <= 0) {
        delta.x *= (player.runningSpeed - player.runningSpeedMult+1);
        delta.y *= (player.runningSpeed - player.runningSpeedMult+1);
        if(goNorth||goEast||goSouth||goWest){
            player.stamina -= (player.fatigueRate * player.fatigueMult);
        }
    }
    if(player.stamina <= 0){
        player.penalty = player.recoverRate;
    }
    if(player.penalty == 0 || player.stamina < player.maxStamina){
        player.stamina += player.restitutionRate;
    }
    player.move(delta);

    if(player.penalty > 0) player.penalty--;
    }   
  }
  
  public Vec2 toGrid(Vec2 v){
    return new Vec2(round(v.x/gridSize),round(v.y/gridSize));
  }
  
  Vec2 getPlayerPos(){
    return box2d.getBodyPixelCoord(player.body);
  }
}
