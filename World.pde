class World{
  int w,h;
  int gridSize;
  int layers = 10;
  int depthDensity = 15;
  
  float scl = 1;
  
  boolean showGrid;
  boolean showLine;
  
  Box2DProcessing box2d;
  Player player;
  
  HashSet<Tile> tiles;
  ArrayList<Dynamic> dynamics  = new ArrayList<Dynamic>();
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  //World without a player
  PVector worldPos = new PVector();
  float worldMovementSpeed = 2;
  float worldMovementSpeedShift = 2;
  
  PApplet p;
  
  World(PApplet p,int w, int h){
    this(p,12,w,h);
  }
  
  World(PApplet p, int gridSize,int w, int h){
    this.p = p;
    this.w = w;
    this.h = h;
    this.gridSize = gridSize;
    textSize(gridSize);
    setupPhysics();
    tiles = new HashSet<Tile>();
    rectMode(CENTER);
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
      if(player != null) player.inputMouse();
      inputMovement();
      box2d.step();
      translate(worldPos.x,worldPos.y);
      drawWorld();
      if(player != null){
        displayKeyboardAim();
        aimMovement();
        if(player.showMiniMap) player.displayMiniMap();
      }
    popMatrix();
  }
  
  void drawWorld(){
    background(0);
    Vec2 pp = getPlayerPos();
    pushMatrix();
      //Translate for scale in the center
      translate(-(width * (scl - 1) / 2),-(height * (scl - 1) / 2));
      scale(scl);
      pushMatrix();
        translate(-pp.x+width/2, -pp.y+height/2);
        displayBackground();
        if(player != null) player.display();
        displayDynamics();
        displayParticles();
        displayTiles();
        TilePainter tp = new TilePainter(world);
        tp.drawCustom(20,34);
        tp.drawCustom(21,34);
        tp.drawCustom(22,34);
        tp.drawCustom(23,34);
        tp.drawCustom(24,34);
        tp.drawCustom(25,34);
        tp.drawCustom(26,34);
        tp.drawCustom(27,34);
        tp.drawCustom(28,34);
        
      popMatrix();
    popMatrix();
  }
  
  void displayBackground(){
    //layers = mouseX;
    //depthDensity = mouseY-100;
  }
  
  void displayTiles(){
    for(Tile t : tiles){
      t.display();
    }
  }
  
  void displayDynamics(){
    for(Dynamic d : dynamics){
      d.display();
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
      if(player.penalty < 0 || player.stamina < player.maxStamina){
          player.stamina += player.restitutionRate;
      }
      
      player.move(delta);
  
      if(player.penalty > 0) player.penalty--;
    } else {
      PVector delta = new PVector();
      if (goNorth) delta.y += worldMovementSpeed;
      if (goSouth) delta.y -= worldMovementSpeed;
      if (goEast)  delta.x -= worldMovementSpeed;
      if (goWest)  delta.x =  worldMovementSpeed;
      if (playerShift) delta.mult(worldMovementSpeedShift);
      worldPos.add(delta);
    }   
  }
  
  public Vec2 toGrid(Vec2 v){
    return new Vec2(round(v.x/gridSize),round(v.y/gridSize));
  }
  
  Vec2 getPlayerPos(){
    if(player == null) {
      //No player found, set camera to world position (default is the center of the world)
      PVector p = PVector.sub(new PVector(w*gridSize/2,h*gridSize/2),worldPos);
      return new Vec2(p.x,p.y);
    }
    return box2d.getBodyPixelCoord(player.body);
  }
}
