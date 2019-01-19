import java.util.*;
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

Box2DProcessing box2d;
public static Player player;
World world;

ArrayList<Particle> particles = new ArrayList<Particle>();

void setup(){
  size(600,600);
  //fullScreen();
  setupPhysics();
  world = new World(12,35,35);
  createWorld();
  player = new Player(100,100);
  textSize(12);
}

void setupPhysics(){
  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  // Turn on collision listening!
  box2d.listenForCollisions();
  box2d.setGravity(0,0);
}
float scl = 1;
void draw(){
  //BACKEND-BACKGROUND
  inputMovement();
  inputMouse();
  background(0);
  box2d.step();
  
  //WORLD
  pushMatrix();
  Vec2 pp = box2d.getBodyPixelCoord(player.body);
  translate(-pp.x+width/2, -pp.y+height/2);
  scale(scl);
  
  
  player.display();
  displayParticles();
  world.displayForeground();
  
  popMatrix();
  
  //FOREGROUND
  drawInfo();
}

void keyPressed(){
  if (key == '+') scl += 0.1;
  if (key == '-') scl -= 0.1;
  if (key == 'm' || key == 'M') player.showMap = !player.showMap;
}

void mousePressed(){
  //showCenter = !showCenter;
}

int moveDist = 20*-1;
void inputMovement(){
  if(keyPressed){
      if (key == CODED) {
        PVector delta = new PVector();
        if(keyCode == UP   || key == 'w' || key == 'W') delta.add(new PVector(0,-moveDist));
        if(keyCode == DOWN || key == 's' || key == 'S') delta.add(new PVector(0,moveDist));
        if(keyCode == LEFT || key == 'a' || key == 'A') delta.add(new PVector(moveDist,0));
        if(keyCode == RIGHT|| key == 'd' || key == 'D') delta.add(new PVector(-moveDist,0));
        player.move(delta);
      } else {
        PVector delta = new PVector();
        if(key == 'w' || key == 'W') delta.add(new PVector(0,-moveDist));
        if(key == 's' || key == 'S') delta.add(new PVector(0,moveDist));
        if(key == 'a' || key == 'A') delta.add(new PVector(moveDist,0));
        if(key == 'd' || key == 'D') delta.add(new PVector(-moveDist,0));
        player.move(delta);
      }
   }
}

void displayParticles(){
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.display();
    // Particles that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    if (p.done()) {
      particles.remove(i);
    }
  }
}

void inputMouse(){
  if(mousePressed){
    float sz = 8;//random(4, 8);
    Vec2 pp = box2d.getBodyPixelCoord(player.body);
    particles.add(new Particle(pp.x, pp.y,new Vec2(player.mouseDirection.x,player.mouseDirection.y*-1), sz));
  }
}

boolean showCenter = false;
void drawInfo(){
  stroke(255);
  fill(255);
  text(frameRate,20,height-40);
  if(showCenter){
    line(width/2,0,width/2,height);
    line(0,height/2,width,height/2);
  }
  Vec2 pp = box2d.getBodyPixelCoord(player.body);
  text("Player : "+floor(-pp.x+width/2)+ " " +floor(-pp.y+height/2), 20,height-20);
  text("Mouse  : "+(mouseX) + " " + (mouseY),20,height-60);
  Vec2 gridPP = toGrid(pp,world.gridSize);
  text("To grid: "+gridPP.x + " " + gridPP.y,20,height-80);
}

public static Vec2 toGrid(Vec2 v, int gridSize){
  return new Vec2(round(v.x/gridSize),round(v.y/gridSize));
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
int count = 0;
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
  
  println("Hit " + count++);

  if (o1.getClass() == Wall.class && o2.getClass() == Player.class) {
    Wall p1 = (Wall) o1;
    //p1.change();
    Player p2 = (Player) o2;
    p2.body.setLinearVelocity(new Vec2());
    //p2.change();
  }

}

// Objects stop touching each other
void endContact(Contact cp) {
}
