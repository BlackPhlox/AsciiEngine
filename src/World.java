import java.util.HashSet;

class World{
  int w,h;
  int gridSize;
  int layers = 15;
  
  boolean showGrid;
  boolean showLine;
  
  HashSet<Tile> tiles;

  AsciiEngine p;
  World(AsciiEngine p, int gridSize,int w, int h){
    this.p = p;
    this.w = w;
    this.h = h;
    this.gridSize = gridSize;
    //this.p.textSize(gridSize);
    tiles = new HashSet<Tile>();
    for(int y = 0; y < h; y++){
      for(int x = 0; x < w; x++){
        new GhostTile(p,this,TileType.FLOOR,x,y);
        if(x == 10 && y % 1 == 0) new GhostTile(p,this,TileType.ROOF,x,y);
        if(x == 5 && y % 2 == 0) new GhostTile(p,this,TileType.BLOCK,x,y);
        if(x == 8 && y % 4 == 0) new GhostTile(p,this,TileType.TREE,x,y);
        if(x == 20 && y == 8) new GhostTile(p,this,TileType.LADDER,x,y);
        if(x == 20 && y == 10) new GhostTile(p,this,TileType.SQUARE,x,y);
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
