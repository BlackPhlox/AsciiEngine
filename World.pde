class World{
  int w,h;
  int gridSize;
  int layers = 15;
  
  boolean showGrid;
  boolean showLine;
  
  HashSet<Tile> tiles;
  World(int gridSize,int w, int h){
    this.w = w;
    this.h = h;
    this.gridSize = gridSize;
    textSize(gridSize);
    tiles = new HashSet<Tile>();
    for(int y = 0; y < h; y++){
      for(int x = 0; x < w; x++){
        new GhostTile(this,TileType.FLOOR,x,y);
        if(x == 10 && y % 1 == 0) new GhostTile(this,TileType.ROOF,x,y);
        if(x == 5 && y % 2 == 0) new GhostTile(this,TileType.BLOCK,x,y);
        if(x == 8 && y % 4 == 0) new GhostTile(this,TileType.TREE,x,y);
        if(x == 20 && y == 8) new GhostTile(this,TileType.LADDER,x,y);
        if(x == 20 && y == 10) new GhostTile(this,TileType.SQUARE,x,y);
      }
    }
  }
  
  void displayBackground(){
    //layers = mouseX;
  }
  
  void displayForeground(){
    for(Tile t : tiles){
      t.display();
    }
  }
}