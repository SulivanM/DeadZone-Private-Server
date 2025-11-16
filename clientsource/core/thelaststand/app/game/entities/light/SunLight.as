package thelaststand.app.game.entities.light
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.lights.AmbientLight;
   import alternativa.engine3d.lights.DirectionalLight;
   import alternativa.engine3d.shadows.DirectionalLightShadow;
   import alternativa.engine3d.shadows.Shadow;
   import com.deadreckoned.threshold.display.Color;
   import flash.display.BitmapData;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.network.Network;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class SunLight extends GameEntity
   {
      
      private const BmpSunlightTable:Class = SunLight_BmpSunlightTable;
      
      protected var _lightAmb:AmbientLight;
      
      protected var _lightDir:DirectionalLight;
      
      protected var _shadow:DirectionalLightShadow;
      
      private var _lightTable:Array;
      
      private var _time:int = 0;
      
      private var _ambientIntensity:Number = 1;
      
      public var timeChanged:Signal;
      
      public function SunLight()
      {
         super();
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         passable = true;
         name = "sun-light";
         this.timeChanged = new Signal(int);
         addedToScene.add(this.onAddedToScene);
         this._lightDir = new DirectionalLight(16777215);
         this._lightDir.visible = Settings.getInstance().staticLights;
         this._lightAmb = new AmbientLight(16777215);
         this._lightAmb.intensity = 0.5;
         var _loc1_:BitmapData = new this.BmpSunlightTable().bitmapData;
         this._lightTable = generateLightTable(_loc1_);
         _loc1_.dispose();
         asset = new Object3D();
         asset.addChild(this._lightDir);
         asset.addChild(this._lightAmb);
         this.updateLight();
         Settings.getInstance().settingChanged.add(this.onSettingChanged);
      }
      
      public static function generateLightTable(param1:BitmapData) : Array
      {
         var _loc5_:Object = null;
         var _loc2_:Array = [];
         var _loc3_:int = param1.width;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = {};
            _loc2_.push(_loc5_);
            _loc5_.c = param1.getPixel(_loc4_,0);
            _loc5_.a = param1.getPixel(_loc4_,1) / 16777215 / 0.5;
            _loc5_.d = param1.getPixel(_loc4_,2) / 16777215 / 0.5;
            _loc4_++;
         }
         return _loc2_;
      }
      
      override public function dispose() : void
      {
         this._lightTable = null;
         this._lightDir.shadow = null;
         this._lightDir = null;
         this._lightAmb = null;
         this.timeChanged.removeAll();
         addedToScene.remove(this.onAddedToScene);
         Settings.getInstance().settingChanged.remove(this.onSettingChanged);
         super.dispose();
      }
      
      protected function updateLight() : void
      {
         this.updateDirection();
         this.updateColor();
         this.shadow = this._shadow;
      }
      
      protected function updateDirection() : void
      {
         var _loc1_:Number = this._time / 2400;
         if(_loc1_ > 0.75)
         {
            _loc1_ -= 0.5;
         }
         var _loc2_:Number = _loc1_ * Math.PI * 2;
         this._lightDir.x = -Math.sin(_loc2_) * 10;
         this._lightDir.y = Math.sin(_loc2_) * 10 * 1.5;
         this._lightDir.z = (1 - Math.cos(_loc2_)) * 0.5 * 10;
         this._lightDir.lookAt(0,0,0);
      }
      
      protected function updateColor() : void
      {
         var _loc1_:Number = this._time / 2400;
         var _loc2_:int = int(this._lightTable.length);
         var _loc3_:int = Math.min(int(_loc2_ * _loc1_),_loc2_ - 1);
         var _loc4_:Object = this._lightTable[_loc3_];
         var _loc5_:Object = this._lightTable[(_loc3_ >= _loc2_ - 1 ? _loc3_ - _loc2_ : _loc3_) + 1];
         var _loc6_:Number = _loc1_ * _loc2_ - _loc3_;
         this._lightAmb.color = this._lightDir.color = Color.interpolate(_loc4_.c,_loc5_.c,_loc6_);
         this._ambientIntensity = _loc4_.a + (_loc5_.a - _loc4_.a) * _loc6_;
         this._lightAmb.intensity = this._ambientIntensity * (Settings.getInstance().staticLights ? 1 : 1.5);
         this._lightDir.intensity = Math.max(0.4,_loc4_.d + (_loc5_.d - _loc4_.d) * _loc6_);
         var _loc7_:Number = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("AmbientLight"));
         this._lightAmb.intensity += this._lightAmb.intensity * (_loc7_ / 100);
      }
      
      private function realTimeToGameTime(param1:Date) : int
      {
         var _loc2_:Date = new Date(2012,0,1,0,0,0);
         var _loc3_:Number = param1.time - _loc2_.time;
         var _loc4_:Number = _loc3_ * (24 / 10);
         var _loc5_:Date = new Date(_loc2_.time + _loc4_);
         var _loc6_:int = Math.round(2400 * (_loc5_.hours / 24));
         var _loc7_:int = Math.round(100 * (_loc5_.minutes / 60));
         return _loc6_ + _loc7_;
      }
      
      private function onAddedToScene(param1:SunLight) : void
      {
         this.time = this.realTimeToGameTime(new Date());
      }
      
      private function onSettingChanged(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case "shadows":
               this.shadow = this._shadow;
               break;
            case "staticLights":
               this._lightDir.visible = Settings.getInstance().staticLights;
               this.updateLight();
         }
      }
      
      public function get intensity() : Number
      {
         return this._ambientIntensity + this._lightDir.intensity;
      }
      
      public function get time() : int
      {
         return this._time;
      }
      
      public function set time(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 += 2400;
         }
         else if(param1 >= 2400)
         {
            param1 -= 2400;
         }
         this._time = param1;
         this.updateLight();
         this.timeChanged.dispatch(this._time);
      }
      
      public function get shadow() : DirectionalLightShadow
      {
         return this._shadow;
      }
      
      public function set shadow(param1:DirectionalLightShadow) : void
      {
         this._shadow = param1;
         this._lightDir.shadow = Settings.getInstance().shadows == Settings.SHADOWS_OFF ? null : (this._lightDir.intensity > 0 ? this._shadow : null);
      }
   }
}

