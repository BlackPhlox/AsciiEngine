import org.jbox2d.collision.shapes.CircleShape;
import org.jbox2d.common.Vec2;
import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.BodyDef;
import org.jbox2d.dynamics.BodyType;
import org.jbox2d.dynamics.FixtureDef;
import processing.core.PApplet;
import processing.core.PVector;

import static processing.core.PApplet.println;

class Particle {
  // We need to keep track of a Body and a radius
  Body body;
  float r;
  int col;
  
  long lifeStart;
  int collisions;
  float minVelocity = 5;
  
  boolean isBullet;
  AsciiEngine p;

  Particle(AsciiEngine p, float x, float y, Vec2 direction, float r_, boolean isBullet) {
    this.p = p;
    r = r_;
    if(r <= 1){
      println("Particle not visible due to a too small radius");
    }
    this.isBullet = isBullet;
    if(isBullet) r = 1;
    makeBody(x, y, r);
    body.setLinearVelocity(direction);
    body.setUserData(this);
    col = p.color(175);
    lifeStart = p.millis();
  }

  // This function removes the particle from the box2d world
  void killBody() {
    p.box2d.destroyBody(body);
  }
  
  void incCollision(){
    collisions++;
  }

  // Change color when hit
  void change() {
    col = p.color(255, 0, 0);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = p.box2d.getBodyPixelCoord(body);
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
    if(p.millis() - lifeStart > 3000){
      killBody();
      return true;
    }
    if (pos.y > p.height+r*2) {
      killBody();
      return true;
    }
    return false;
  }


  Vec2 pos;
  Vec2 prePos;
  void display() {
    
    if(isBullet && pos!=null && p.frameCount % 2 == 0){
      prePos = pos;
    }

    // We look at each body and get its screen position
    pos = p.box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    
    if(isBullet){
        p.stroke(255);
      if(prePos != null) p.line(pos.x,pos.y,prePos.x, prePos.y);
    } else {
      float a = body.getAngle();
        p.pushMatrix();
        p.translate(pos.x, pos.y);
        p.rotate(a);
        p.fill(col);
        p.stroke(0);
        p.strokeWeight(1);
        p.ellipse(0, 0, r*2, r*2);
        // Let's add a line so we can see the rotation
        p.line(0,0,r,0);
        p.popMatrix();
    }
  }

  // Here's our function that adds the particle to the Box2D world
  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = p.box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = p.box2d.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = p.box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.01f;
    fd.restitution = 0.3f; //Bounciness on walls
    
    //also set continues collision check
    //body.setBullet(true);
    //raycast?

    // Attach fixture to body
    body.createFixture(fd);

    //beanbag/ rubber ball
    //body.setAngularVelocity(random(-10, 10));
  }
}
