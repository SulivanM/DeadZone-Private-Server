package thelaststand.common.resources.formats
{
   import flash.utils.ByteArray;
   import flash.utils.clearTimeout;
   
   public class XMLHandler extends GenericHandler
   {
      
      private var _data:XML;
      
      private var _timeout:uint;
      
      public function XMLHandler()
      {
         super();
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
            this._data = new XML(_loader.data);
         }
         return this._data;
      }
      
      override public function getContentAsByteArray() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeUTFBytes(this._data);
         _loc1_.position = 0;
         return _loc1_;
      }
      
      override public function loadFromByteArray(param1:ByteArray, param2:* = null) : void
      {
         _loaded = true;
         _loading = false;
         param1.position = 0;
         this._data = new XML(param1.readUTFBytes(param1.length));
         loadCompleted.dispatch(this);
      }
      
      override public function pauseLoad() : void
      {
         clearTimeout(this._timeout);
         super.pauseLoad();
      }
      
      override public function get id() : String
      {
         return "xml";
      }
      
      override public function get extensions() : Array
      {
         return ["xml","htm","html"];
      }
   }
}

