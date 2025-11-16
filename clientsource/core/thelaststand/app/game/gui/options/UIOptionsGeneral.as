package thelaststand.app.game.gui.options
{
   import flash.events.MouseEvent;
   import thelaststand.app.core.Settings;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.common.lang.Language;
   
   public class UIOptionsGeneral extends UIComponent
   {
      
      private var _labelColWidth:int = 240;
      
      private var _valueColWidth:int = 140;
      
      private var _lang:Language;
      
      private var _settings:Settings;
      
      private var _width:int;
      
      private var txt_gore:BodyTextField;
      
      private var txt_tracers:BodyTextField;
      
      private var txt_clothingPreview:BodyTextField;
      
      private var check_gore:CheckBox;
      
      private var check_tracers:CheckBox;
      
      private var check_clothingPreview:CheckBox;
      
      private var btn_resetWarnings:PushButton;
      
      public function UIOptionsGeneral()
      {
         super();
         this._lang = Language.getInstance();
         this._settings = Settings.getInstance();
         this.txt_gore = new BodyTextField({
            "text":this._lang.getString("options_gen_gore").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_gore);
         this.check_gore = new CheckBox({"htmlText":""},"right");
         this.check_gore.selected = this._settings.gore;
         this.check_gore.changed.add(this.onBooleanSettingChanged);
         addChild(this.check_gore);
         this.txt_tracers = new BodyTextField({
            "text":this._lang.getString("options_gen_tracers").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_tracers);
         this.check_tracers = new CheckBox({"htmlText":""},"right");
         this.check_tracers.selected = this._settings.bulletTracers;
         this.check_tracers.changed.add(this.onBooleanSettingChanged);
         addChild(this.check_tracers);
         this.txt_clothingPreview = new BodyTextField({
            "text":this._lang.getString("options_gen_clothingPreview").toUpperCase(),
            "size":15,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_clothingPreview);
         this.check_clothingPreview = new CheckBox({"htmlText":""},"right");
         this.check_clothingPreview.selected = this._settings.clothingPreview;
         this.check_clothingPreview.changed.add(this.onBooleanSettingChanged);
         addChild(this.check_clothingPreview);
         this.btn_resetWarnings = new PushButton(this._lang.getString("options_gen_resetwarn"));
         this.btn_resetWarnings.clicked.add(this.onClickResetWarnings);
         addChild(this.btn_resetWarnings);
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
         this.txt_gore.x = 0;
         this.txt_gore.y = 0;
         this.check_gore.x = this._labelColWidth;
         this.check_gore.y = int(this.txt_gore.y + (this.txt_gore.height - this.check_gore.height) * 0.5);
         this.txt_tracers.x = this.txt_gore.x;
         this.txt_tracers.y = int(this.txt_gore.y + this.txt_gore.height + 8);
         this.check_tracers.x = this._labelColWidth;
         this.check_tracers.y = int(this.txt_tracers.y + (this.txt_tracers.height - this.check_tracers.height) * 0.5);
         this.txt_clothingPreview.x = this.txt_tracers.x;
         this.txt_clothingPreview.y = int(this.txt_tracers.y + this.txt_tracers.height + 8);
         this.check_clothingPreview.x = this._labelColWidth;
         this.check_clothingPreview.y = int(this.txt_clothingPreview.y + (this.txt_clothingPreview.height - this.check_clothingPreview.height) * 0.5);
         this.btn_resetWarnings.x = int(this.txt_gore.x + 4);
         this.btn_resetWarnings.y = 230;
      }
      
      private function onBooleanSettingChanged(param1:CheckBox) : void
      {
         switch(param1)
         {
            case this.check_gore:
               this._settings.gore = this.check_gore.selected;
               break;
            case this.check_tracers:
               this._settings.bulletTracers = this.check_tracers.selected;
               break;
            case this.check_clothingPreview:
               this._settings.clothingPreview = this.check_clothingPreview.selected;
         }
      }
      
      private function onClickResetWarnings(param1:MouseEvent) : void
      {
         this._settings.resetWarnings();
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("options_resetwarnings_msg"));
         _loc2_.addTitle(this._lang.getString("options_resetwarnings_title"),BaseDialogue.TITLE_COLOR_GREY);
         _loc2_.addButton(this._lang.getString("options_resetwarnings_ok"));
         _loc2_.open();
      }
   }
}

