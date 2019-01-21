import java.util.*;

import org.jbox2d.dynamics.contacts.Contact;
import processing.core.PGraphics;
import processing.core.PVector;
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

import processing.core.PApplet;

public class AsciiEngine extends PApplet{

    public static void main (String... args) {
        AsciiEngine pt = new AsciiEngine();
        PApplet.runSketch(new String[]{"ProcessingTest"}, pt);
    }

    @Override
    public void settings() {
        size(600,600);
        //fullScreen();
        setupPhysics();
        world = new World(this,12,35,35);
        createWorld();
        player = new Player(this,100,100,5);
        smooth(1);
    }

    @Override
    public void draw() {
        //BACKEND-BACKGROUND
        pushMatrix();
        inputMovement();
        inputMouse();

        box2d.step();

        drawWorld();
        if(keyBoardAim){
            pushStyle();
            stroke(255);
            strokeWeight(5);
            point(cursor.x,cursor.y);
            popStyle();
        }

        popMatrix();
        //FOREGROUND
        if(player.showMap) player.displayMiniMap();
        drawInfo();
    }

    Box2DProcessing box2d;
    public static Player player;
    World world;

    ArrayList<Particle> particles = new ArrayList<Particle>();


    private boolean goNorth,goSouth,goEast,goWest,running,crouching;
    public static double penalty;

    void setupPhysics(){
        // Initialize box2d physics and create the world
        box2d = new Box2DProcessing(this);
        box2d.createWorld();

        // Turn on collision listening!
        box2d.listenForCollisions();
        box2d.setGravity(0,0);
    }
    float scl = 1;

    void drawWorld(){
        background(0);
        Vec2 pp = box2d.getBodyPixelCoord(player.body);
        pushMatrix();
        translate(-(width * (scl - 1) / 2),-(height * (scl - 1) / 2));
        scale(scl);
        pushMatrix();
        translate(-pp.x+width/2, -pp.y+height/2);
        world.displayBackground();
        player.display();
        displayParticles();
        world.displayForeground();
        popMatrix();
        popMatrix();
    }

    boolean showCenter = false;
    boolean keyBoardAim = false;
    float cursorMovementSpeed = 5;
    PVector cursor = new PVector();
    public void keyPressed(){
        if (key == '+') scl += 0.1;
        if (key == '-') scl -= 0.1;
        if (key == 'm' || key == 'M') player.showMap = !player.showMap;
        if (key == 'k') keyBoardAim = !keyBoardAim;
        setPressedMovementKeys(true, keyBoardAim);
    }

    public void keyReleased(){
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
        }
        switch (keyCode) {
            case SHIFT: running = b; break;
            case ALT: crouching = b; break;
        }
    }

    public void mousePressed(){
        //showCenter = !showCenter;
    }

    void cursorMovement(){
        if(keyPressed && keyBoardAim){
            switch (keyCode) {
                case UP:    cursor.add(0,-1*cursorMovementSpeed); break;
                case DOWN:  cursor.add(0,1*cursorMovementSpeed); break;
                case LEFT:  cursor.add(-1*cursorMovementSpeed,0); break;
                case RIGHT: cursor.add(1*cursorMovementSpeed,0); break;
            }
        }
    }

    void inputMovement(){
        cursorMovement();
        if(player != null) {
            PVector delta = new PVector();
            if (goNorth) delta.y += (player.walkSpeed * player.walkSpeedMult);
            if (goSouth) delta.y -= (player.walkSpeed * player.walkSpeedMult);
            if (goEast)  delta.x += (player.walkSpeed * player.walkSpeedMult);
            if (goWest)  delta.x -= (player.walkSpeed * player.walkSpeedMult);
            if (crouching){
                delta.x *= player.crouchSpeedRedux;
                delta.y *= player.crouchSpeedRedux;
            } else if (running && player.stamina > 0 && penalty <= 0) {
                delta.x *= (player.runningSpeed - player.runningSpeedMult+1);
                delta.y *= (player.runningSpeed - player.runningSpeedMult+1);
                if(goNorth||goEast||goSouth||goWest){
                    player.stamina -= (player.fatigueRate * player.fatigueMult);
                }
            }
            if(player.stamina <= 0){
                penalty = player.recoverRate;
            }
            if(penalty > 0 || player.stamina < player.maxStamina){
                player.stamina += player.restitutionRate;
            }
            player.move(delta);

            if(penalty > 0) penalty--;
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

    float zoom;
    float maxZoom = 50;
    float zoomInSpeed = 0.05f;
    float zoomOutSpeed = 0.2f;
    void inputMouse(){
        if(mousePressed){

            float sz = 2;//random(4, 8);
            Vec2 pp = box2d.getBodyPixelCoord(player.body);
            PVector normMouseDirection = player.mouseDirection;
            normMouseDirection.normalize();
            PVector p2 = PVector.add(new PVector(pp.x,pp.y),normMouseDirection);

            if(mouseButton == RIGHT){
                zoom = lerp(zoom,maxZoom,zoomInSpeed);
                player.mouseDirection.setMag(zoom);
                translate(player.mouseDirection.x*-1,player.mouseDirection.y*-1);
            }

            float ran = random(100,120);
            player.mouseDirection.setMag(ran);

            boolean isBullet = true;
            if(mouseButton == LEFT) particles.add(
                    new Particle(this,p2.x,p2.y,
                            new Vec2(normMouseDirection.x*0.5f,normMouseDirection.y*-1*0.5f), sz, isBullet));
        } else {
            if(player.mouseDirection != null){
                player.mouseDirection.setMag(zoom);
                translate(player.mouseDirection.x*-1,player.mouseDirection.y*-1);
            }
            zoom = lerp(zoom,0,zoomOutSpeed);
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
        Vec2 pp = box2d.getBodyPixelCoord(player.body);
        text("Player : "+floor(-pp.x+width/2)+ " " +floor(-pp.y+height/2), 20,height-20);
        text("Mouse  : "+(mouseX) + " " + (mouseY),20,height-60);
        Vec2 gridPP = toGrid(pp,world.gridSize);
        text("To grid: "+gridPP.x + " " + gridPP.y,20,height-80);
        text("Zoom lvl: "+ scl,20,height-100);
        if(keyBoardAim) text("Keyboard Only",20,height-120);
        text("Stamina: "+ player.stamina,20,height-140);
        text("Weight: "+ player.totalWeight,20,height-160);
        text("Penalty: "+ penalty,20,height-180);
    }

    public static Vec2 toGrid(Vec2 v, int gridSize){
        return new Vec2(round(v.x/gridSize),round(v.y/gridSize));
    }

    void createWorld(){

        //working (kinda)
        new Wall(this,world,1,1,34,1); //x
        new Wall(this,world,1,1,1,34); //y
        new Wall(this,world,1,35,20,35); //w1
        new Wall(this,world,30,35,35,35); //w2
        new Wall(this,world,35,1,35,35); //h

        //Supposed to work
  /*new Wall(world,0,0,35,0);    //w1
    new Wall(world,35,0,35,35);  //h1

    new Wall(world,0,35,35,35);  //w2
    new Wall(world,35,0,0,0);    //h2
  */

    }

    //PHYSICS
// Collision event functions!
    public void beginContact(Contact cp) {
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
    public void endContact(Contact cp) {
    }
}

