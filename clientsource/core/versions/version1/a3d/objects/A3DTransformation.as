package versions.version1.a3d.objects
{
   import commons.A3DMatrix;
   
   public class A3DTransformation
   {
      
      private var _matrix:A3DMatrix;
      
      public function A3DTransformation(param1:A3DMatrix)
      {
         super();
         this._matrix = param1;
      }
      
      public function get matrix() : A3DMatrix
      {
         return this._matrix;
      }
      
      public function set matrix(param1:A3DMatrix) : void
      {
         this._matrix = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DTransformation [";
         _loc1_ += "matrix = " + this.matrix + " ";
         return _loc1_ + "]";
      }
   }
}

