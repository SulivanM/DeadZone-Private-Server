package thelaststand.app.game.data.injury
{
   public class InjuryCause
   {
      
      public static const UNKNOWN:String = "unknown";
      
      public static const BLUNT:String = "blunt";
      
      public static const SHARP:String = "sharp";
      
      public static const HEAT:String = "heat";
      
      public static const BULLET:String = "bullet";
      
      public static const ILLNESS:String = "illness";
      
      public function InjuryCause()
      {
         super();
         throw new Error("InjuryCause cannot be directly instantiated.");
      }
   }
}

