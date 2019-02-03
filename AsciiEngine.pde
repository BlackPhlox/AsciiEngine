//NATIVE
import java.util.*;
//GUI
import controlP5.*;
//PHYSICS
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

World world;
int fps = 60;
boolean isDebugging = true;

void setup() {
  size(600, 600);
  //fullScreen();
  world = new World(this, 200, 200);
  createWorld();
  world.player = new Player(this,100, 100, 5);
  world.dynamics.add(new Firearm(200, 150, 10, "AK47", new WeaponSetting()));
  
  NPC npc1 = new NPC(120, 120, 5, "James");
    npc1.patrolList.add(new PatrolPoint(new Vec2(30,20),5));
    npc1.patrolList.add(new PatrolPoint(new Vec2(90,20),5));
    npc1.patrolList.add(new PatrolPoint(new Vec2(80,90),5));
    npc1.patrolList.add(new PatrolPoint(new Vec2(20,90),5));
  world.dynamics.add(npc1);
  world.dynamics.add(new NPC(140, 90, 5, "John"));
  world.dynamics.add(new NPC(150, 190, 5, "Jane"));
  world.dynamics.add(new Car(200,200,40,20, Drivetrain.BW));
  smooth(1);
  frameRate(fps);
}


void draw() {
  world.update();
  if(isDebugging) drawInfo();
}

void drawInfo() {  
  fill(255);
  text("Framerate: "+round(frameRate), 20, height-40);
  if (showCenter) {
    line(width/2, 0, width/2, height);
    line(0, height/2, width, height/2);
  }
  Vec2 cp = world.getCameraPos();
  text("Position : "+round(cp.x)+ " " +round(cp.y), 20, height-20);
  text("Mouse Pos  : "+(mouseX) + " " + (mouseY), 20, height-60);
  Vec2 gridPP = world.toGrid(cp);
  text("To grid: "+gridPP.x + " " + gridPP.y, 20, height-80);
  text("Zoom lvl: "+ nfc(world.scl, 1), 20, height-100);

  if (world.player != null) {
    if (world.player.keyBoardAim) text("Keyboard Only", 20, height-120);
    text("Stamina: "+ nfc(round(world.player.stamina), 1), 20, height-140);
    text("Weight: "+ world.player.totalWeight, 20, height-160);
    text("Penalty: "+ world.player.penalty, 20, height-180);
    String state = "";
    if (!world.player.running && !world.player.crouching) state = "Walking";
    if (world.player.running) state = "Running";
    if (world.player.crouching) state = "Crouching";
    text("MovementState: "+ state, 20, height-200);
    text((world.player.shooting?"Shooting":"")+" "+(rightPress?"Aiming":""), 20, height-220);
  }
}

// WORLD GENERATION/CREATION

void createWorld() {

  /*for (int y = 0; y < world.h; y++) {
    for (int x = 0; x < world.w; x++) {
      if (x == 10 && y % 1 == 0)new GhostTile(world, TileType.ROOF, x, y);
      if (x == 5 && y % 4 == 0) new GhostTile(world, TileType.BLOCK, x, y);
      if (x == 8 && y % 4 == 0) new GhostTile(world, TileType.TREE, x, y);
      if (x == 20 && y == 8)    new GhostTile(world, TileType.LADDER, x, y);
      if (x == 20 && y == 10)   new GhostTile(world, TileType.SQUARE, x, y);
    }
  }*/
  WorldBuilder wb = new WorldBuilder(world);
  
  wb.createRoom(28,0,5,5,1,Direction.EAST);
  
  wb.createRoom(22,0,5,5,1,Direction.NORTH);
  
  wb.createRoom(16,0,5,5,1,Direction.SOUTH);
  
  wb.createRoom(10,0,5,5,1,Direction.WEST);
  
  wb.createRoom(0,0,5,5,2,Direction.NONE);
}

// INPUT HANDLING
private boolean aimGoNorth, aimGoSouth, aimGoEast, aimGoWest;

