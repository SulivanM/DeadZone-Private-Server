package thelaststand.app.game.entities.light
{
   import com.deadreckoned.threshold.display.Color;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.network.Network;
   
   public class IndoorLight extends SunLight
   {
      
      private var _color:uint = 9470333;
      
      private var _intensity:Number = 0.4;
      
      public function IndoorLight()
      {
         super();
      }
      
      override protected function updateLight() : void
      {
         this.updateDirection();
         updateColor();
         _lightAmb.color = new Color(_lightAmb.color).tint(this._color,0.25).RGB;
         _lightAmb.intensity *= this._intensity * 1.7;
         _lightDir.intensity *= this._intensity * 1.7;
         _lightDir.intensity = Math.max(0.25,_lightDir.intensity);
         var _loc1_:Number = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("AmbientLight"));
         _lightAmb.intensity += _lightAmb.intensity * (_loc1_ / 100);
         this.shadow = _shadow;
      }
      
      override protected function updateDirection() : void
      {
         _lightDir.x = -0.6;
         _lightDir.y = 0.5;
         _lightDir.z = 1;
         _lightDir.lookAt(0,0,0);
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = param1;
         this.updateLight();
      }
      
      override public function get intensity() : Number
      {
         return this._intensity;
      }
      
      public function set intensity(param1:Number) : void
      {
         this._intensity = param1;
         this.updateLight();
      }
   }
}

