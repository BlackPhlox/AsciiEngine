class Player extends Human{
  boolean showMiniMap = false;
  PVector mouseDirection;
  int radius;
  
  //Movement
  float maxStamina = 100,
            restitutionRate = 0.2,
            fatigueRate = 0.5,
            fatigueMult = 1,
            recoverRate = 100,
            totalWeight = 5;
  float stamina = maxStamina;
  private float walkSpeed = 3, walkSpeedMult = 2,
          runningSpeed = 2, runningSpeedMult = 1,
          crouchSpeedRedux = 0.5;
  float penalty;
  
  //Player states
  boolean running,crouching,shooting,aiming,driving;
  
  Vehicle vehicle;
  PlayerGUI pgui;
  
  //Control interface
  boolean keyBoardAim = false;
  PVector cursor = new PVector(width/2,height/2);
  float cursorMovementSpeed = 5;
  
  //Minimap
  int miniMapGridSize = 5;
  
  //Aim Zoom
  float zoom;
  float mouseZoom;
  
  //Specified by the weapon
  float maxZoom = 500;
  float zoomInSpeed = 0.05;
  float zoomOutSpeed = 0.2;
  float minVel = 100;
  float maxVel = 120;
  
  int bpm = 60;
            
  Player(PApplet p,int x, int y, int r){
    pgui = new PlayerGUI(p);
    this.radius = r;
    setupPhysics(x,y);
  }
  
  void setupPhysics(int x, int y){
    makeBody(x, y, radius);
    body.setUserData(this);
  }
  
  void display() {
    pgui.updateHeartbeatSensor(); 
    Vec2 pos;
    if(driving){
      if(body.isActive()) body.setActive(false);
      pos = world.box2d.getBodyPixelCoord(vehicle.body);
    } else {
      if(!body.isActive()) body.setActive(true);
      pos = world.box2d.getBodyPixelCoord(body);
    }    
    pushMatrix();
      fill(100);
      translate(pos.x, pos.y);
      stroke(0);
      strokeWeight(1);
      //Calc mouseDirection
      if(keyBoardAim){
        mouseDirection = PVector.sub(cursor,new PVector(width/2,height/2));
      } else {
        mouseDirection = PVector.sub(new PVector(mouseX,mouseY),new PVector(width/2,height/2));
      }
      rotate(mouseDirection.heading());
      fill(255);
      ellipse(0, 0, radius*2, radius*2);
      line(0, 0, radius, 0);
    popMatrix();
  }
  
  void displayMiniMap(){
    Vec2 pos = world.box2d.getBodyPixelCoord(body);
    Vec2 posGrid = world.toGrid(pos);
    pushMatrix();
    pushStyle();
    stroke(0);
      translate(100,100);
        pushMatrix();
        translate((-posGrid.x*miniMapGridSize),(-posGrid.y*miniMapGridSize));
        fill(255,50);
        for(Tile t : world.tiles){
          square(t.x*miniMapGridSize,t.y*miniMapGridSize,miniMapGridSize);
        }
        popMatrix();
      square(0,0,miniMapGridSize);
    popStyle();
    popMatrix();
  }
  
  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = world.box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = world.box2d.createBody(bd);
    body.setLinearDamping(5);
    body.setFixedRotation(true);
    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = world.box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.01;
    fd.restitution = 0.3;

    // Attach fixture to body
    body.createFixture(fd);
  }
  
  void move(PVector p){
    body.setLinearVelocity(new Vec2(p.x,p.y));
    body.setAngularVelocity(0);
  }
  
  void inputMouse(){
    shooting = (leftPress  || playerSpace ? true : false);
    aiming =   (rightPress || playerLessThan ? true : false);
    if(mouseDirection != null){
        float sz = 2;//random(4, 8);
        Vec2 pp = world.getCameraPos();
        
        mouseZoom = getMouseAimZoom(pp);
        PVector p2 = particlesSpawnPos(pp,mouseDirection);
        
        if(aiming){
          zoom = lerp(zoom,mouseZoom,zoomInSpeed);
          mouseDirection.setMag(zoom);
          translate(mouseDirection.x*-1,mouseDirection.y*-1);
        }
        
        float ran = random(minVel,maxVel);
        mouseDirection.setMag(ran);
        
        boolean isBullet = true;
        if(shooting && !driving) world.particles.add(new Particle(p2.x,p2.y,new Vec2(mouseDirection.x*0.5,mouseDirection.y*-1*0.5), sz, isBullet));
        if(mouseDirection != null){
          mouseDirection.setMag(zoom);
          translate(mouseDirection.x*-1,mouseDirection.y*-1);
        }
    }
    zoom = lerp(zoom,0,zoomOutSpeed);
  }

  float getMouseAimZoom(Vec2 playerPos){
    return constrain(PVector.dist(new PVector(playerPos.x,playerPos.y),mouseDirection),0,maxZoom);
  }
  
  //Normalizes the mouseDirection Vector
  PVector particlesSpawnPos(Vec2 playerPos, PVector mouseDirection){
    mouseDirection.normalize();
    return PVector.add(new PVector(playerPos.x,playerPos.y),mouseDirection);
  }
  
  Dynamic getNearest(){
    return getNearest(Dynamic.class);
  }
  
  Dynamic getNearest(Class c){
    float nearestDist = Float.MAX_VALUE;
    Dynamic nearest = null;
    for(Dynamic d : world.dynamics){
      if(d.body != null /*&& d.getClass() == c  <- Get NullPointer*/){
        PVector v = new PVector(world.box2d.getBodyPixelCoord(d.body).x,world.box2d.getBodyPixelCoord(d.body).y);
        PVector pp = new PVector(world.getCameraPos().x,world.getCameraPos().y);
        if(PVector.dist(v,pp) < nearestDist){
          nearestDist = PVector.dist(v,pp);
          nearest = d;
        }
      }
    }
    return nearest;
  }
}
