class Wall extends Static{
  // A boundary is a simple rectangle with x,y,width,and height
  int wallWidth;
  int wallHeight;
  Wall[] walls;
  boolean isEnd = false;
  TileType tileType = TileType.WALL;
  
  Wall(World world, int x_,int y_, boolean isEnd) {
    this(world, x_, y_, 1, 1);  
    this.isEnd = isEnd;
  }

  Wall(World world, int x_,int y_, int w_, int h_) {
    super(world,x_,y_);
    this.wallWidth = w_;
    this.wallHeight = h_;
    if(w_ > 1 || h_ > 1) {
      walls = new Wall[w_*h_]; //<>// //<>//
      for(int i = x_-1; i < wallWidth; i++){
        for(int j = y_-1; j < wallHeight; j++){
          boolean end = (i == wallWidth) || (j == wallHeight);
          walls[i] = new Wall(world,i,j,end); //<>// //<>//
        }
      }
    } 
  }

  // Draw the boundary, if it were at an angle we'd have to do something fancier
  void display() {
    if(walls != null){
      for(int i = 0; i < wallHeight*wallWidth; i++){
        if(walls[i]!=null) walls[i].display();
      }
    } else {
      //drawRect();
      TilePainter sp = new TilePainter(world);
      if(isEnd){
        sp.drawTile(tileType,x,y);
      } else sp.drawTile(tileType,x,y);
    }
    drawRect();
  }
  
  void drawRect(){
    noFill();
    stroke(255);
    square(x*world.gridSize,y*world.gridSize,world.gridSize);
  }
  
  
}
