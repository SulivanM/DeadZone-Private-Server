package alternativa.engine3d.core
{
   import alternativa.engine3d.objects.Surface;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class RayIntersectionData
   {
      
      public var object:Object3D;
      
      public var point:Vector3D;
      
      public var surface:Surface;
      
      public var time:Number;
      
      public var uv:Point;
      
      public function RayIntersectionData()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[RayIntersectionData " + this.object + ", " + this.point + ", " + this.uv + ", " + this.time + "]";
      }
   }
}

