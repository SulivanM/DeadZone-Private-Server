package versions.version1.a3d.objects
{
   import commons.Id;
   
   public class A3DSurface
   {
      
      private var _indexBegin:int;
      
      private var _materialId:Id;
      
      private var _numTriangles:int;
      
      public function A3DSurface(param1:int, param2:Id, param3:int)
      {
         super();
         this._indexBegin = param1;
         this._materialId = param2;
         this._numTriangles = param3;
      }
      
      public function get indexBegin() : int
      {
         return this._indexBegin;
      }
      
      public function set indexBegin(param1:int) : void
      {
         this._indexBegin = param1;
      }
      
      public function get materialId() : Id
      {
         return this._materialId;
      }
      
      public function set materialId(param1:Id) : void
      {
         this._materialId = param1;
      }
      
      public function get numTriangles() : int
      {
         return this._numTriangles;
      }
      
      public function set numTriangles(param1:int) : void
      {
         this._numTriangles = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DSurface [";
         _loc1_ += "indexBegin = " + this.indexBegin + " ";
         _loc1_ += "materialId = " + this.materialId + " ";
         _loc1_ += "numTriangles = " + this.numTriangles + " ";
         return _loc1_ + "]";
      }
   }
}

