abstract class Tile implements Updatable{
  int x,y;
  World world;
  Tile(World world, int x, int y){
    this.world = world;
    this.x = x;
    this.y = y;
    world.tiles.add(this);
  }
}
