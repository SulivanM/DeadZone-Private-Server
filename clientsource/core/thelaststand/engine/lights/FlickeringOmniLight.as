package thelaststand.engine.lights
{
   import alternativa.engine3d.lights.OmniLight;
   import thelaststand.engine.animation.IAnimatingObject;
   
   public class FlickeringOmniLight extends OmniLight implements IAnimatingObject
   {
      
      private var _f:Number = 0;
      
      public var time:Number = 0.05;
      
      public var maxIntensity:Number = 2.25;
      
      public var minIntensity:Number = 1.75;
      
      public function FlickeringOmniLight(param1:OmniLight = null)
      {
         super(16777215,1,1000);
         if(param1)
         {
            name = param1.name;
            color = param1.color;
            attenuationBegin = param1.attenuationBegin;
            attenuationEnd = param1.attenuationEnd;
            intensity = param1.intensity;
            x = param1.x;
            y = param1.y;
            z = param1.z;
         }
      }
      
      public function updateAnimation(param1:Number) : void
      {
         if(!visible)
         {
            return;
         }
         if(this._f >= this.time)
         {
            intensity = this.minIntensity + (this.maxIntensity - this.minIntensity) * Math.random();
            this._f = 0;
         }
         else
         {
            this._f += param1;
         }
      }
   }
}

