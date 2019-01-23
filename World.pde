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
  ArrayList<Item> items = new ArrayList<Item>();
  
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
  
  void update(){
    pushMatrix();
      player.inputMouse();
      inputMovement();
      box2d.step();
      drawWorld();
      displayKeyboardAim();
      aimMovement();
    popMatrix();
  }
  
  void drawWorld(){
    background(0);
    Vec2 pp = world.box2d.getBodyPixelCoord(player.body);
    pushMatrix();
      translate(-(width * (scl - 1) / 2),-(height * (scl - 1) / 2));
      scale(scl);
      pushMatrix();
        translate(-pp.x+width/2, -pp.y+height/2);
        displayBackground();
        player.display();
        displayItems();
        displayParticles();
        displayTiles();
      popMatrix();
    popMatrix();
  }
  
  void displayBackground(){
    //layers = mouseX;
  }
  
  void displayTiles(){
    for(Tile t : tiles){
      t.display();
    }
  }
  
  void displayItems(){
    for(Item i : items){
      i.display();
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
  
  void displayKeyboardAim(){
    if(player.keyBoardAim){
      pushStyle();
        stroke(255);
        strokeWeight(5);
        point(player.cursor.x,player.cursor.y);
      popStyle();
    }
  }
  
  void aimMovement(){
    if(player != null && player.keyBoardAim) {
      PVector delta = new PVector();
      if(aimGoNorth) delta.add(0,-1*player.cursorMovementSpeed);
      if(aimGoSouth) delta.add(0,1*player.cursorMovementSpeed);
      if(aimGoEast)  delta.add(1*player.cursorMovementSpeed,0);
      if(aimGoWest)  delta.add(-1*player.cursorMovementSpeed,0);
      player.cursor.add(delta);
    }
  }
  
  void inputMovement(){
    if(player != null) {
      player.running =   (playerShift ? true : false);
      player.crouching = (playerCtrl ? true : false);
      PVector delta = new PVector();
      if (playerGoNorth) delta.y += (player.walkSpeed * player.walkSpeedMult);
      if (playerGoSouth) delta.y -= (player.walkSpeed * player.walkSpeedMult);
      if (playerGoEast)  delta.x += (player.walkSpeed * player.walkSpeedMult);
      if (playerGoWest)  delta.x -= (player.walkSpeed * player.walkSpeedMult);
      if (player.crouching){
        delta.x *= player.crouchSpeedRedux;
        delta.y *= player.crouchSpeedRedux;
      } else if (player.running && player.stamina > 0 && player.penalty <= 0) {
          delta.x *= (player.runningSpeed - player.runningSpeedMult+1);
          delta.y *= (player.runningSpeed - player.runningSpeedMult+1);
          if(playerGoNorth||playerGoEast||playerGoSouth||playerGoWest){
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
