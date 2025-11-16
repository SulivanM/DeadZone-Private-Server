package thelaststand.common.resources.formats
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   
   public class ImageHandler extends SWFHandler
   {
      
      private var _bitmapData:BitmapData;
      
      public function ImageHandler()
      {
         super();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._bitmapData)
         {
            this._bitmapData.dispose();
            this._bitmapData = null;
         }
      }
      
      override public function getContent() : *
      {
         if(!loaded)
         {
            return null;
         }
         if(!this._bitmapData)
         {
            try
            {
               this._bitmapData = Bitmap(_loader.content).bitmapData;
            }
            catch(e:Error)
            {
            }
         }
         return this._bitmapData;
      }
      
      override public function get id() : String
      {
         return "img";
      }
      
      override public function get extensions() : Array
      {
         return ["jpg","jpe","jpeg","gif","png"];
      }
   }
}

