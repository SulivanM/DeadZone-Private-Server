package thelaststand.engine.objects.light
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.lights.OmniLight;
   import thelaststand.app.core.Settings;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class OmniLightEntity extends GameEntity
   {
      
      private var _container:Object3D;
      
      private var _light:OmniLight;
      
      public function OmniLightEntity()
      {
         super();
         this._light = new OmniLight(16777215,0,1000);
         this._container = new Object3D();
         this._container.addChild(this._light);
         asset = this._container;
         passable = true;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         this._light.visible = Settings.getInstance().dynamicLights;
         Settings.getInstance().settingChanged.add(this.onSettingChanged);
      }
      
      override public function dispose() : void
      {
         Settings.getInstance().settingChanged.remove(this.onSettingChanged);
         super.dispose();
         this._light = null;
         this._container = null;
      }
      
      private function onSettingChanged(param1:String, param2:Object) : void
      {
         if(param1 == "dynamicLights")
         {
            this._light.visible = param2 === true;
         }
      }
      
      public function get light() : OmniLight
      {
         return this._light;
      }
   }
}

