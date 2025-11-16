package thelaststand.app.game.gui.options
{
   import flash.events.MouseEvent;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UISpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.common.lang.Language;
   
   public class UIOptionsVideo extends UIComponent
   {
      
      private var _labelColWidth:int = 140;
      
      private var _valueColWidth:int = 140;
      
      private var _advanced:Boolean = false;
      
      private var _width:int;
      
      private var _preset:int;
      
      private var _lang:Language;
      
      private var _settings:Settings;
      
      private var btn_advanced:PushButton;
      
      private var txt_renderingLabel:BodyTextField;
      
      private var txt_renderingValue:BodyTextField;
      
      private var txt_preset:BodyTextField;
      
      private var txt_antialias:BodyTextField;
      
      private var txt_shadows:BodyTextField;
      
      private var txt_dynamicLights:BodyTextField;
      
      private var txt_staticLights:BodyTextField;
      
      private var txt_flash:BodyTextField;
      
      private var spinner_preset:UISpinner;
      
      private var spinner_antialias:UISpinner;
      
      private var spinner_shadows:UISpinner;
      
      private var spinner_flash:UISpinner;
      
      private var check_dynamicLights:CheckBox;
      
      private var check_staticLights:CheckBox;
      
      public function UIOptionsVideo()
      {
         var _loc1_:int = 0;
         super();
         this._lang = Language.getInstance();
         this._settings = Settings.getInstance();
         this._advanced = this._settings.getData("vidAdvanced",false);
         this.txt_renderingLabel = new BodyTextField({
            "text":this._lang.getString("options_vid_rendering").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_renderingLabel);
         this.txt_renderingValue = new BodyTextField({
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_renderingValue.text = (Global.softwareRendering ? this._lang.getString("options_vid_rsoft") : this._lang.getString("options_vid_rhard")).toUpperCase();
         addChild(this.txt_renderingValue);
         this.txt_preset = new BodyTextField({
            "text":this._lang.getString("options_vid_preset").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_preset);
         this._preset = this._settings.getData("vidPreset",4);
         var _loc2_:Array = this._lang.getEnum("options_vid_preset_values");
         this.spinner_preset = new UISpinner();
         this.spinner_preset.width = this._valueColWidth;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            this.spinner_preset.addItem(_loc2_[_loc1_],_loc1_);
            _loc1_++;
         }
         this.spinner_preset.selectItem(this._preset);
         this.spinner_preset.changed.add(this.onPresetSpinnerChanged);
         addChild(this.spinner_preset);
         this.btn_advanced = new PushButton(this._advanced ? this._lang.getString("options_vid_basic").toUpperCase() : this._lang.getString("options_vid_advanced").toUpperCase());
         this.btn_advanced.clicked.add(this.onClickedAdvance);
         addChild(this.btn_advanced);
         this.txt_antialias = new BodyTextField({
            "htmlText":this._lang.getString("options_vid_antialias").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_antialias.alpha = Global.softwareRendering ? 0.3 : 1;
         addChild(this.txt_antialias);
         this.spinner_antialias = new UISpinner();
         this.spinner_antialias.width = this._valueColWidth;
         this.spinner_antialias.changed.add(this.onAASettingChanged);
         addChild(this.spinner_antialias);
         var _loc3_:Array = this._lang.getEnum("options_vid_antialias_values");
         _loc1_ = 0;
         while(_loc1_ < _loc3_.length)
         {
            this.spinner_antialias.addItem(_loc3_[_loc1_],_loc1_);
            _loc1_++;
         }
         this.spinner_antialias.selectItem(this._settings.antiAlias);
         this.txt_shadows = new BodyTextField({
            "htmlText":this._lang.getString("options_vid_shadows").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_shadows);
         this.spinner_shadows = new UISpinner();
         this.spinner_shadows.width = this._valueColWidth;
         this.spinner_shadows.changed.add(this.onShadowsSettingChanged);
         addChild(this.spinner_shadows);
         var _loc4_:Array = this._lang.getEnum("options_vid_shadows_values");
         _loc1_ = 0;
         while(_loc1_ < _loc4_.length)
         {
            this.spinner_shadows.addItem(_loc4_[_loc1_],_loc1_);
            _loc1_++;
         }
         this.spinner_shadows.selectItem(this._settings.shadows);
         this.txt_dynamicLights = new BodyTextField({
            "htmlText":this._lang.getString("options_vid_dlights").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_dynamicLights);
         this.check_dynamicLights = new CheckBox({"htmlText":""},"right");
         this.check_dynamicLights.selected = this._settings.dynamicLights;
         this.check_dynamicLights.changed.add(this.onBooleanSettingChanged);
         addChild(this.check_dynamicLights);
         this.txt_staticLights = new BodyTextField({
            "htmlText":this._lang.getString("options_vid_slights").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_staticLights);
         this.check_staticLights = new CheckBox({"htmlText":""},"right");
         this.check_staticLights.selected = this._settings.staticLights;
         this.check_staticLights.changed.add(this.onBooleanSettingChanged);
         addChild(this.check_staticLights);
         this.txt_flash = new BodyTextField({
            "htmlText":this._lang.getString("options_vid_flash").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_flash);
         this.spinner_flash = new UISpinner();
         this.spinner_flash.width = this._valueColWidth;
         this.spinner_flash.changed.add(this.onFlashSettingChanged);
         addChild(this.spinner_flash);
         var _loc5_:Array = this._lang.getEnum("options_vid_flash_values");
         _loc1_ = 0;
         while(_loc1_ < _loc5_.length)
         {
            this.spinner_flash.addItem(_loc5_[_loc1_],_loc1_);
            _loc1_++;
         }
         this.spinner_flash.selectItem(this._settings.flashQuality);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._settings = null;
         this._lang = null;
      }
      
      override protected function draw() : void
      {
         this.txt_renderingLabel.x = 0;
         this.txt_renderingLabel.y = 0;
         this.txt_renderingValue.x = this._labelColWidth;
         this.txt_renderingValue.y = int(this.txt_renderingLabel.y);
         this.txt_preset.x = int(this.txt_renderingLabel.x);
         this.txt_preset.y = int(this.txt_renderingLabel.y + this.txt_renderingLabel.height + 14);
         this.spinner_preset.x = this._labelColWidth;
         this.spinner_preset.y = int(this.txt_preset.y + (this.txt_preset.height - this.spinner_preset.height) * 0.5);
         this.spinner_preset.redraw();
         if(this._advanced)
         {
            this.txt_antialias.visible = true;
            this.txt_shadows.visible = true;
            this.txt_dynamicLights.visible = true;
            this.txt_staticLights.visible = true;
            this.txt_flash.visible = true;
            this.spinner_antialias.visible = true;
            this.spinner_shadows.visible = true;
            this.spinner_flash.visible = true;
            this.check_dynamicLights.visible = true;
            this.check_staticLights.visible = true;
            this.txt_antialias.x = int(this.txt_preset.x);
            this.txt_antialias.y = int(this.txt_preset.y + this.txt_preset.height + 14);
            this.spinner_antialias.x = this._labelColWidth;
            this.spinner_antialias.y = int(this.txt_antialias.y + (this.txt_antialias.height - this.spinner_antialias.height) * 0.5);
            this.txt_shadows.x = int(this.txt_antialias.x);
            this.txt_shadows.y = int(this.txt_antialias.y + this.txt_antialias.height + 8);
            this.spinner_shadows.x = this._labelColWidth;
            this.spinner_shadows.y = int(this.txt_shadows.y + (this.txt_shadows.height - this.spinner_shadows.height) * 0.5);
            this.txt_dynamicLights.x = int(this.txt_shadows.x);
            this.txt_dynamicLights.y = int(this.txt_shadows.y + this.txt_shadows.height + 8);
            this.check_dynamicLights.x = this._labelColWidth;
            this.check_dynamicLights.y = int(this.txt_dynamicLights.y + (this.txt_dynamicLights.height - this.check_dynamicLights.height) * 0.5);
            this.txt_staticLights.x = int(this.txt_dynamicLights.x);
            this.txt_staticLights.y = int(this.txt_dynamicLights.y + this.txt_dynamicLights.height + 8);
            this.check_staticLights.x = this._labelColWidth;
            this.check_staticLights.y = int(this.txt_staticLights.y + (this.txt_staticLights.height - this.check_staticLights.height) * 0.5);
            this.txt_flash.x = int(this.txt_staticLights.x);
            this.txt_flash.y = int(this.txt_staticLights.y + this.txt_staticLights.height + 8);
            this.spinner_flash.x = this._labelColWidth;
            this.spinner_flash.y = int(this.txt_flash.y + (this.txt_flash.height - this.spinner_shadows.height) * 0.5);
            this.btn_advanced.x = int(this.txt_flash.x + 4);
            this.btn_advanced.y = int(this.txt_flash.y + this.txt_flash.height + 24);
         }
         else
         {
            this.txt_antialias.visible = false;
            this.txt_shadows.visible = false;
            this.txt_dynamicLights.visible = false;
            this.txt_staticLights.visible = false;
            this.txt_flash.visible = false;
            this.spinner_antialias.visible = false;
            this.spinner_shadows.visible = false;
            this.spinner_flash.visible = false;
            this.check_dynamicLights.visible = false;
            this.check_staticLights.visible = false;
            this.btn_advanced.x = int(this.txt_renderingLabel.x + 4);
            this.btn_advanced.y = int(this.txt_preset.y + this.txt_preset.height + 24);
         }
      }
      
      private function toggleAdvanedMode() : void
      {
         this._advanced = !this._advanced;
         this._settings.setData("vidAdvanced",this._advanced);
         this.btn_advanced.label = this._advanced ? this._lang.getString("options_vid_basic") : this._lang.getString("options_vid_advanced");
         invalidate();
      }
      
      private function gotoCustomPreset() : void
      {
         this._preset = 4;
         this._settings.setData("vidPreset",this._preset);
         this.spinner_preset.selectItem(this._preset);
      }
      
      private function onPresetSpinnerChanged() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         this._preset = int(this.spinner_preset.selectedData);
         this._settings.setData("vidPreset",this._preset);
         switch(this._preset)
         {
            case 0:
               _loc1_ = Settings.ANTIALIAS_OFF;
               _loc2_ = Settings.SHADOWS_OFF;
               _loc4_ = false;
               _loc5_ = false;
               _loc3_ = Settings.FLASH_QUALITY_MED;
               break;
            case 1:
               _loc1_ = Settings.ANTIALIAS_OFF;
               _loc2_ = Settings.SHADOWS_OFF;
               _loc4_ = false;
               _loc5_ = true;
               _loc3_ = Settings.FLASH_QUALITY_HIGH;
               break;
            case 2:
               _loc1_ = Settings.ANTIALIAS_X2;
               _loc2_ = Settings.SHADOWS_LOW;
               _loc4_ = true;
               _loc5_ = true;
               _loc3_ = Settings.FLASH_QUALITY_HIGH;
               break;
            case 3:
               _loc1_ = Settings.ANTIALIAS_X8;
               _loc2_ = Settings.SHADOWS_HIGH;
               _loc4_ = true;
               _loc5_ = true;
               _loc3_ = Settings.FLASH_QUALITY_BEST;
               break;
            case 4:
               return;
         }
         this.spinner_antialias.selectItem(_loc1_);
         this.spinner_shadows.selectItem(_loc2_);
         this.spinner_flash.selectItem(_loc3_);
         this.check_dynamicLights.selected = _loc4_;
         this.check_staticLights.selected = _loc5_;
         this._settings.antiAlias = int(this.spinner_antialias.selectedData);
         this._settings.shadows = int(this.spinner_shadows.selectedData);
         this._settings.flashQuality = int(this.spinner_flash.selectedData);
         this._settings.dynamicLights = this.check_dynamicLights.selected;
         this._settings.staticLights = this.check_staticLights.selected;
      }
      
      private function onAASettingChanged() : void
      {
         this.gotoCustomPreset();
         this._settings.antiAlias = int(this.spinner_antialias.selectedData);
      }
      
      private function onShadowsSettingChanged() : void
      {
         this.gotoCustomPreset();
         this._settings.shadows = int(this.spinner_shadows.selectedData);
      }
      
      private function onFlashSettingChanged() : void
      {
         this.gotoCustomPreset();
         this._settings.flashQuality = int(this.spinner_flash.selectedData);
      }
      
      private function onBooleanSettingChanged(param1:CheckBox) : void
      {
         this.gotoCustomPreset();
         switch(param1)
         {
            case this.check_dynamicLights:
               this._settings.dynamicLights = this.check_dynamicLights.selected;
               break;
            case this.check_staticLights:
               this._settings.staticLights = this.check_staticLights.selected;
         }
      }
      
      private function onClickedAdvance(param1:MouseEvent) : void
      {
         this.toggleAdvanedMode();
      }
   }
}

