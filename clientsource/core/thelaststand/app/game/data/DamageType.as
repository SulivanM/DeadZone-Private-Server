package thelaststand.app.game.data
{
   public class DamageType
   {
      
      public static const UNKNOWN:uint = 0;
      
      public static const MELEE:uint = 1;
      
      public static const PROJECTILE:uint = 2;
      
      public static const EXPLOSIVE:uint = 3;
      
      public function DamageType()
      {
         super();
         throw new Error("DamageType cannot be directly instantiated.");
      }
      
      public static function getValue(param1:String) : uint
      {
         if(param1 == null)
         {
            return UNKNOWN;
         }
         switch(param1.toUpperCase())
         {
            case "MELEE":
               return MELEE;
            case "PROJECTILE":
               return PROJECTILE;
            case "EXPLOSIVE":
               return EXPLOSIVE;
            default:
               return UNKNOWN;
         }
      }
   }
}

