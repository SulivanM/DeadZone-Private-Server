package alternativa.engine3d.lights
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   
   use namespace alternativa3d;
   
   public class AmbientLight extends Light3D
   {
      
      public function AmbientLight(param1:uint)
      {
         super();
         this.alternativa3d::type = alternativa3d::AMBIENT;
         this.color = param1;
      }
      
      override public function calculateBoundBox() : void
      {
      }
      
      override alternativa3d function calculateVisibility(param1:Camera3D) : void
      {
         param1.alternativa3d::ambient[0] += (color >> 16 & 0xFF) * intensity / 255;
         param1.alternativa3d::ambient[1] += (color >> 8 & 0xFF) * intensity / 255;
         param1.alternativa3d::ambient[2] += (color & 0xFF) * intensity / 255;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:AmbientLight = new AmbientLight(color);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
   }
}

