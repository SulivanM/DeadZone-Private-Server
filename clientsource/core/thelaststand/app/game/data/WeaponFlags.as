package thelaststand.app.game.data
{
   public class WeaponFlags
   {
      
      public static const NONE:uint = 0;
      
      public static const SUPPRESSED:uint = 1;
      
      public function WeaponFlags()
      {
         super();
         throw new Error("WeaponFlags cannot be directly instantiated.");
      }
      
      public static function getFlagByName(param1:String) : uint
      {
         switch(param1)
         {
            case "suppressed":
               return SUPPRESSED;
            default:
               return NONE;
         }
      }
   }
}

