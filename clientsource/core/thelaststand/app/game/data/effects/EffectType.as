package thelaststand.app.game.data.effects
{
   import thelaststand.app.game.data.GameResources;
   import thelaststand.common.resources.ResourceManager;
   
   public class EffectType
   {
      
      private static var _types:Array;
      
      public function EffectType()
      {
         super();
         throw new Error("EffectType cannot be directly instantiated.");
      }
      
      public static function getTypeName(param1:int) : String
      {
         setTypes();
         return _types[param1];
      }
      
      public static function getTypeValue(param1:String) : int
      {
         setTypes();
         return _types.indexOf(param1);
      }
      
      public static function getResourceProductionTypeValue(param1:String) : int
      {
         switch(param1)
         {
            case GameResources.WOOD:
               return EffectType.getTypeValue("WoodProduction");
            case GameResources.METAL:
               return EffectType.getTypeValue("MetalProduction");
            case GameResources.CLOTH:
               return EffectType.getTypeValue("ClothProduction");
            case GameResources.AMMUNITION:
               return EffectType.getTypeValue("AmmoProduction");
            case GameResources.FOOD:
               return EffectType.getTypeValue("FoodProduction");
            case GameResources.WATER:
               return EffectType.getTypeValue("WaterProduction");
            default:
               return -1;
         }
      }
      
      private static function setTypes() : void
      {
         if(_types != null)
         {
            return;
         }
         var _loc1_:XML = ResourceManager.getInstance().getResource("xml/effects.xml").content;
         _types = _loc1_.types.toString().replace(/\s/ig,"").split(",");
      }
   }
}

