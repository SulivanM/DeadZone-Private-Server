package thelaststand.app.game.gui.compound
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIResourceDisplay extends Sprite
   {
      
      private static const BMP_BAR:BitmapData = new BmpBarResource();
      
      private static const BMP_ADD_BUTTON:BitmapData = new BmpResourceAddButton();
      
      private static const BMP_ADD_ICON:BitmapData = new BmpIconAddResource();
      
      private var _barWidth:int;
      
      private var _barHeight:int;
      
      private var _displayAsPercentage:Boolean;
      
      private var _warningLevel:Number = 0;
      
      private var _maxValue:Number;
      
      private var _value:Number;
      
      private var _color:uint;
      
      private var _labelColor:int = -1;
      
      private var _label:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _tweenDummy:Object = {
         "barValue":0,
         "labelValue":0
      };
      
      private var _tweenAnimation:TweenMax;
      
      private var bmp_add:Bitmap;
      
      private var bmp_addButton:Bitmap;
      
      private var bmp_bar:Bitmap;
      
      private var bmp_icon:Bitmap;
      
      private var mc_bar:Shape;
      
      private var txt_amount:BodyTextField;
      
      public var clicked:NativeSignal;
      
      public function UIResourceDisplay(param1:BitmapData, param2:uint, param3:Boolean = false, param4:Point = null)
      {
         super();
         this._color = param2;
         this._displayAsPercentage = param3;
         this.bmp_bar = new Bitmap(BMP_BAR);
         this.bmp_bar.cacheAsBitmap = true;
         addChildAt(this.bmp_bar,0);
         this.bmp_addButton = new Bitmap(BMP_ADD_BUTTON);
         this.bmp_addButton.x = int(this.bmp_bar.x + this.bmp_bar.width - 2);
         this.bmp_addButton.y = int(this.bmp_bar.y);
         addChildAt(this.bmp_addButton,0);
         this.bmp_add = new Bitmap(BMP_ADD_ICON);
         this.bmp_add.x = int(this.bmp_addButton.x + this.bmp_addButton.width - this.bmp_add.width - 4);
         this.bmp_add.y = int(this.bmp_addButton.y + (this.bmp_addButton.height - this.bmp_add.height) * 0.5);
         addChild(this.bmp_add);
         this.bmp_icon = new Bitmap(param1);
         this.bmp_icon.x = int(this.bmp_bar.x - this.bmp_icon.width * 0.5) + (param4 != null ? param4.x : 0);
         this.bmp_icon.y = int(this.bmp_bar.y + (this.bmp_bar.height - this.bmp_icon.height) * 0.5) + (param4 != null ? param4.y : 0);
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_icon);
         this._width = this.bmp_addButton.x + this.bmp_addButton.width;
         this._height = this.bmp_bar.height;
         this._barWidth = this.bmp_bar.width - 4;
         this._barHeight = this.bmp_bar.height - 4;
         this.mc_bar = new Shape();
         this.mc_bar.x = int(this.bmp_bar.x + 2);
         this.mc_bar.y = int(this.bmp_bar.y + 2);
         this.mc_bar.graphics.beginFill(this._color);
         this.mc_bar.graphics.drawRect(0,0,this._barWidth,this._barHeight);
         this.mc_bar.graphics.endFill();
         this.mc_bar.blendMode = BlendMode.OVERLAY;
         addChildAt(this.mc_bar,getChildIndex(this.bmp_bar) + 1);
         this.txt_amount = new BodyTextField({
            "color":16777215,
            "autoSize":"left",
            "size":14,
            "bold":true,
            "align":"left"
         });
         this.txt_amount.text = "0";
         this.txt_amount.x = int(this.bmp_addButton.x - this.txt_amount.width - 2);
         this.txt_amount.y = int(this.bmp_bar.y + (this.bmp_bar.height - this.txt_amount.height) * 0.5 - 1);
         this.txt_amount.maxWidth = int(this.bmp_addButton.x - (this.bmp_icon.x + this.bmp_icon.width * 0.5 + 12));
         this.txt_amount.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_amount);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killTweensOf(this._tweenDummy);
         TweenMax.killChildTweensOf(this);
         this.bmp_bar.bitmapData = null;
         this.bmp_bar = null;
         this.bmp_addButton.bitmapData = null;
         this.bmp_addButton = null;
         this.bmp_add.bitmapData = null;
         this.bmp_add = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon.filters = [];
         this.bmp_icon = null;
         this.txt_amount.dispose();
         this.txt_amount = null;
         this.clicked.removeAll();
         this.clicked = null;
         this._tweenAnimation = null;
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      private function animate() : void
      {
         var updateDisplay:Function = function():void
         {
            var _loc1_:Number = _tweenDummy.barValue / _maxValue;
            var _loc2_:Boolean = _warningLevel > 0 && _loc1_ < _warningLevel;
            if(_label != null)
            {
               txt_amount.text = _label;
            }
            else
            {
               txt_amount.text = _displayAsPercentage ? Math.round(_loc1_ * 100) + "%" : NumberFormatter.format(_tweenDummy.labelValue,0);
            }
            if(_labelColor < 0)
            {
               txt_amount.textColor = _loc2_ ? Effects.COLOR_WARNING : 16777215;
            }
            txt_amount.x = int(bmp_addButton.x - txt_amount.width - 2);
            txt_amount.y = int(bmp_bar.y + (bmp_bar.height - txt_amount.height) * 0.5 - 1);
            txt_amount.maxWidth = int(bmp_addButton.x - (bmp_icon.x + bmp_icon.width * 0.5 + 12));
            if(_loc1_ > 1)
            {
               _loc1_ = 1;
            }
            else if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
            mc_bar.width = int(_barWidth * _loc1_);
            mc_bar.transform.colorTransform = _loc2_ ? Effects.CT_WARNING : Effects.CT_DEFAULT;
         };
         var barValue:Number = Math.min(this._value,this._maxValue);
         if(stage == null)
         {
            this._tweenDummy.barValue = barValue;
            this._tweenDummy.labelValue = this._value;
            updateDisplay();
         }
         if(this._tweenAnimation != null && this._tweenAnimation.totalProgress < 1)
         {
            this._tweenAnimation.updateTo({
               "barValue":barValue,
               "labelValue":this._value
            });
            return;
         }
         this._tweenAnimation = TweenMax.to(this._tweenDummy,0.25,{
            "barValue":barValue,
            "labelValue":this._value,
            "onUpdate":updateDisplay,
            "onComplete":function():void
            {
               _tweenAnimation = null;
            }
         });
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         TweenMax.to(this.bmp_add,0,{
            "colorTransform":{"exposure":1.1},
            "glowFilter":{
               "color":7065090,
               "alpha":1,
               "blurX":8,
               "blurY":8,
               "strength":2,
               "quality":1
            },
            "overwrite":true
         });
         TweenMax.to(this.bmp_bar,0,{
            "colorTransform":{"exposure":1.08},
            "overwrite":true
         });
         TweenMax.to(this.bmp_addButton,0,{
            "colorTransform":{"exposure":1.08},
            "overwrite":true
         });
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_add,0.25,{
            "colorTransform":{"exposure":1},
            "glowFilter":{
               "alpha":0,
               "remove":true
            }
         });
         TweenMax.to(this.bmp_bar,0.25,{"colorTransform":{"exposure":1}});
         TweenMax.to(this.bmp_addButton,0.25,{"colorTransform":{"exposure":1}});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_addButton,0,{
            "colorTransform":{"exposure":1.25},
            "overwrite":true
         });
         TweenMax.to(this.bmp_addButton,0.5,{
            "delay":0.05,
            "colorTransform":{"exposure":1}
         });
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         this.animate();
      }
      
      public function get labelColor() : int
      {
         return this._labelColor;
      }
      
      public function set labelColor(param1:int) : void
      {
         this._labelColor = param1;
         this.txt_amount.textColor = this._labelColor;
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._value = param1;
         this.animate();
      }
      
      public function get maxValue() : Number
      {
         return this._maxValue;
      }
      
      public function set maxValue(param1:Number) : void
      {
         this._maxValue = param1;
         this.animate();
      }
      
      public function get warningLevel() : Number
      {
         return this._warningLevel;
      }
      
      public function set warningLevel(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._warningLevel = param1;
         this.animate();
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

