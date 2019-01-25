public class PatrolPoint extends Vec2{
  float waitTime;
  PatrolPoint(Vec2 v, float waitTime){
    super(v);
    this.waitTime = waitTime;
  }
}
