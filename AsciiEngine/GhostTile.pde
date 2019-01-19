class GhostTile extends Tile{
  TileType tileType;
  GhostTile(World world,TileType t,int x, int y){
    super(world, x,y);
    this.tileType = t;
  }
  
  void display(){
    pushStyle();
    fill(255,20);
    TilePainter sp = new TilePainter(world);
    sp.drawTile(tileType,x,y);
    popStyle();
  }
}
