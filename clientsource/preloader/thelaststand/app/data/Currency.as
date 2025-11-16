package thelaststand.app.data
{
   public class Currency
   {
      
      public static const FUEL:String = "Coins";
      
      public static const FACEBOOK_CREDITS:String = "FBC";
      
      public static const US_DOLLARS:String = "USD";
      
      public static const KONGREGATE_KREDS:String = "KKR";
      
      public static const ALLIANCE_TOKENS:String = "ATK";
      
      public function Currency()
      {
         super();
         throw new Error("Currency cannot be directly instantiated.");
      }
   }
}

