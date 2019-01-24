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
ControlP5 cp5;
int fps = 60;

void setup() {
  size(600, 600);
  //fullScreen();
  world = new World(this, 35, 35);
  createWorld();
  world.player = new Player(100, 100, 5);
  world.dynamics.add(new Item(200, 150, 10, "Gun"));
  world.dynamics.add(new NPC(120, 120, 5, "James", true));
  world.dynamics.add(new NPC(120, 120, 5, "John", false));
  world.dynamics.add(new NPC(120, 120, 5, "Jane", true));
  smooth(1);
  frameRate(fps);

  setupGUI();
}

int every = 60; //bpm
boolean pre;
void draw() {
  world.update();
  drawInfo();

  boolean f = frameCount % round(fps/(every/60)) == 0;
  
  heartRateChart.push("incoming", 
    (f?15:0)+(pre?-0.75:0)*20
  );
  
  if(f) pre = true; else pre = false;
}

void drawInfo() {  
  fill(255);
  text("Framerate: "+round(frameRate), 20, height-40);
  if (showCenter) {
    line(width/2, 0, width/2, height);
    line(0, height/2, width, height/2);
  }
  Vec2 pp = world.getPlayerPos();
  text("Position : "+round(pp.x)+ " " +round(pp.y), 20, height-20);
  text("Mouse Pos  : "+(mouseX) + " " + (mouseY), 20, height-60);
  Vec2 gridPP = world.toGrid(pp);
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

  for (int y = 0; y < world.h; y++) {
    for (int x = 0; x < world.w; x++) {
      new GhostTile(world, TileType.FLOOR, x, y);
      if (x == 10 && y % 1 == 0)new GhostTile(world, TileType.ROOF, x, y);
      if (x == 5 && y % 2 == 0) new GhostTile(world, TileType.BLOCK, x, y);
      if (x == 8 && y % 4 == 0) new GhostTile(world, TileType.TREE, x, y);
      if (x == 20 && y == 8)    new GhostTile(world, TileType.LADDER, x, y);
      if (x == 20 && y == 10)   new GhostTile(world, TileType.SQUARE, x, y);
    }
  }


  //working (kinda)
  new Wall(world, 1, 1, 34, 1); //x
  new Wall(world, 1, 1, 1, 34); //y
  new Wall(world, 1, 35, 20, 35); //w1
  new Wall(world, 30, 35, 35, 35); //w2
  new Wall(world, 35, 1, 35, 35); //h

  //new Wall(world,1,15,35,35); //Check performace

  //Supposed to work
  /*new Wall(world,0,0,35,0);    //w1
   new Wall(world,35,0,35,35);  //h1
   
   new Wall(world,0,35,35,35);  //w2
   new Wall(world,35,0,0,0);    //h2
   */
}

// GUI
Chart heartRateChart;
void setupGUI() {
  cp5 = new ControlP5(this);

  cp5.begin(cp5.addBackground("dialogWindow").close());

  cp5.addButton("d1")
    .setLabel("Dialog")
    .setPosition(0, 0)
    .setSize(width/2, 20)
    .lock()
    ;

  cp5.addButton("d2")
    .setLabel("NPC_NAME")
    .setPosition(20, 40)
    .setSize(width/2-40, 20)
    .lock()
    ;

  cp5.addToggle("d3")
    .setLabel("Follow me")
    .setPosition(20, 80)
    .setSize(45, 20)
    .setMode(Toggle.CHECKBOX)
    ;

  cp5.addToggle("d4")
    .setLabel("Trade")
    .setPosition(80, 80)
    .setSize(45, 20)
    .setMode(Toggle.CHECKBOX)
    ;
  cp5.end();   

  cp5.begin(cp5.addBackground("inventoryWindow").setPosition(width-width/2, 0).close());

  cp5.addButton("i1")
    .setLabel("Inventory")
    .setPosition(0, 0)
    .setSize(width/2, 20)
    .lock()
    ;

  cp5.end();

  cp5.begin(cp5.addBackground("statsWindow").close());

  heartRateChart = cp5.addChart("heartRate")
    .setPosition(50, 50)
    .setSize(200, 100)
    .setRange(-20, 20)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(1.5)
    .setColorCaptionLabel(color(40))
    ;

  heartRateChart.addDataSet("incoming");
  heartRateChart.setData("incoming", new float[100]);

  cp5.addSlider("v1", 0, 255).setSize(width/2-28, 0).linebreak();
  cp5.addSlider("v2", 0, 255).linebreak();
  cp5.addSlider("v3", 0, 200).linebreak();
  cp5.addSlider("v4", 0, 300).linebreak();
  cp5.addSlider("v5", 0, 400).linebreak();

  cp5.addSlider("v6", 0, 255).linebreak();
  cp5.addSlider("v7", 0, 255).linebreak();
  cp5.addSlider("v8", 0, 200).linebreak();
  cp5.addSlider("v9", 0, 300).linebreak();
  cp5.addSlider("v10", 0, 400);

  cp5.addButton("s1")
    .setLabel("Stats")
    .setPosition(0, 0)
    .setSize(width/2, 20)
    .lock()
    ;
  cp5.end();

  cp5.getController("v1").setCaptionLabel("XP");
  style("v1");

  // change the caption label for controller v1 and apply styles
  cp5.getController("v2").setCaptionLabel("Health");
  style("v2");

  // change the caption label for controller v2 and apply styles
  cp5.getController("v3").setCaptionLabel("Stamina");
  style("v3");

  // change the caption label for controller v3 and apply styles
  cp5.getController("v4").setCaptionLabel("Agility");
  style("v4");

  // change the caption label for controller v3 and apply styles
  cp5.getController("v5").setCaptionLabel("Dexterity");
  style("v5");


  cp5.getController("v6").setCaptionLabel("Strength");
  style("v6");

  // change the caption label for controller v1 and apply styles
  cp5.getController("v7").setCaptionLabel("Perception");
  style("v7");

  // change the caption label for controller v2 and apply styles
  cp5.getController("v8").setCaptionLabel("Stamina");
  style("v8");

  // change the caption label for controller v3 and apply styles
  cp5.getController("v9").setCaptionLabel("Charisma");
  style("v9");

  // change the caption label for controller v3 and apply styles
  cp5.getController("v10").setCaptionLabel("Intelligence");
  style("v10");
}

