abstract class StaticTile extends Tile{
  // But we also have to make a body for box2d to know about it
  Body b;
  
  StaticTile(World world,int x, int y){
    super(world,x,y);
    
     int w = world.gridSize;
     int h = world.gridSize;

    // Define the polygon
    PolygonShape sd = new PolygonShape();
    
    // Figure out the box2d coordinates
    float box2dW = world.box2d.scalarPixelsToWorld(w/2);
    float box2dH = world.box2d.scalarPixelsToWorld(h/2);
    
    // We're just a box
    sd.setAsBox(box2dW, box2dH);
    
    //Body created in Static
    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(world.box2d.coordPixelsToWorld(x*world.gridSize,y*world.gridSize));
    b = world.box2d.createBody(bd);
   
    // Attached the shape to the body using a Fixture
    b.createFixture(sd,1);
    
    b.setUserData(this);
  }
}  
