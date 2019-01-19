enum TileType{
  /*WALL_END,
  WALL_MID_H,
  WALL_MID_V,*/
  WALL("#"),
  
  TREE("ooooooo*"),
  LADDER("["),
  FLOOR("."),
  ROOF("R"),
  EMPTY(" "),
  
  
  BLOCK(DrawType.BOX),
  
  SQUARE(DrawType.SQUARE);
  
  private String icon = null;
  private DrawType dt = null;

  private TileType(final String icon) {
      this.icon = icon;
  }
  
  private TileType(final DrawType dt) {
      this.dt = dt;
  }
  
  public DrawType getDrawType(){
    return dt;
  }
  
  public String getIcon(){
    return icon;
  }
  
}
