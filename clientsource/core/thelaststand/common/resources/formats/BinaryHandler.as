package thelaststand.common.resources.formats
{
   import flash.net.URLLoaderDataFormat;
   import flash.utils.ByteArray;
   
   public class BinaryHandler extends GenericHandler
   {
      
      private var _data:ByteArray;
      
      public function BinaryHandler()
      {
         super();
         _loader.dataFormat = URLLoaderDataFormat.BINARY;
      }
      
      override public function dispose() : void
      {
         this._data = null;
         super.dispose();
      }
      
      override public function getContent() : *
      {
         if(!loaded)
         {
            return null;
         }
         if(!this._data)
         {
            this._data = ByteArray(_loader.data);
         }
         return this._data;
      }
      
      override public function get id() : String
      {
         return "bin";
      }
   }
}

