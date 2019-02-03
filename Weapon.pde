abstract class Weapon extends Item implements Actionable{
  final WeaponSetting weaponSetting;
  Weapon(int x, int y, int r, String name, WeaponSetting weaponSetting){
    super(x, y, r, name);
    this.weaponSetting = weaponSetting;
  }
}
