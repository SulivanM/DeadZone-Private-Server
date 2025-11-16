package thelaststand.app.game.entities.buildings
{
   import flash.utils.getDefinitionByName;
   
   public class BuildingEntityFactory
   {
      
      private static var forceCompile:Array = [AllianceFlagEntity,FuelGeneratorEntity,WireTrapEntity,TrapGunBarrelEntity,StadiumButtonEntity];
      
      public function BuildingEntityFactory()
      {
         super();
         throw new Error("BuildingEntityFactory cannot be directly instantiated.");
      }
      
      public static function create(param1:XML) : BuildingEntity
      {
         var _loc3_:Class = null;
         var _loc2_:String = param1.hasOwnProperty("@entity") ? param1.@entity.toString() + "Entity" : null;
         if(_loc2_ != null)
         {
            _loc3_ = getDefinitionByName("thelaststand.app.game.entities.buildings." + _loc2_) as Class;
            if(_loc3_ != null)
            {
               return new _loc3_();
            }
         }
         if(param1.@type == "junk")
         {
            return new JunkBuildingEntity();
         }
         if(param1.@door == "1")
         {
            return new DoorBuildingEntity();
         }
         return new BuildingEntity();
      }
   }
}

