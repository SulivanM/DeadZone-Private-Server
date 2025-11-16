package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.shadows.Shadow;
   
   use namespace alternativa3d;
   
   public class Light3D extends Object3D
   {
      
      alternativa3d static const AMBIENT:int = 1;
      
      alternativa3d static const DIRECTIONAL:int = 2;
      
      alternativa3d static const OMNI:int = 3;
      
      alternativa3d static const SPOT:int = 4;
      
      alternativa3d static const SHADOW_BIT:int = 256;
      
      private static var lastLightNumber:uint = 0;
      
      alternativa3d var type:int = 0;
      
      alternativa3d var _shadow:Shadow;
      
      public var color:uint;
      
      public var intensity:Number = 1;
      
      alternativa3d var lightToObjectTransform:Transform3D = new Transform3D();
      
      alternativa3d var lightID:String;
      
      alternativa3d var red:Number = 0;
      
      alternativa3d var green:Number = 0;
      
      alternativa3d var blue:Number = 0;
      
      public function Light3D()
      {
         super();
         this.alternativa3d::lightID = "l" + lastLightNumber.toString(16);
         name = "L" + (lastLightNumber++).toString();
      }
      
      override alternativa3d function calculateVisibility(param1:Camera3D) : void
      {
         if(this.intensity != 0 && this.color > 0)
         {
            param1.alternativa3d::lights[param1.alternativa3d::lightsLength] = this;
            ++param1.alternativa3d::lightsLength;
         }
      }
      
      alternativa3d function checkBound(param1:Object3D) : Boolean
      {
         return true;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Light3D = new Light3D();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         super.clonePropertiesFrom(param1);
         var _loc2_:Light3D = param1 as Light3D;
         this.color = _loc2_.color;
         this.intensity = _loc2_.intensity;
      }
      
      public function get shadow() : Shadow
      {
         return this.alternativa3d::_shadow;
      }
      
      public function set shadow(param1:Shadow) : void
      {
         if(this.alternativa3d::_shadow != null)
         {
            this.alternativa3d::_shadow.alternativa3d::_light = null;
         }
         this.alternativa3d::_shadow = param1;
         if(param1 != null)
         {
            param1.alternativa3d::_light = this;
         }
         this.alternativa3d::type = param1 != null ? this.alternativa3d::type | alternativa3d::SHADOW_BIT : this.alternativa3d::type & ~alternativa3d::SHADOW_BIT;
      }
   }
}

