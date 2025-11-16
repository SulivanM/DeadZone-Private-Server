package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   
   public final class ItemCounterType
   {
      
      private static var _names:Dictionary;
      
      public static const None:uint = 0;
      
      public static const ZombieKills:uint = 1;
      
      public static const HumanKills:uint = 2;
      
      public static const SurvivorKills:uint = 3;
      
      public function ItemCounterType()
      {
         super();
         throw new Error("ItemCounterType cannot be directly instantiated.");
      }
      
      public static function getName(param1:uint) : String
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:uint = 0;
         if(_names == null)
         {
            _names = new Dictionary();
            for each(_loc2_ in describeType(ItemCounterType).constant)
            {
               _loc3_ = _loc2_.@name.toString();
               _loc4_ = uint(ItemCounterType[_loc3_]);
               _names[_loc4_] = _loc3_;
            }
         }
         return String(_names[param1]);
      }
   }
}