NPC npc;
Car car;
void keyPressed() {
  if (key == 'p' || key == 'P') world.showGrid = !world.showGrid;
  if (key == 'l' || key == 'L') world.showLine = !world.showLine;
  if (key == 'n' || key == 'N') world.showWallEdge = !world.showWallEdge;
  
  if (key == '+' && world.scl < 8) world.scl += 0.1;
  if (key == '-' && world.scl > -8) world.scl -= 0.1;
  if (world.player != null) {
    if (key == 'm' || key == 'M') world.player.showMiniMap = !world.player.showMiniMap;
    if (key == 'k' || key == 'K') {world.player.keyBoardAim = !world.player.keyBoardAim; world.player.cursor = new PVector(width/2,height/2);}
    if (key == 'f' || key == 'F') {
      Dynamic d = world.player.getNearest();
      if(d != null){
          if(d instanceof Car){
            if(!world.player.driving){
              car = (Car) d;
              car.player = world.player;
              world.player.vehicle = car;
              world.player.driving = true;
            } else {
              car.player = null;
              world.player.vehicle = null;
              world.player.driving = false;
            }
          } else if (d instanceof Item){
            Item item = (Item) d;
        }
      }
    }
    PlayerGUI pgui = world.player.pgui;
    ControllerGroup dialogWindow = pgui.cp5.getGroup("dialogWindow");
    ControllerGroup inventoryWindow = pgui.cp5.getGroup("inventoryWindow");
    ControllerGroup statsWindow = pgui.cp5.getGroup("statsWindow");
    if (key == 'e' || key == 'E') if (dialogWindow.isOpen()) dialogWindow.close();
    else {
      statsWindow.close(); 
      dialogWindow.open(); 
      dialogWindow.bringToFront();
      Dynamic d = world.player.getNearest();
      if(d != null && d instanceof NPC){
        npc = (NPC) d;
        Controller c1 = dialogWindow.getController("d2");
        c1.setLabel(npc.name);
        
        Toggle c2 = (Toggle) dialogWindow.getController("d3");
        c2.setValue(npc.following);
        
        Toggle c3 = (Toggle) dialogWindow.getController("d5");
        c3.setValue(npc.debug);
        
        Toggle c4 = (Toggle) dialogWindow.getController("d6");
        c3.setValue(npc.patroling);
      }
    }
  
    if (key == 'u' || key == 'U') if (statsWindow.isOpen()) statsWindow.close();
    else {
      dialogWindow.close(); 
      statsWindow.open(); 
      statsWindow.bringToFront();
    }
  
    if (key == 'i' || key == 'I') if (inventoryWindow.isOpen()) inventoryWindow.close();
    else {
      inventoryWindow.open();
    }
  }
  
  setPressedMovementKeys(true);
}

public void controlEvent(ControlEvent theEvent) {
  //println(theEvent);
  Controller c = theEvent.getController();

  if(c.getName().equals("d3")){
    Toggle c2 = (Toggle) c;
    npc.following = c2.getState();
  }
  
  if(c.getName().equals("d5")){
    Toggle c2 = (Toggle) c;
    npc.debug = c2.getState();
  }
  
  if(c.getName().equals("d6")){
    Toggle c2 = (Toggle) c;
    npc.patroling = c2.getState();
  }
}

void keyReleased() {
  setPressedMovementKeys(false);
}

boolean goNorth, goSouth, goEast, goWest;
boolean playerSpace, playerShift, playerCtrl, playerLessThan;
void setPressedMovementKeys(boolean b) {
  switch (key) {
    case 'W': goNorth = b; break;
    case 'w': goNorth = b; break;
    case 'S': goSouth = b; break;
    case 's': goSouth = b; break;
    case 'A': goWest  = b; break;
    case 'a': goWest  = b; break;
    case 'D': goEast  = b; break;
    case 'd': goEast  = b; break;
    case ' ': playerSpace   = b; break;
    case '<': playerLessThan= b; break;
  }
  switch (keyCode) {
    case SHIFT: playerShift = b; break;
    case CONTROL: playerCtrl  = b; break;
  }
  if (world.player != null && !world.player.keyBoardAim) {
    switch (keyCode) {
      case UP:    goNorth = b; break;
      case DOWN:  goSouth = b; break;
      case LEFT:  goWest  = b; break;
      case RIGHT: goEast  = b; break;
    }
  } else {
    switch (keyCode) {
      case UP:    aimGoNorth = b; break;
      case DOWN:  aimGoSouth = b; break;
      case LEFT:  aimGoWest  = b; break;
      case RIGHT: aimGoEast  = b; break;
    }
  }
}

boolean leftPress, centerPress, rightPress;
void setPressedMouseButtons(boolean b) {
  switch(mouseButton) {
  case LEFT:   leftPress = b;   break;
  case CENTER: centerPress = b; break;
  case RIGHT:  rightPress = b;  break;
  }
}

boolean showCenter = false;
void mousePressed() {
  setPressedMouseButtons(true);
}

void mouseReleased() {
  setPressedMouseButtons(false);
}

//PHYSICS
// Define collision events
void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1.getClass() == Wall.class && o2.getClass() == Player.class) {
    Wall p1 = (Wall) o1;
    //p1.change();
    Player p2 = (Player) o2;
    p2.body.setLinearVelocity(new Vec2());
    //p2.change();
  } else if (o1.getClass() == Wall.class && o2.getClass() == Particle.class) {
    Wall p1 = (Wall) o1;
    //p1.change();
    Particle p2 = (Particle) o2;
    p2.incCollision();
    p2.body.setLinearDamping(5);
    //p2.change();
  }
}

// Objects stop touching each other
void endContact(Contact cp) {
}
