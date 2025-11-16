package versions.version2.a3d.geometry
{
   import flash.utils.ByteArray;
   
   public class A3D2IndexBuffer
   {
      
      private var _byteBuffer:ByteArray;
      
      private var _id:int;
      
      private var _indexCount:int;
      
      public function A3D2IndexBuffer(param1:ByteArray, param2:int, param3:int)
      {
         super();
         this._byteBuffer = param1;
         this._id = param2;
         this._indexCount = param3;
      }
      
      public function get byteBuffer() : ByteArray
      {
         return this._byteBuffer;
      }
      
      public function set byteBuffer(param1:ByteArray) : void
      {
         this._byteBuffer = param1;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
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
         var _loc1_:String = "A3D2IndexBuffer [";
         _loc1_ += "byteBuffer = " + this.byteBuffer + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "indexCount = " + this.indexCount + " ";
         return _loc1_ + "]";
      }
   }
}

