package thelaststand.app.game.data
{
   public class GearType
   {
      
      public static const UNKNOWN:uint = 0;
      
      public static const PASSIVE:uint = 1;
      
      public static const ACTIVE:uint = 2;
      
      public static const CONSUMABLE:uint = 4;
      
      public static const EXPLOSIVE:uint = 8;
      
      public static const IMPROVISED:uint = 16;
      
      public function GearType()
      {
         super();
         throw new Error("GearType cannot be directly instantiated.");
      }
   }
}