void style(String theControllerName) {
  Controller c = cp5.getController(theControllerName);
  // adjust the height of the controller
  c.setHeight(15);

  c.setWidth(width/2-80);

  // add some padding to the caption label background
  c.getCaptionLabel().getStyle().setPadding(4, 4, 3, 4);

  // shift the caption label up by 4px
  c.getCaptionLabel().getStyle().setMargin(-4, 0, 0, 0); 

  // set the background color of the caption label
  c.getCaptionLabel().setColorBackground(color(10, 20, 30, 140));
}

// INPUT HANDLING

private boolean aimGoNorth, aimGoSouth, aimGoEast, aimGoWest;

void keyPressed() {
  if (key == '+' && world.scl < 8) world.scl += 0.1;
  if (key == '-' && world.scl > -8) world.scl -= 0.1;
  if (world.player != null) {
    if (key == 'm' || key == 'M') world.player.showMiniMap = !world.player.showMiniMap;
    if (key == 'k' || key == 'K') world.player.keyBoardAim = !world.player.keyBoardAim;
  }
  setPressedMovementKeys(true);

  ControllerGroup dialogWindow = cp5.getGroup("dialogWindow");
  ControllerGroup inventoryWindow = cp5.getGroup("inventoryWindow");
  ControllerGroup statsWindow = cp5.getGroup("statsWindow");
  if (key == 'e' || key == 'E') if (dialogWindow.isOpen()) dialogWindow.close();
  else {
    statsWindow.close(); 
    dialogWindow.open(); 
    dialogWindow.bringToFront();
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

void keyReleased() {
  setPressedMovementKeys(false);
}

boolean goNorth, goSouth, goEast, goWest;
boolean playerSpace, playerShift, playerCtrl, playerLessThan;
void setPressedMovementKeys(boolean b) {
  switch (key) {
  case 'W':     
    goNorth = b; 
    break;
  case 'w':     
    goNorth = b; 
    break;
  case 'S':     
    goSouth = b; 
    break;
  case 's':     
    goSouth = b; 
    break;
  case 'A':     
    goWest  = b; 
    break;
  case 'a':     
    goWest  = b; 
    break;
  case 'D':     
    goEast  = b; 
    break;
  case 'd':     
    goEast  = b; 
    break;
  case ' ':     
    playerSpace   = b; 
    break;
  case '<':     
    playerLessThan= b; 
    break;
  }
  switch (keyCode) {
  case SHIFT:   
    playerShift = b; 
    break;
  case CONTROL: 
    playerCtrl  = b; 
    break;
  }
  if (world.player != null && !world.player.keyBoardAim) {
    switch (keyCode) {
    case UP:    
      goNorth = b; 
      break;
    case DOWN:  
      goSouth = b; 
      break;
    case LEFT:  
      goWest  = b; 
      break;
    case RIGHT: 
      goEast  = b; 
      break;
    }
  } else {
    switch (keyCode) {
    case UP:     
      aimGoNorth = b; 
      break;
    case DOWN:   
      aimGoSouth = b; 
      break;
    case LEFT:   
      aimGoWest  = b; 
      break;
    case RIGHT:  
      aimGoEast  = b; 
      break;
    }
  }
}

boolean leftPress, centerPress, rightPress;
void setPressedMouseButtons(boolean b) {
  switch(mouseButton) {
  case LEFT: 
    leftPress = b; 
    break;
  case CENTER: 
    centerPress = b; 
    break;
  case RIGHT: 
    rightPress = b; 
    break;
  }
}

boolean showCenter = false;
void mousePressed() {
  //Debug draws (TOGGLE)
  //showCenter = !showCenter;
  //world.showGrid = !world.showGrid;
  //world.showLine = !world.showLine;
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
