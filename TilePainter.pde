class TilePainter{
  World world;
  TilePainter(World world){
    this.world = world;
  }
  
  void drawTile(TileType t,int x,int y){
    PVector p = calculateDepthVector(x,y);
    //Creates a spherical bulge of tiles around the playerPos
    //p.limit(world.depthDensity);
    pushMatrix();
    translate(x*world.gridSize,y*world.gridSize);
    drawDebug(p);
    
    switch(t){
    //case Type:   drawMethod   (min, max,        p,String or Char,Fade,DescFade 
      case WALL:   drawCharacter(0,world.layers,  p,t.getChar()   ,true,true) ;break;
      case TREE:   drawString(   4,               p,t.getIcon()   ,false,false);break;
      case LADDER: drawCharacter(0,world.layers-1,p,t.getChar()   ,false,false);break;
      case FLOOR:  drawCharacter(0,1,             p,t.getChar()   ,false,false);break;
                                                  //Height
      case ROOF:   drawRoof(                      p,world.layers              );break;
      case BLOCK:  drawBox(                       p,10                        );break;
      
      case SQUARE: drawSquare(p);break;
      
    }
    
     popMatrix();   
  }
  
  void drawCustom(int x,int y){
    PVector p = calculateDepthVector(x,y);
    //Creates a spherical bulge of tiles around the playerPos
    //p.limit(world.depthDensity);
    pushMatrix();
    translate(x*world.gridSize,y*world.gridSize);
    //The custom part
      drawCharacter(4,world.layers,p,'#',true,true);
    popMatrix();   
  }
  
  PVector calculateDepthVector(int x, int y){
    Vec2 v = world.getPlayerPos();
    return PVector.sub(
        new PVector(x*world.gridSize,y*world.gridSize),
        new PVector(v.x,v.y)
    );
  }
  
  PVector calculateLayerPos(int layer, PVector depthVector){
    return new PVector(map(layer,0,world.depthDensity,0,depthVector.x),map(layer,0,world.depthDensity,0,depthVector.y));
  }
  
  void drawDebug(PVector p){
    if(world.showGrid){
      pushStyle();
      stroke(255,20);
      fill(255,20);
      square(0,0,world.gridSize);
      popStyle();
    }
    if(world.showLine){
      line(0,0,p.x,p.y);
    }
  }
  
  private void drawSquare(PVector p){
    fill(255,50);
    PVector bottom = calculateLayerPos(0,p);
    square(bottom.x,bottom.y,world.gridSize);
  }
  
  private void drawRoof(PVector p, int roofHeight){
    fill(50);
    PVector top = calculateLayerPos(roofHeight,p);
    square(top.x,top.y,world.gridSize);//size should use depthDensity
  }
  
  private void drawBox(PVector p, int boxHeight){
    fill(255);
    PVector bottom = calculateLayerPos(0,p);
    rect(bottom.x,bottom.y,world.gridSize,world.gridSize);
    PVector top = calculateLayerPos(boxHeight,p);
    float size = world.gridSize/2;
    stroke(255);
    line(bottom.x-size,bottom.y-size,top.x-size,top.y-size);
    line(bottom.x+size,bottom.y-size,top.x+size,top.y-size);
    line(bottom.x-size,bottom.y+size,top.x-size,top.y+size);
    line(bottom.x+size,bottom.y+size,top.x+size,top.y+size);
    square(top.x,top.y,world.gridSize);//size should use depthDensity
  }
  
  private void drawString(int min, PVector p, String s, boolean fade, boolean descFade){
    if(s.length() > 1){
      int sLength = s.length(); 
        for(int i = 0; i < sLength; i++){
          if(fade){
            if(descFade){
              fill(map(i,min,sLength,255,0));
            } else {
              fill(map(i,min,sLength,0,255));
            }
          } else {
            fill(255);
          }
          if(min <= i) drawTextOffset(s.charAt(i),i,p);
      }
    }
  }
  
  private void drawCharacter(int min, int max, PVector p, char c, boolean fade, boolean descFade){
     for(int i = min; i < max; i++){
       if(fade){
         if(descFade){
           fill(255,map(i,min,max,255,0));
         } else {
           fill(255,map(i,min,max,0,255));
         }
       } else {
         fill(255);
       }
       drawTextOffset(c,i,p);
     }  
  }
 
  
  private void drawTextOffset(char c, int i, PVector p){
    drawTextOffset(String.valueOf(c),i,p);
  }
  
  private void drawTextOffset(String s, int i, PVector p){
    pushMatrix();
      float x = map(i,0,world.depthDensity,0,p.x);
      float y = map(i,0,world.depthDensity,0,p.y);
      translate(-textWidth(s)/2,world.gridSize-textWidth(s)/2-4);
      text(s,x,y);
    popMatrix();
  }
}
