package versions.version1.a3d.geometry
{
   import flash.utils.ByteArray;
   
   public class A3DIndexBuffer
   {
      
      private var _byteBuffer:ByteArray;
      
      private var _indexCount:int;
      
      public function A3DIndexBuffer(param1:ByteArray, param2:int)
      {
         super();
         this._byteBuffer = param1;
         this._indexCount = param2;
      }
      
      public function get byteBuffer() : ByteArray
      {
         return this._byteBuffer;
      }
      
      public function set byteBuffer(param1:ByteArray) : void
      {
         this._byteBuffer = param1;
      }
      
      public function get indexCount() : int
      {
         return this._indexCount;
      }
      
      public function set indexCount(param1:int) : void
      {
         this._indexCount = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DIndexBuffer [";
         _loc1_ += "byteBuffer = " + this.byteBuffer + " ";
         _loc1_ += "indexCount = " + this.indexCount + " ";
         return _loc1_ + "]";
      }
   }
}

