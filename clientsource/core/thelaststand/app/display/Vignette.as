package thelaststand.app.display
{
   import flash.display.Bitmap;
   
   public class Vignette extends Bitmap
   {
      
      public function Vignette()
      {
         super();
         bitmapData = new BmpOverlayVignette();
         smoothing = true;
         cacheAsBitmap = true;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         bitmapData.dispose();
         bitmapData = null;
      }
   }
}

