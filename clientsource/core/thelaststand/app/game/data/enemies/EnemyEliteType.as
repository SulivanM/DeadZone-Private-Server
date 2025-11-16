package thelaststand.app.game.data.enemies
{
   public class EnemyEliteType
   {
      
      public static const NONE:uint = 0;
      
      public static const RARE:uint = 1;
      
      public static const UNIQUE:uint = 2;
      
      public function EnemyEliteType()
      {
         super();
      }
      
      public static function getValue(param1:String) : uint
      {
         if(param1 == null)
         {
            return NONE;
         }
         switch(param1.toUpperCase())
         {
            case "UNIQUE":
               return UNIQUE;
            case "RARE":
               return RARE;
            case "NONE":
         }
         return NONE;
      }
      
      public static function getName(param1:uint) : String
      {
         switch(param1)
         {
            case 2:
               return "UNIQUE";
            case 1:
               return "RARE";
            case 0:
         }
         return "NONE";
      }
   }
}

