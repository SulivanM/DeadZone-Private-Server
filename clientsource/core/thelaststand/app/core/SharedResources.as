package thelaststand.app.core
{
   import flash.display.BitmapData;
   
   public class SharedResources
   {
      
      public static var loadingBitmapInstance:BitmapData;
      
      public static var logoBitmapInstance:BitmapData;
      
      public static var kongregateAPI:*;
      
      public function SharedResources()
      {
         super();
         throw new Error("SharedResources cannot be directly instantiated.");
      }
   }
}

