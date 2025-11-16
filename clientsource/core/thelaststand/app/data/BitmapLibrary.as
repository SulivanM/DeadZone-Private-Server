package thelaststand.app.data
{
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   
   public class BitmapLibrary
   {
      
      private static var currencyIconLookup:Dictionary = new Dictionary(true);
      
      public function BitmapLibrary()
      {
         super();
         throw new Error("BitmapLibrary cannot be directly instantiated.");
      }
      
      public static function getIcon(param1:String) : BitmapData
      {
         if(param1 == Currency.US_DOLLARS)
         {
            return null;
         }
         var _loc2_:BitmapData = currencyIconLookup[param1];
         if(_loc2_ == null)
         {
            switch(param1)
            {
               case Currency.FUEL:
                  _loc2_ = new BmpIconFuel();
                  break;
               case Currency.FACEBOOK_CREDITS:
                  _loc2_ = new BmpIconFBCredit();
                  break;
               case Currency.KONGREGATE_KREDS:
                  _loc2_ = new BmpIconKongKreds();
                  break;
               case Currency.ALLIANCE_TOKENS:
                  _loc2_ = new BmpIconAllianceTokensSmall();
            }
            currencyIconLookup[param1] = _loc2_;
         }
         return _loc2_;
      }
   }
}

