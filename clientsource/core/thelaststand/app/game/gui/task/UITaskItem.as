package thelaststand.app.game.gui.task
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UITaskItem extends Sprite
   {
      
      private static const ICON_BG_BEVEL:GlowFilter = new GlowFilter(0,0.25,2.5,2.5,10,1,true);
      
      protected var _target:*;
      
      protected var _priority:int = 0;
      
      protected var _showSpeedUp:Boolean = true;
      
      private var _color:uint = 9972236;
      
      private var _enabled:Boolean = true;
      
      private var _icon:BitmapData;
      
      private var _width:int = 394;
      
      private var _height:int = 32;
      
      private var _secondsRemaining:int = 0;
      
      private var _disposed:Boolean = false;
      
      protected var btn_speedUp:PurchasePushButton;
      
      private var bmp_icon:Bitmap;
      
      private var mc_background:Sprite;
      
      private var mc_progress:Shape;
      
      protected var mc_iconBackground:Shape;
      
      private var txt_label:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      public function UITaskItem()
      {
         super();
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(7236973);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginFill(2434341);
         this.mc_background.graphics.drawRect(1,1,this._width - 2,this._height - 2);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.mc_progress = new Shape();
         addChild(this.mc_progress);
         this.mc_iconBackground = new Shape();
         this.mc_iconBackground.filters = [ICON_BG_BEVEL];
         addChild(this.mc_iconBackground);
         this.bmp_icon = new Bitmap();
         addChild(this.bmp_icon);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "size":13,
            "bold":true
         });
         this.txt_label.text = " ";
         this.txt_label.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_label);
         this.txt_time = new BodyTextField({
            "color":12566463,
            "size":13,
            "bold":true,
            "align":"right"
         });
         this.txt_time.text = " ";
         this.txt_time.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_time);
         this.btn_speedUp = new PurchasePushButton(Language.getInstance().getString("speed_up"));
         this.btn_speedUp.name = "btn_speedUp";
         this.btn_speedUp.clicked.add(this.onClickSpeedUp);
         this.btn_speedUp.showIcon = false;
         this.btn_speedUp.showBorder = false;
         this.btn_speedUp.width = 78;
         this.btn_speedUp.height = 24;
         addChild(this.btn_speedUp);
         this.setIcon(this._color);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      }
      
      public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         this._target = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.btn_speedUp.dispose();
         this.txt_time.dispose();
         this.txt_label.dispose();
         this.mc_iconBackground.filters = [];
      }
      
      public function update() : void
      {
      }
      
      protected function positionElements() : void
      {
         this.mc_iconBackground.x = 4;
         this.mc_iconBackground.y = Math.round((this._height - this.mc_iconBackground.height) * 0.5);
         this.btn_speedUp.x = this._width - this.btn_speedUp.width - 6;
         this.btn_speedUp.y = Math.round((this._height - this.btn_speedUp.height) * 0.5);
         if(this._showSpeedUp)
         {
            this.txt_time.x = int(this.btn_speedUp.x - this.txt_time.width - 2);
         }
         else
         {
            this.txt_time.x = int(this._width - this.txt_time.width - 2);
         }
         this.txt_time.y = Math.round((this._height - this.txt_label.height) * 0.5);
         this.txt_label.x = int(this.mc_iconBackground.x + this.mc_iconBackground.width + 4);
         this.txt_label.y = Math.round((this._height - this.txt_label.height) * 0.5);
         this.txt_label.maxWidth = int(this.txt_time.x - this.txt_label.x - 10);
         this.bmp_icon.x = int(this.mc_iconBackground.x + (this.mc_iconBackground.width - this.bmp_icon.width) * 0.5);
         this.bmp_icon.y = int(this.mc_iconBackground.y + (this.mc_iconBackground.height - this.bmp_icon.height) * 0.5);
         this.mc_progress.x = int(this.mc_iconBackground.x + this.mc_iconBackground.width + 2);
         this.mc_progress.y = this.mc_iconBackground.y;
         this.mc_progress.graphics.endFill();
         this.mc_progress.graphics.beginFill(4342338);
         this.mc_progress.graphics.drawRect(0,0,int(this.btn_speedUp.x - this.mc_progress.x - 2),24);
         this.mc_progress.graphics.endFill();
      }
      
      protected function setIcon(param1:uint, param2:BitmapData = null) : void
      {
         this._color = param1;
         this.mc_iconBackground.graphics.clear();
         this.mc_iconBackground.graphics.beginFill(this._color);
         this.mc_iconBackground.graphics.drawRect(0,0,28,24);
         this.mc_iconBackground.graphics.endFill();
         this.bmp_icon.bitmapData = param2;
      }
      
      protected function setTime(param1:int) : void
      {
         var _loc2_:String = null;
         this._secondsRemaining = param1;
         if(this._secondsRemaining < 0)
         {
            this.txt_time.visible = false;
            this.btn_speedUp.visible = false;
         }
         else
         {
            this.txt_time.visible = true;
            this.btn_speedUp.enabled = this._showSpeedUp && this._enabled && this._secondsRemaining > 5;
            this.btn_speedUp.visible = this._showSpeedUp;
            _loc2_ = DateTimeUtils.secondsToString(param1,true,true);
            this.txt_time.text = _loc2_;
            this.txt_time.x = this.btn_speedUp.visible ? int(this.btn_speedUp.x - this.txt_time.width - 2) : int(this._width - this.txt_time.width - 2);
         }
      }
      
      protected function setProgress(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this.mc_progress.scaleX = param1;
      }
      
      protected function setLabel(param1:String) : void
      {
         this.txt_label.text = param1.toUpperCase();
      }
      
      protected function handleClick() : void
      {
      }
      
      private function onClickSpeedUp(param1:MouseEvent) : void
      {
         var _loc2_:SpeedUpDialogue = new SpeedUpDialogue(this._target);
         _loc2_.open();
         param1.stopPropagation();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_background,0,{
            "colorTransform":{"exposure":1.05},
            "overwrite":true
         });
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_background,0.1,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.handleClick();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.positionElements();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled;
         this.btn_speedUp.enabled = this._enabled && this._secondsRemaining > 5;
      }
      
      public function get target() : *
      {
         return this._target;
      }
      
      public function get label() : String
      {
         return this.txt_label.text;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get priority() : int
      {
         return this._priority;
      }
   }
}

