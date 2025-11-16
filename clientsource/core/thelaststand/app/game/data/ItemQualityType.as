package thelaststand.app.game.data
{
   public class ItemQualityType
   {
      
      public static const NONE:int = int.MIN_VALUE;
      
      public static const GREY:int = -1;
      
      public static const WHITE:int = 0;
      
      public static const GREEN:int = 1;
      
      public static const BLUE:int = 2;
      
      public static const PURPLE:int = 3;
      
      public static const RARE:int = 50;
      
      public static const UNIQUE:int = 51;
      
      public static const INFAMOUS:int = 52;
      
      public static const PREMIUM:int = 100;
      
      public function ItemQualityType()
      {
         super();
         throw new Error("ItemQualityType cannot be directly instantiated.");
      }
      
      public static function getValue(param1:String) : uint
      {
         return int(ItemQualityType[param1.toUpperCase()]);
      }
      
      public static function getName(param1:int) : String
      {
         switch(param1)
         {
            case -1:
               return "GREY";
            case 0:
               return "WHITE";
            case 1:
               return "GREEN";
            case 2:
               return "BLUE";
            case 3:
               return "PURPLE";
            case 50:
               return "RARE";
            case 51:
               return "UNIQUE";
            case 52:
               return "INFAMOUS";
            case 100:
               return "PREMIUM";
            default:
               return "";
         }
      }
      
      public static function isSpecial(param1:int) : Boolean
      {
         switch(param1)
         {
            case RARE:
            case UNIQUE:
            case INFAMOUS:
               return true;
            default:
               return false;
         }
      }
      
      public static function getQualityFromRating(param1:int) : uint
      {
         if(param1 <= -1)
         {
            return GREY;
         }
         if(param1 <= 5)
         {
            return WHITE;
         }
         if(param1 <= 10)
         {
            return GREEN;
         }
         if(param1 <= 15)
         {
            return BLUE;
         }
         if(param1 <= int.MAX_VALUE)
         {
            return PURPLE;
         }
         return WHITE;
      }
   }
}

