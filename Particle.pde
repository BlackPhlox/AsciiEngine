class Particle {
  // We need to keep track of a Body and a radius
  Body body;
  float r;
  color col;
  
  long lifeStart;
  int collisions;
  float minVelocity = 5;
  
  boolean isBullet;

  Particle(float x, float y, Vec2 direction, float r_, boolean isBullet) {
    r = r_;
    if(r <= 1){
      println("Particle not visible due to a too small radius");
    }
    this.isBullet = isBullet;
    if(isBullet) r = 1;
    makeBody(x, y, r);
    body.setLinearVelocity(direction);
    body.setUserData(this);
    col = color(175);
    lifeStart = millis();
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }
  
  void incCollision(){
    collisions++;
  }

  // Change color when hit
  void change() {
    col = color(255, 0, 0);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    
    Vec2 lv = body.getLinearVelocity();
    if(new PVector(lv.x,lv.y).mag() < minVelocity){
      killBody();
      return true;
    }
    if(collisions > 3){
      killBody();
      return true;
    }
    if(millis() - lifeStart > 3000){
      killBody();
      return true;
    }
    if (pos.y > height+r*2) {
      killBody();
      return true;
    }
    return false;
  }


  Vec2 pos;
  Vec2 prePos;
  void display() {
    
    if(isBullet && pos!=null && frameCount % 2 == 0){
      prePos = pos;
    }

    // We look at each body and get its screen position
    pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    
    if(isBullet){
      stroke(255);
      if(prePos != null) line(pos.x,pos.y,prePos.x, prePos.y);
    } else {
      float a = body.getAngle();
      pushMatrix();
        translate(pos.x, pos.y);
        rotate(a);
        fill(col);
        stroke(0);
        strokeWeight(1);
        ellipse(0, 0, r*2, r*2);
        // Let's add a line so we can see the rotation
        line(0,0,r,0);
      popMatrix();
    }
  }

  // Here's our function that adds the particle to the Box2D world
  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

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
