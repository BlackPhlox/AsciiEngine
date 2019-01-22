class Player{
  boolean showMap = false;
  PVector mouseDirection;
  int radius;
  
  //Movement
  public float maxStamina = 100,
            restitutionRate = 0.2,
            fatigueRate = 0.5,
            fatigueMult = 1,
            recoverRate = 100,
            totalWeight = 5;
  public float stamina = maxStamina;
  private float walkSpeed = 3, walkSpeedMult = 2,
          runningSpeed = 2, runningSpeedMult = 1,
          crouchSpeedRedux = 0.5;
            
  Player(int x, int y, int r){
    this.radius = r;
    setupPhysics(x,y);
  }
  
  Body body;
  void setupPhysics(int x, int y){
    makeBody(x, y, radius);
    body.setUserData(this);
  }
  
  void display() {
    Vec2 pos = world.box2d.getBodyPixelCoord(body);
    pushMatrix();
      fill(100);
      translate(pos.x, pos.y);
      stroke(0);
      strokeWeight(1);
      //Calc mouseDirection
      mouseDirection = PVector.sub(new PVector(mouseX,mouseY),new PVector(width/2,height/2));
      rotate(mouseDirection.heading());
      fill(255);
      ellipse(0, 0, radius*2, radius*2);
      line(0, 0, radius, 0);
    popMatrix();
  }
  
  int miniMapGridSize = 5;
  void displayMiniMap(){
    Vec2 pos = world.box2d.getBodyPixelCoord(body);
    Vec2 posGrid = toGrid(pos,world.gridSize);
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
}
