class NPC extends Dynamic{
  PVector mouseDirection;
  int radius;
  
  String name;
  
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
  boolean running,crouching,shooting,aiming;
  
            
  NPC(int x, int y, int r, String name){
    this.name = name;
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
    PVector p = new PVector(world.getPlayerPos().x,world.getPlayerPos().y*-1);
    if(PVector.dist(new PVector(world.getPlayerPos().x,world.getPlayerPos().y),new PVector(pos.x,pos.y))>35) move(p.sub(new PVector(pos.x,pos.y*-1)));
    pushMatrix();
      translate(pos.x, pos.y);
      stroke(0);
      strokeWeight(1);
      fill(255);
      text(name,-textWidth(name)/2,-radius);
      //Calc mouseDirection
      mouseDirection = PVector.sub(new PVector(world.getPlayerPos().x,world.getPlayerPos().y),new PVector(pos.x,pos.y));
      rotate(mouseDirection.heading());
      fill(255);
      ellipse(0, 0, radius*2, radius*2);
      line(0, 0, radius, 0);
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
    body.applyForce(new Vec2(p.x,p.y),body.getLocalCenter());
    body.setAngularVelocity(0);
  }
  
  float maxZoom = 500;
  float zoomInSpeed = 0.05;
  float zoomOutSpeed = 0.2;
  float minVel = 100;
  float maxVel = 120;
  
  void inputMouse(){
    shooting = (leftPress  || playerSpace ? true : false);
    aiming =   (rightPress || playerLessThan ? true : false);
    if(mouseDirection != null){
        float sz = 2;//random(4, 8);
        Vec2 pp = world.getPlayerPos();
        
        PVector p2 = particlesSpawnPos(pp,mouseDirection);
        
        float ran = random(minVel,maxVel);
        mouseDirection.setMag(ran);
        
        boolean isBullet = true;
        if(shooting) world.particles.add(new Particle(p2.x,p2.y,new Vec2(mouseDirection.x*0.5,mouseDirection.y*-1*0.5), sz, isBullet));
    }
  }

  
  //Normalizes the mouseDirection Vector
  PVector particlesSpawnPos(Vec2 playerPos, PVector mouseDirection){
    mouseDirection.normalize();
    return PVector.add(new PVector(playerPos.x,playerPos.y),mouseDirection);
  }
}
