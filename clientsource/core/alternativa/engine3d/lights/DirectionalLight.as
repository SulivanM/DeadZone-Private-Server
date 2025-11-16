package alternativa.engine3d.lights
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   
   use namespace alternativa3d;
   
   public class DirectionalLight extends Light3D
   {
      
      public function DirectionalLight(param1:uint)
      {
         super();
         this.alternativa3d::type = alternativa3d::DIRECTIONAL;
         this.color = param1;
      }
      
      public function lookAt(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = param1 - this.x;
         var _loc5_:Number = param2 - this.y;
         var _loc6_:Number = param3 - this.z;
         rotationX = Math.atan2(_loc6_,Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_)) - Math.PI / 2;
         rotationY = 0;
         rotationZ = -Math.atan2(_loc4_,_loc5_);
      }
      
      override public function calculateBoundBox() : void
      {
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:DirectionalLight = new DirectionalLight(color);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
   }
}

