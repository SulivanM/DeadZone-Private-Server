package thelaststand.app.game.data
{
   public class ClothingAccessory extends Gear
   {
      
      public function ClothingAccessory(param1:String = null)
      {
         super(param1);
      }
      
      override public function clone() : Item
      {
         var _loc1_:ClothingAccessory = new ClothingAccessory(_type);
         cloneBaseProperties(_loc1_);
         _loc1_.survivorClasses = survivorClasses.concat();
         _loc1_.weaponClasses = weaponClasses.concat();
         _loc1_.weaponTypes = weaponTypes;
         _loc1_.ammoTypes = ammoTypes;
         return _loc1_;
      }
      
      override public function toString() : String
      {
         return "(ClothingAccessory id=" + id + ", type=" + type + ", level=" + level + ", mods=" + getMod(0) + "," + getMod(1) + ")";
      }
      
      override protected function setXML(param1:XML) : void
      {
         super.setXML(param1);
         _gearType = GearType.PASSIVE;
      }
   }
}

