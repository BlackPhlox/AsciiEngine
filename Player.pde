class Player{
  boolean showMap = false;
  PVector mouseDirection;
  int r;
  Player(int x, int y, int r){
    this.r = r;
    setupPhysics(x,y);
  }
  
  Body body;
  void setupPhysics(int x, int y){
    makeBody(x, y, r);
    body.setUserData(this);
  }
  
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
      fill(100);
      translate(pos.x, pos.y);
      stroke(0);
      strokeWeight(1);
      //Calc mouseDirection
      mouseDirection = PVector.sub(new PVector(mouseX,mouseY),new PVector(width/2,height/2));
      rotate(mouseDirection.heading());
      fill(255);
      ellipse(0, 0, r*2, r*2);
      line(0, 0, r, 0);
    popMatrix();
  }
  
  int mapGridSize = 5;
  void displayMiniMap(){
    Vec2 pos = box2d.getBodyPixelCoord(body);
    Vec2 posGrid = toGrid(pos,world.gridSize);
    pushMatrix();
    pushStyle();
    stroke(0);
      translate(100,100);
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
