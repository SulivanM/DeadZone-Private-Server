package versions.version1.a3d.geometry
{
   import commons.Id;
   
   public class A3DGeometry
   {
      
      private var _id:Id;
      
      private var _indexBuffer:A3DIndexBuffer;
      
      private var _vertexBuffers:Vector.<A3DVertexBuffer>;
      
      public function A3DGeometry(param1:Id, param2:A3DIndexBuffer, param3:Vector.<A3DVertexBuffer>)
      {
         super();
         this._id = param1;
         this._indexBuffer = param2;
         this._vertexBuffers = param3;
      }
      
      public function get id() : Id
      {
         return this._id;
      }
      
      public function set id(param1:Id) : void
      {
         this._id = param1;
      }
      
      public function get indexBuffer() : A3DIndexBuffer
      {
         return this._indexBuffer;
      }
      
      public function set indexBuffer(param1:A3DIndexBuffer) : void
      {
         this._indexBuffer = param1;
      }
      
      public function get vertexBuffers() : Vector.<A3DVertexBuffer>
      {
         return this._vertexBuffers;
      }
      
      public function set vertexBuffers(param1:Vector.<A3DVertexBuffer>) : void
      {
         this._vertexBuffers = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DGeometry [";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "indexBuffer = " + this.indexBuffer + " ";
         _loc1_ += "vertexBuffers = " + this.vertexBuffers + " ";
         return _loc1_ + "]";
      }
   }
}

