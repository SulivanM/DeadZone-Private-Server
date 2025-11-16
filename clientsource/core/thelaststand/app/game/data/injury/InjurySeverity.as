package thelaststand.app.game.data.injury
{
   public class InjurySeverity
   {
      
      public static const MINOR:String = "minor";
      
      public static const MODERATE:String = "moderate";
      
      public static const SERIOUS:String = "serious";
      
      public static const SEVERE:String = "severe";
      
      public static const CRITICAL:String = "critical";
      
      public function InjurySeverity()
      {
         super();
         throw new Error("InjurySeverity cannot be directly instantiated.");
      }
      
      public static function getColor(param1:String) : uint
      {
         switch(param1)
         {
            case InjurySeverity.MINOR:
               return 16630807;
            case InjurySeverity.MODERATE:
               return 16622364;
            case InjurySeverity.SERIOUS:
               return 16544010;
            case InjurySeverity.SEVERE:
               return 14901820;
            case InjurySeverity.CRITICAL:
               return 11800078;
            default:
               return 0;
         }
      }
   }
}

