import org.jbox2d.common.Vec2;
import processing.core.PApplet;
import processing.core.PVector;

import static processing.core.PApplet.map;

class TilePainter{
  World world;
  AsciiEngine p;
  TilePainter(AsciiEngine p, World world){
    this.p = p;
    this.world = world;
  }
  
  void drawTile(TileType t,int x,int y){
    PVector p = calculateDepthVector(x,y);
    this.p.stroke(255);
    //p.limit(world.depth);
    this.p.pushMatrix();
    this.p.translate(x*world.gridSize,y*world.gridSize);
    drawDebug(p);
    
    switch(t){
      case WALL:   drawString(0,world.layers,p,t.getIcon());break;
      case TREE:   drawString(0,world.layers,p,t.getIcon());break;
      case LADDER: drawString(0,world.layers-1,p,t.getIcon());break;
      case ROOF:   drawRoof(p,world.layers);break;
      case FLOOR:  drawString(0,1,p,t.getIcon());break;
    //case EMPTY:  drawString(0,1,p,t.getIcon());break;
      
      case SQUARE: drawSquare(p);break;
      case BLOCK:  drawBox(p,10);break;
    }

    this.p.popMatrix();
  }
  
  PVector calculateDepthVector(int x, int y){
    Vec2 v = p.box2d.getBodyPixelCoord(p.player.body);
    return PVector.sub(
        new PVector(x*world.gridSize,y*world.gridSize),
        new PVector(v.x,v.y)
    );
  }
  
  void drawDebug(PVector p){
    if(world.showGrid){
      this.p.pushStyle();
      this.p.stroke(255,20);
      this.p.fill(255,20);
      this.p.rect(0,0,world.gridSize,world.gridSize);
      this.p.popStyle();
    }
    if(world.showLine){
      this.p.line(0,0,p.x,p.y);
    }
  }
  
  private void drawSquare(PVector p){
    this.p.fill(255,50);
    PVector bottom = new PVector(map(0,0,world.layers,0,p.x),map(0,0,world.layers,0,p.y));
    this.p.rect(bottom.x,bottom.y,world.gridSize,world.gridSize);
  }
  
  private void drawRoof(PVector p, int roofHeight){
    this.p.fill(50);
    PVector top = new PVector(map(roofHeight,0,world.layers,0,p.x),map(roofHeight,0,world.layers,0,p.y));
    this.p.rect(top.x,top.y,world.gridSize*2,world.gridSize*2);
  }
  
  private void drawBox(PVector p, int boxHeight){
    this.p.fill(255);
    PVector bottom = new PVector(map(0,0,world.layers,0,p.x),map(0,0,world.layers,0,p.y));
    //rect(bottom.x,bottom.y,world.gridSize,world.gridSize);
    PVector top = new PVector(map(boxHeight,0,world.layers,0,p.x),map(boxHeight,0,world.layers,0,p.y));
    float size = world.gridSize/2;
    this.p.line(bottom.x-size,bottom.y-size,top.x-size,top.y-size);
    this.p.line(bottom.x+size,bottom.y-size,top.x+size,top.y-size);
    this.p.line(bottom.x-size,bottom.y+size,top.x-size,top.y+size);
    this.p.line(bottom.x+size,bottom.y+size,top.x+size,top.y+size);
    this.p.rect(top.x,top.y,world.gridSize*1.4f,world.gridSize*1.4f);
  }
  
  private void drawString(int min, int max, PVector p, String s){
    if(s.length() > 1){
      int sLength = s.length();
        for(int i = 0; i < sLength; i++){
          //fill(map(i,0,sLength,255,0));
          this.p.pushStyle();
          this.p.fill(255);
          drawTextOffset(s.charAt(i),map(i,0,world.layers,0,p.x),map(i,0,world.layers,0,p.y));
          this.p.popStyle();
        }     
     } else {
       for(int i = min; i < max; i++){
         this.p.fill(255,map(i,0,world.layers,255,0));
         drawTextOffset(s,map(i,0,world.layers,0,p.x),map(i,0,world.layers,0,p.y));
       }  
     }
  }
  
  private void drawTextOffset(char c, float x, float y){
    drawTextOffset(String.valueOf(c),x,y);
  }
  
  private void drawTextOffset(String s, float x, float y){
    this.p.pushMatrix();
    this.p.translate(-this.p.textWidth(s)/2,world.gridSize-this.p.textWidth(s)/2-4);
    this.p.text(s,x,y);
    this.p.popMatrix();
  }
}
