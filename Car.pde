class Car extends Vehicle {
  String disc;
  int w,h;
  Drivetrain drivetrain;
  
  Player player;
  
  boolean parked, driving, neutral;
  
  Car(int x, int y, int w, int h, Drivetrain dt){
    this.w = w;
    this.h = h;
    this.drivetrain = dt;
    makeBody(x,y,w,h);
    body.setUserData(this);
  }
  
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = world.box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    

    float a = body.getAngle();
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(a*-1);
      //fill(255);
      noFill();
      stroke(255);
      //rect(0,0,w,h);
      rect(0,0,w,h);
      // Let's add a line so we can see the rotation
      line(0,0,w/2,0);
      
    
    if(player != null && mousePressed){
      PVector mos = new PVector(mouseX,mouseY);
      PVector screen = new PVector(width/2,height/2);
      PVector s = PVector.sub(new PVector(mos.x,mos.y*-1),new PVector(screen.x,screen.y*-1));      
      move(s,150);
    }
    popMatrix();
    
  }
  
  void move(PVector p, float vel){
    Vec2 movementFrom = new Vec2();
    if(drivetrain != Drivetrain.AW){
      float a = body.getAngle();
      Vec2 v1 = new Vec2();
      if(drivetrain == Drivetrain.FW){
        v1 = new Vec2(w/2,0);
      } else if(drivetrain == Drivetrain.BW){
        v1 = new Vec2(-w/2,0);   
      }
      PVector v2 = new PVector(v1.x,v1.y);
      v2.rotate(a);
      movementFrom = new Vec2(v2.x,v2.y);   
    }
    //Debug start
    pushStyle();
    stroke(255,0,0);
    strokeWeight(5);
    pushMatrix();
      float a = body.getAngle();
      rotate(a*-1);
      translate(movementFrom.x,movementFrom.y);
      point(0,0);
    popMatrix();
    popStyle();
    //Debug end
    p.setMag(vel);
    body.applyForce(new Vec2(p.x,p.y),movementFrom);
    body.setAngularVelocity(0);
  }
  
  void makeBody(float x, float y, float w, float h) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = world.box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = world.box2d.createBody(bd);
    body.setLinearDamping(2);
    
    body.setAngularDamping(2);

    // Define the polygon
    PolygonShape sd = new PolygonShape();
    
    // Figure out the box2d coordinates
    float box2dW = world.box2d.scalarPixelsToWorld(w/2);
    float box2dH = world.box2d.scalarPixelsToWorld(h/2);
    
    // We're just a box
    sd.setAsBox(box2dW, box2dH);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;

    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.01;
    fd.restitution = 0.3; //Bounciness on walls

    // Attach fixture to body
    body.createFixture(fd);

    //beanbag/ rubber ball
    //body.setAngularVelocity(random(-10, 10));
  }
}
