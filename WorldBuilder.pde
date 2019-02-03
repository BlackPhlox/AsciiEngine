class WorldBuilder{
  World world;
  WorldBuilder(World world){
    this.world = world;
  }
  void createRoom(int x, int y,int w,int h, int hole, Direction d){
    println("Creating Room /w with params: " + x + " " + y + " " + w + " " + h + " " + hole + " " + d);
    if(d == Direction.NORTH){
      new Wall(world, x, y, x+hole+1, y+1); //NORTH1
      new Wall(world, x+(w-hole), y, x+w, y+1); //NORTH2
      for(int i = 1; i < hole*2+1; i++){
        new GhostTile(world,TileType.ENTRY,x+i+hole,y);
      }
    } else new Wall(world, x, y, x+w, y+1); //NORTH
    if(d == Direction.SOUTH){
      new Wall(world, x, y+h, x+hole+1, y+h+1); //SOUTH1
      new Wall(world, x+(w-hole), y+h, x+w, y+h+1); //SOUTH2
      for(int i = 1; i < hole*2+1; i++){
        new GhostTile(world,TileType.ENTRY,x+i+hole,y+h);
      }
    } else new Wall(world, x, y+h, x+w, y+h+1); //SOUTH
    if(d == Direction.EAST){
      new Wall(world, x+w, y, x+w+1, y+hole+1); //EAST1
      new Wall(world, x+w, y+(h-hole), x+w+1, y+h+1); //EAST2
      for(int i = 0; i < hole*2; i++){
        new GhostTile(world,TileType.ENTRY,x+w,y+i+hole+1);
      }
    } else new Wall(world, x+w, y, x+w+1, y+h+1); //EAST
    if(d == Direction.WEST){
      new Wall(world, x, y, x+1, y+hole+1); //WEST1
      new Wall(world, x, y+(h-hole), x+1, y+h); //WEST2
      for(int i = 0; i < hole*2; i++){
        new GhostTile(world,TileType.ENTRY,x,y+i+hole+1);
      }
    } else new Wall(world, x, y, x+1, y+h); //WEST
    
    for (int y1 = y; y1 < y+h; y1++) {
      for (int x1 = x; x1 < x+w; x1++) {
        new GhostTile(world, TileType.FLOOR, x1, y1);
      }
    }
    
  }
  
}
