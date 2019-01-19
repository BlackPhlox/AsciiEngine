class Player{
  boolean showMap = false;
  PVector mouseDirection;
  Player(int x, int y){
    setupPhysics(x,y);
  }
  
  Body body;
  void setupPhysics(int x, int y){
    makeBody(x, y, 10);
    body.setUserData(this);
  }
  
  void display() {
    // We look at each body and get its screen position
    fill(100);
    //body.setTransform(new Vec2(pos.x,pos.y*-1),0.1);
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    stroke(0);
    strokeWeight(1);
    ellipse(0, 0, 10*2, 10*2);
    // Let's add a line so we can see the rotation
    line(0, 0, 10, 0);
    pushMatrix();
    //Calc mouseDirection
    mouseDirection = PVector.sub(new PVector(mouseX,mouseY),new PVector(width/2,height/2));
    rotate(mouseDirection.heading());
    ellipse(0, 0, 10, 10);
    line(0, 0, 5, 0);
    popMatrix();
    popMatrix();
    if(showMap) drawMiniMap();
  }
  
  int mapGridSize = 5;
  void drawMiniMap(){
    Vec2 pos = box2d.getBodyPixelCoord(body);
    Vec2 posGrid = toGrid(pos,world.gridSize);
    pushStyle();
    pushMatrix();
    translate(pos.x-width/2+100,pos.y-height/2+100);
    pushMatrix();
    translate((-posGrid.x*mapGridSize),(-posGrid.y*mapGridSize));
    fill(255,50);
    for(Tile t : world.tiles){
      rect(t.x*mapGridSize,t.y*mapGridSize,mapGridSize,mapGridSize);
    }
    popMatrix();
    rect(0,0,mapGridSize,mapGridSize);
    popStyle();
    popMatrix();
  }
  
  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.createBody(bd);
    body.setLinearDamping(5);
    body.setFixedRotation(true);
    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

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
