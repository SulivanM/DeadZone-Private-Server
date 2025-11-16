package thelaststand.app.game.data
{
   public class WeaponType
   {
      
      private static var _names:Array;
      
      public static const NONE:uint = 0;
      
      public static const AUTO:uint = 1;
      
      public static const SEMI_AUTO:uint = 2;
      
      public static const ONE_HANDED:uint = 4;
      
      public static const TWO_HANDED:uint = 8;
      
      public static const IMPROVISED:uint = 16;
      
      public static const EXPLOSIVE:uint = 32;
      
      public static const BLADE:uint = 64;
      
      public static const BLUNT:uint = 128;
      
      public static const AXE:uint = 256;
      
      public static const SPECIAL:uint = 512;
      
      public function WeaponType()
      {
         super();
         throw new Error("WeaponType cannot be directly instantiated.");
      }
      
      public static function getNames() : Array
      {
         if(_names == null)
         {
            _names = ["NONE","AUTO","SEMI_AUTO","ONE_HANDED","TWO_HANDED","IMPROVISED","EXPLOSIVE","BLADE","BLUNT","AXE","SPECIAL"];
         }
         return _names;
      }
   }
}

