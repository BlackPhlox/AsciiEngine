class Item extends Dynamic{
  String name;
  String disc;
  int r;
  
  Item(int x, int y, int r, String name){
    this.name = name;
    this.r = r;
    makeBody(x,y,r);
    body.setUserData(this);
  }
  
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = world.box2d.getBodyPixelCoord(body);
    // Get its angle of rotation

    float a = body.getAngle();
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(a);
      
      fill(255);
      ellipse(0,0,r*2,r*2);
      text(name,-textWidth(name)/2,-r);
      
      // Let's add a line so we can see the rotation
      line(0,0,r,0);
    popMatrix();
    
  }
  
  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = world.box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = world.box2d.createBody(bd);
    body.setLinearDamping(2);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = world.box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;

    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.01;
    fd.restitution = 0.3; //Bounciness on walls
    
    //also set continues collision check
    //body.setBullet(true);
    //raycast?

    // Attach fixture to body
    body.createFixture(fd);

    //beanbag/ rubber ball
    //body.setAngularVelocity(random(-10, 10));
  }
}
