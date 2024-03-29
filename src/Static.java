import org.jbox2d.collision.shapes.PolygonShape;
import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.BodyDef;
import org.jbox2d.dynamics.BodyType;

abstract class Static extends Tile{
  // But we also have to make a body for box2d to know about it
  Body b;
  
  Static(AsciiEngine p, World world,int x, int y){
    super(world,x,y);
    
     int w = world.gridSize;
     int h = world.gridSize;

    // Define the polygon
    PolygonShape sd = new PolygonShape();
    
    // Figure out the box2d coordinates
    float box2dW = p.box2d.scalarPixelsToWorld(w/2);
    float box2dH = p.box2d.scalarPixelsToWorld(h/2);
    
    // We're just a box
    sd.setAsBox(box2dW, box2dH);
    
    //Body created in Static
    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(p.box2d.coordPixelsToWorld(x*world.gridSize,y*world.gridSize));
    b = p.box2d.createBody(bd);
   
    // Attached the shape to the body using a Fixture
    b.createFixture(sd,1);
    
    b.setUserData(this);
  }
}  
