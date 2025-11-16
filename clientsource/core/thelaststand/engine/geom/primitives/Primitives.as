package thelaststand.engine.geom.primitives
{
   import alternativa.engine3d.primitives.Box;
   import alternativa.engine3d.primitives.GeoSphere;
   import thelaststand.engine.alternativa.engine3d.primitives.Plane;
   import thelaststand.engine.alternativa.engine3d.primitives.SimplePlane;
   
   public class Primitives
   {
      
      public static const PLANE:Plane = new Plane(1,1);
      
      public static const PLANE_DOUBLE_SIDED:Plane = new Plane(1,1,true);
      
      public static const SIMPLE_PLANE:SimplePlane = new SimplePlane();
      
      public static const SIMPLE_PLANE_DOUBLE_SIDED:SimplePlane = new SimplePlane(1,1,true);
      
      public static const BOX:Box = new Box(1,1,1);
      
      public static const SPHERE:GeoSphere = new GeoSphere(1,5);
      
      public function Primitives()
      {
         super();
         throw new Error("Primitives cannot be directly instantiated.");
      }
   }
}

