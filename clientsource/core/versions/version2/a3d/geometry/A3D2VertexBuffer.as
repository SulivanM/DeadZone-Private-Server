package versions.version2.a3d.geometry
{
   import flash.utils.ByteArray;
   
   public class A3D2VertexBuffer
   {
      
      private var _attributes:Vector.<A3D2VertexAttributes>;
      
      private var _byteBuffer:ByteArray;
      
      private var _id:int;
      
      private var _vertexCount:uint;
      
      public function A3D2VertexBuffer(param1:Vector.<A3D2VertexAttributes>, param2:ByteArray, param3:int, param4:uint)
      {
         super();
         this._attributes = param1;
         this._byteBuffer = param2;
         this._id = param3;
         this._vertexCount = param4;
      }
      
      public function get attributes() : Vector.<A3D2VertexAttributes>
      {
         return this._attributes;
      }
      
      public function set attributes(param1:Vector.<A3D2VertexAttributes>) : void
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
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
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
         var _loc1_:String = "A3D2VertexBuffer [";
         _loc1_ += "attributes = " + this.attributes + " ";
         _loc1_ += "byteBuffer = " + this.byteBuffer + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "vertexCount = " + this.vertexCount + " ";
         return _loc1_ + "]";
      }
   }
}

