class GhostTile extends Tile{
  TileType tileType;
  AsciiEngine p;
  GhostTile(AsciiEngine p,World world,TileType t,int x, int y){
    super(world, x,y);
    this.p = p;
    this.tileType = t;
  }
  
  public void display(){
    TilePainter sp = new TilePainter(p,world);
    sp.drawTile(tileType,x,y);
  }
}
