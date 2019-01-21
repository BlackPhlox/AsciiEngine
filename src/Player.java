import org.jbox2d.collision.shapes.CircleShape;
import org.jbox2d.common.Vec2;
import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.BodyDef;
import org.jbox2d.dynamics.BodyType;
import org.jbox2d.dynamics.FixtureDef;
import processing.core.PApplet;
import processing.core.PVector;

class Player{
  boolean showMap = false;
  PVector mouseDirection;
  int radius;
  AsciiEngine p;
  
  //Movement
  public float maxStamina = 100f,
            restitutionRate = 0.2f,
            fatigueRate = 0.5f,
            fatigueMult = 1,
            recoverRate = 100,
            totalWeight = 5;
  public float stamina = maxStamina;
  float walkSpeed = 3;
    float walkSpeedMult = 2;
    float runningSpeed = 2;
    float runningSpeedMult = 1;
    float crouchSpeedRedux = 0.5f;
            
  Player(AsciiEngine p, int x, int y, int r){
    this.radius = r;
    this.p = p;
    setupPhysics(x,y);
  }
  
  Body body;
  void setupPhysics(int x, int y){
    makeBody(x, y, radius);
    body.setUserData(this);
  }

  void display() {
    Vec2 pos = p.box2d.getBodyPixelCoord(body);
    p.pushMatrix();
      p.fill(100);
      p.translate(pos.x, pos.y);
      p.stroke(0);
      p.strokeWeight(1);
      //Calc mouseDirection
      mouseDirection = PVector.sub(new PVector(p.mouseX,p.mouseY),new PVector(p.width/2,p.height/2));
      p.rotate(mouseDirection.heading());
      p.fill(255);
      p.ellipse(0, 0, radius*2, radius*2);
      p.line(0, 0, radius, 0);
    p.popMatrix();
  }
  
  int miniMapGridSize = 5;
  void displayMiniMap(){
    Vec2 pos = p.box2d.getBodyPixelCoord(body);
    Vec2 posGrid = AsciiEngine.toGrid(pos,p.world.gridSize);
    p.pushMatrix();
    p.pushStyle();
    p.stroke(0);
      p.translate(100,100);
        p.pushMatrix();
        p.translate((-posGrid.x*miniMapGridSize),(-posGrid.y*miniMapGridSize));
        p.fill(255,50);
        for(Tile t : p.world.tiles){
            p.rect(t.x*miniMapGridSize,t.y*miniMapGridSize,miniMapGridSize,miniMapGridSize);
        }
        p.popMatrix();
      p.rect(0,0,miniMapGridSize,miniMapGridSize);
      p.popStyle();
      p.popMatrix();
  }
  
  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = p.box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = p.box2d.createBody(bd);
    body.setLinearDamping(5);
    body.setFixedRotation(true);
    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = p.box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.01f;
    fd.restitution = 0.3f;

    // Attach fixture to body
    body.createFixture(fd);
  }
  
  void move(PVector p){
    body.setLinearVelocity(new Vec2(p.x,p.y));
    body.setAngularVelocity(0);
  }
}
