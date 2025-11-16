package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.Material;
   
   use namespace alternativa3d;
   
   public class Surface
   {
      
      public var material:Material;
      
      public var indexBegin:int = 0;
      
      public var numTriangles:int = 0;
      
      alternativa3d var object:Object3D;
      
      public function Surface()
      {
         super();
      }
      
      public function clone() : Surface
      {
         var _loc1_:Surface = new Surface();
         _loc1_.alternativa3d::object = this.alternativa3d::object;
         _loc1_.material = this.material;
         _loc1_.indexBegin = this.indexBegin;
         _loc1_.numTriangles = this.numTriangles;
         return _loc1_;
      }
   }
}

