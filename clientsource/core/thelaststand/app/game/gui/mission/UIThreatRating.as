package thelaststand.app.game.gui.mission
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import thelaststand.app.display.Effects;
   
   public class UIThreatRating extends Sprite
   {
      
      private const COLOR_NORMAL:uint = 8355711;
      
      private const COLOR_WARNING:uint = 16711680;
      
      private var _bmpThreat:BitmapData;
      
      private var _bmpThreatWarning:BitmapData;
      
      private var _value:Number;
      
      private var _maxValue:Number;
      
      private var _warningValue:Number;
      
      private var _warningState:Boolean;
      
      private var _width:int = 110;
      
      private var _height:int = 12;
      
      private var bmp_icon:Bitmap;
      
      private var mc_background:Shape;
      
      private var mc_border:Shape;
      
      private var mc_bar:Shape;
      
      public function UIThreatRating()
      {
         super();
         mouseEnabled = mouseChildren = false;
         this.mc_background = new Shape();
         addChild(this.mc_background);
         this.mc_border = new Shape();
         addChild(this.mc_border);
         this.mc_bar = new Shape();
         addChild(this.mc_bar);
         this._bmpThreatWarning = new BmpIconThreatRating();
         this._bmpThreat = new BmpIconThreatRatingGrey();
         this.bmp_icon = new Bitmap(this._bmpThreat);
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_icon);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._bmpThreat.dispose();
         this._bmpThreat = null;
         this._bmpThreatWarning.dispose();
         this._bmpThreatWarning = null;
         this.bmp_icon.filters = [];
         this.bmp_icon.bitmapData = null;
         this.bmp_icon = null;
      }
      
      private function draw() : void
      {
         if(!stage)
         {
            return;
         }
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(0);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_border.graphics.clear();
         this.mc_border.graphics.beginFill(this.COLOR_NORMAL);
         this.mc_border.graphics.drawRect(0,0,this._width,this._height);
         this.mc_border.graphics.drawRect(1,1,this._width - 2,this._height - 2);
         this.mc_border.graphics.endFill();
         this.mc_bar.graphics.clear();
         this.mc_bar.graphics.beginFill(this.COLOR_NORMAL);
         this.mc_bar.graphics.drawRect(0,0,this._width - 4,this._height - 4);
         this.mc_bar.x = 2;
         this.mc_bar.y = 2;
         this.mc_bar.width = this._value / this._maxValue * (this._width - this.mc_bar.x * 2);
         this.bmp_icon.x = Math.ceil(this._width - this.bmp_icon.width * 0.5);
         this.bmp_icon.y = int((this._height - this.bmp_icon.height) * 0.5);
      }
      
      private function setWarningState(param1:Boolean) : void
      {
         if(this._warningState == param1)
         {
            return;
         }
         this._warningState = param1;
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = this._warningState ? this.COLOR_WARNING : this.COLOR_NORMAL;
         this.mc_border.transform.colorTransform = _loc2_;
         this.mc_bar.transform.colorTransform = _loc2_;
         this.bmp_icon.bitmapData = this._warningState ? this._bmpThreatWarning : this._bmpThreat;
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.draw();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      public function get maxValue() : Number
      {
         return this._maxValue;
      }
      
      public function set maxValue(param1:Number) : void
      {
         this._maxValue = param1;
         this.mc_bar.width = this._value / this._maxValue * (this._width - this.mc_bar.x * 2);
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 == this._value)
         {
            return;
         }
         if(param1 > this._maxValue)
         {
            param1 = this._maxValue;
         }
         this._value = param1;
         this.mc_bar.width = this._value / this._maxValue * (this._width - this.mc_bar.x * 2);
         this.setWarningState(this._value > this._maxValue * 0.75);
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
   }
}

