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
  smooth(1);
}

private boolean goNorth,goSouth,goEast,goWest;

void draw(){
  pushMatrix();
  world.player.inputMouse();
  world.inputMovement();
  world.box2d.step();
  
  world.drawWorld();
  
  if(keyBoardAim){
    pushStyle();
      stroke(255);
      strokeWeight(5);
      point(cursor.x,cursor.y);
    popStyle();
  }
  
  popMatrix();
  //FOREGROUND
  if(world.player.showMap) world.player.displayMiniMap();
  drawInfo();
}

boolean showCenter = false;
boolean keyBoardAim = false;
float cursorMovementSpeed = 5;
PVector cursor = new PVector();
void keyPressed(){
  if (key == '+' && world.scl < 8) world.scl += 0.1;
  if (key == '-' && world.scl > -8) world.scl -= 0.1;
  if (key == 'm' || key == 'M') world.player.showMap = !world.player.showMap;
  if (key == 'k') keyBoardAim = !keyBoardAim;
  setPressedMovementKeys(true, keyBoardAim);
}

void keyReleased(){
  setPressedMovementKeys(false, keyBoardAim);
}

void setPressedMovementKeys(boolean b, boolean usesKeyboardAim){
  switch (key) {
    case 'W':     goNorth = b; break;
    case 'w':     goNorth = b; break;
    case 'S':     goSouth = b; break;
    case 's':     goSouth = b; break;
    case 'A':     goWest  = b; break;
    case 'a':     goWest  = b; break;
    case 'D':     goEast  = b; break;
    case 'd':     goEast  = b; break;
  }
  if(!usesKeyboardAim){
    switch (keyCode) {
      case UP:    goNorth = b; break;
      case DOWN:  goSouth = b; break;
      case LEFT:  goWest  = b; break;
      case RIGHT: goEast  = b; break;
    }
  } else {
    switch (keyCode){
      case UP:    cursor.add(0,-1*cursorMovementSpeed); break;
      case DOWN:  cursor.add(0,1*cursorMovementSpeed); break;
      case LEFT:  cursor.add(-1*cursorMovementSpeed,0); break;
      case RIGHT: cursor.add(1*cursorMovementSpeed,0); break;
    }
  }
  switch (keyCode) {
    case SHIFT: world.player.running = b; break;
    case ALT: world.player.crouching = b; break;
  }
}

boolean leftPress,centerPress,rightPress;
void mousePressed(){
  //showCenter = !showCenter;
  switch(mouseButton){
    case LEFT: leftPress = true; break;
    case CENTER: centerPress = true; break;
    case RIGHT: rightPress = true; break;
  }
}

void mouseReleased(){
  switch(mouseButton){
    case LEFT: leftPress = false; break;
    case CENTER: centerPress = false; break;
    case RIGHT: rightPress = false; break;
  }
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
  if(keyBoardAim) text("Keyboard Only",20,height-120);
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
