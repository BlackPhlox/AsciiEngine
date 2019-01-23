import java.util.*;
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

World world;

void setup(){
  size(600,600);
  //fullScreen();
  world = new World(this,12,35,35);
  world.setupPhysics();
  createWorld();
  world.player = new Player(100,100,5);
  world.items.add(new Item(200,150,10,"Gun"));
  smooth(1);
}

void draw(){
  world.update();
  //FOREGROUND
  if(world.player.showMap) world.player.displayMiniMap();
  drawInfo();
}

private boolean aimGoNorth,aimGoSouth,aimGoEast,aimGoWest;

void keyPressed(){
  if (key == '+' && world.scl < 8) world.scl += 0.1;
  if (key == '-' && world.scl > -8) world.scl -= 0.1;
  if (key == 'm' || key == 'M') world.player.showMap = !world.player.showMap;
  if (key == 'k') world.player.keyBoardAim = !world.player.keyBoardAim;
  setPressedMovementKeys(true, world.player.keyBoardAim);
}

void keyReleased(){
  setPressedMovementKeys(false, world.player.keyBoardAim);
}

private boolean playerGoNorth,playerGoSouth,playerGoEast,playerGoWest;
private boolean playerSpace, playerShift, playerCtrl;
void setPressedMovementKeys(boolean b, boolean usesKeyboardAim){
  switch (key) {
    case 'W':     playerGoNorth = b; break;
    case 'w':     playerGoNorth = b; break;
    case 'S':     playerGoSouth = b; break;
    case 's':     playerGoSouth = b; break;
    case 'A':     playerGoWest  = b; break;
    case 'a':     playerGoWest  = b; break;
    case 'D':     playerGoEast  = b; break;
    case 'd':     playerGoEast  = b; break;
    case ' ':     playerSpace   = b; break;
  }
  switch (keyCode) {
    case SHIFT:   playerShift = b; break;
    case CONTROL: playerCtrl  = b; break;
  }
  if(!usesKeyboardAim){
    switch (keyCode) {
      case UP:    playerGoNorth = b; break;
      case DOWN:  playerGoSouth = b; break;
      case LEFT:  playerGoWest  = b; break;
      case RIGHT: playerGoEast  = b; break;
    }
  } else {
    switch (keyCode){
      case UP:     aimGoNorth = b; break;
      case DOWN:   aimGoSouth = b; break;
      case LEFT:   aimGoWest  = b; break;
      case RIGHT:  aimGoEast  = b; break;
    }
  }
}

boolean showCenter = false;
boolean leftPress,centerPress,rightPress;

void setPressedMouseButtons(boolean b){
  switch(mouseButton){
    case LEFT: leftPress = b; break;
    case CENTER: centerPress = b; break;
    case RIGHT: rightPress = b; break;
  }
}

void mousePressed(){
  //showCenter = !showCenter;
  setPressedMouseButtons(true);
}

void mouseReleased(){
  setPressedMouseButtons(false);
}

void drawInfo(){
  stroke(255);
  fill(255);
  text(frameRate,20,height-40);
  if(showCenter){
    line(width/2,0,width/2,height);
    line(0,height/2,width,height/2);
  }
  Vec2 pp = world.getPlayerPos();
  text("Player : "+floor(-pp.x+width/2)+ " " +floor(-pp.y+height/2), 20,height-20);
  text("Mouse  : "+(mouseX) + " " + (mouseY),20,height-60);
  Vec2 gridPP = world.toGrid(pp);
  text("To grid: "+gridPP.x + " " + gridPP.y,20,height-80);
  text("Zoom lvl: "+ nfc(world.scl,1),20,height-100);
  if(world.player.keyBoardAim) text("Keyboard Only",20,height-120);
  text("Stamina: "+ world.player.stamina,20,height-140);
  text("Weight: "+ world.player.totalWeight,20,height-160);
  text("Penalty: "+ world.player.penalty,20,height-180);
}

void createWorld(){
  
  //working (kinda)
  new Wall(world,1,1,34,1); //x
  new Wall(world,1,1,1,34); //y
  new Wall(world,1,35,20,35); //w1
  new Wall(world,30,35,35,35); //w2
  new Wall(world,35,1,35,35); //h
  
  //Supposed to work
  /*new Wall(world,0,0,35,0);    //w1
    new Wall(world,35,0,35,35);  //h1
    
    new Wall(world,0,35,35,35);  //w2
    new Wall(world,35,0,0,0);    //h2
  */
  
}

//PHYSICS
// Collision event functions!
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
