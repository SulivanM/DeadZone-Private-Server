package thelaststand.app.game.data
{
   public class Gender
   {
      
      public static const MALE:String = "male";
      
      public static const FEMALE:String = "female";
      
      public static const UNKNOWN:String = "unknown";
      
      public function Gender()
      {
         super();
         throw new Error("Gender cannot be directly instantiated.");
      }
   }
}

