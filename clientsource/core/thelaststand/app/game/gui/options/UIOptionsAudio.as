package thelaststand.app.game.gui.options
{
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Settings;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.UISlider;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIOptionsAudio extends UIComponent
   {
      
      private var _labelColWidth:int = 140;
      
      private var _valueColWidth:int = 140;
      
      private var _lang:Language;
      
      private var _settings:Settings;
      
      private var _width:int;
      
      private var txt_music:BodyTextField;
      
      private var txt_sfx:BodyTextField;
      
      private var txt_voices:BodyTextField;
      
      private var txt_3d:BodyTextField;
      
      private var check_voices:CheckBox;
      
      private var check_3d:CheckBox;
      
      private var slider_music:UISlider;
      
      private var slider_sfx:UISlider;
      
      public function UIOptionsAudio()
      {
         super();
         this._lang = Language.getInstance();
         this._settings = Settings.getInstance();
         this.txt_music = new BodyTextField({
            "text":this._lang.getString("options_aud_music").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_music);
         this.slider_music = new UISlider();
         this.slider_music.value = Audio.music.volume;
         this.slider_music.valueChanged.add(this.onMusicVolumeChanged);
         addChild(this.slider_music);
         this.txt_sfx = new BodyTextField({
            "text":this._lang.getString("options_aud_sfx").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_sfx);
         this.slider_sfx = new UISlider();
         this.slider_sfx.value = Audio.sound.volume;
         this.slider_sfx.valueChanged.add(this.onSFXVolumeChanged);
         addChild(this.slider_sfx);
         this.txt_voices = new BodyTextField({
            "text":this._lang.getString("options_aud_voices").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_voices);
         this.check_voices = new CheckBox({"htmlText":""},"right");
         this.check_voices.selected = this._settings.voices;
         this.check_voices.changed.add(this.onBooleanSettingChanged);
         addChild(this.check_voices);
         this.txt_3d = new BodyTextField({
            "text":this._lang.getString("options_aud_3d").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_3d);
         this.check_3d = new CheckBox({"htmlText":""},"right");
         this.check_3d.selected = this._settings.sound3D;
         this.check_3d.changed.add(this.onBooleanSettingChanged);
         addChild(this.check_3d);
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
         this.txt_music.x = 0;
         this.txt_music.y = 0;
         this.slider_music.x = this._labelColWidth;
         this.slider_music.y = int(this.txt_music.y + (this.txt_music.height - this.slider_music.height) * 0.5);
         this.txt_sfx.x = int(this.txt_music.x);
         this.txt_sfx.y = int(this.txt_music.y + this.txt_music.height + 8);
         this.slider_sfx.x = this._labelColWidth;
         this.slider_sfx.y = int(this.txt_sfx.y + (this.txt_sfx.height - this.slider_sfx.height) * 0.5);
         this.txt_voices.x = int(this.txt_sfx.x);
         this.txt_voices.y = int(this.txt_sfx.y + this.txt_sfx.height + 8);
         this.check_voices.x = this._labelColWidth;
         this.check_voices.y = int(this.txt_voices.y + (this.txt_voices.height - this.check_voices.height) * 0.5);
         this.txt_3d.x = int(this.txt_voices.x);
         this.txt_3d.y = int(this.txt_voices.y + this.txt_voices.height + 8);
         this.check_3d.x = this._labelColWidth;
         this.check_3d.y = int(this.txt_3d.y + (this.txt_3d.height - this.check_3d.height) * 0.5);
      }
      
      private function onBooleanSettingChanged(param1:CheckBox) : void
      {
         switch(param1)
         {
            case this.check_voices:
               this._settings.voices = this.check_voices.selected;
               break;
            case this.check_3d:
               this._settings.sound3D = this.check_3d.selected;
         }
      }
      
      private function onMusicVolumeChanged() : void
      {
         Audio.setMusicVolume(this.slider_music.value);
      }
      
      private function onSFXVolumeChanged() : void
      {
         Audio.setSoundVolume(this.slider_sfx.value);
      }
   }
}

