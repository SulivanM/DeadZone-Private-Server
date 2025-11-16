package versions.version1.a3d.geometry
{
   import flash.utils.ByteArray;
   
   public class A3DVertexBuffer
   {
      
      private var _attributes:Vector.<int>;
      
      private var _byteBuffer:ByteArray;
      
      private var _vertexCount:uint;
      
      public function A3DVertexBuffer(param1:Vector.<int>, param2:ByteArray, param3:uint)
      {
         super();
         this._attributes = param1;
         this._byteBuffer = param2;
         this._vertexCount = param3;
      }
      
      public function get attributes() : Vector.<int>
      {
         return this._attributes;
      }
      
      public function set attributes(param1:Vector.<int>) : void
      {
         this._attributes = param1;
      }
      
      public function get byteBuffer() : ByteArray
      {
         return this._byteBuffer;
      }
      
      public function set byteBuffer(param1:ByteArray) : void
      {
         this._byteBuffer = param1;
      }
      
      public function get vertexCount() : uint
      {
         return this._vertexCount;
      }
      
      public function set vertexCount(param1:uint) : void
      {
         this._vertexCount = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DVertexBuffer [";
         _loc1_ += "attributes = " + this.attributes + " ";
         _loc1_ += "byteBuffer = " + this.byteBuffer + " ";
         _loc1_ += "vertexCount = " + this.vertexCount + " ";
         return _loc1_ + "]";
      }
   }
}

