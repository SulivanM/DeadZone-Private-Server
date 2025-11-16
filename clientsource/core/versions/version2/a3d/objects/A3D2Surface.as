package versions.version2.a3d.objects
{
   public class A3D2Surface
   {
      
      private var _indexBegin:int;
      
      private var _materialId:int;
      
      private var _numTriangles:int;
      
      public function A3D2Surface(param1:int, param2:int, param3:int)
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
      
      public function get materialId() : int
      {
         return this._materialId;
      }
      
      public function set materialId(param1:int) : void
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
         var _loc1_:String = "A3D2Surface [";
         _loc1_ += "indexBegin = " + this.indexBegin + " ";
         _loc1_ += "materialId = " + this.materialId + " ";
         _loc1_ += "numTriangles = " + this.numTriangles + " ";
         return _loc1_ + "]";
      }
   }
}

