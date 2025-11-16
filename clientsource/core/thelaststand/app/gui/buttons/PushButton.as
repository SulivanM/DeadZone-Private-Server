package thelaststand.app.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.BevelFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.gui.buttons.AbstractButton;
   
   public class PushButton extends AbstractButton
   {
      
      private static const BMP_PAINT:BitmapData = new BmpButtonPaint();
      
      private static const BMP_GRIME:BitmapData = new BmpButtonGrime();
      
      private const SELECTED_COLOR:uint = 7545099;
      
      private var _autoSize:Boolean;
      
      private var _iconBackgroundColor:int = 0;
      
      private var _color:uint = 2960942;
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean = false;
      
      private var _selectedColor:uint = 7545099;
      
      private var _labelOffset:int;
      
      private var _width:int;
      
      private var _height:int;
      
      protected var _label:String = "";
      
      protected var mc_background:PushButtonBackground;
      
      protected var txt_label:BodyTextField;
      
      private var mc_grime:Shape;
      
      private var mc_iconBackground:Sprite;
      
      private var mc_icon:DisplayObject;
      
      private var mc_paint:Shape;
      
      public var data:*;
      
      public function PushButton(param1:String = "", param2:* = null, param3:int = -1, param4:Object = null, param5:uint = 2960942)
      {
         super();
         this._color = param5;
         this._iconBackgroundColor = param3;
         mouseChildren = false;
         this.mc_background = new PushButtonBackground();
         this.mc_background.mc_rollover.alpha = 0;
         addChild(this.mc_background);
         this.mc_paint = new Shape();
         this.mc_paint.cacheAsBitmap = true;
         addChild(this.mc_paint);
         this.mc_grime = new Shape();
         this.mc_grime.blendMode = BlendMode.OVERLAY;
         this.mc_grime.alpha = 0.3;
         this.mc_grime.cacheAsBitmap = true;
         addChild(this.mc_grime);
         var _loc6_:Shape = new Shape();
         _loc6_.name = "mc_color";
         this.mc_iconBackground = new Sprite();
         this.mc_iconBackground.addChild(_loc6_);
         this.mc_iconBackground.filters = [new BevelFilter(1,45,16777215,0.25,0,0.15,1,1,10)];
         this.iconBackgroundColor = this._iconBackgroundColor;
         if(param4 == null)
         {
            param4 = {};
         }
         if(!param4.hasOwnProperty("color"))
         {
            param4.color = 14408667;
         }
         if(!param4.hasOwnProperty("size"))
         {
            param4.size = 13;
         }
         this.txt_label = new BodyTextField(param4);
         this.txt_label.text = this._label;
         this.txt_label.filters = [Effects.STROKE];
         this.label = this._label;
         this.setSize(this.mc_background.mc_color.width,this.mc_background.mc_color.height);
         if(param1 != null)
         {
            this.label = param1;
         }
         if(param2 != null)
         {
            if(param2 is BitmapData)
            {
               this.mc_icon = new Bitmap(param2,"auto",true);
               this.icon = this.mc_icon;
            }
            else
            {
               this.icon = param2 as DisplayObject;
            }
         }
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,int.MAX_VALUE,true);
      }
      
      override public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this);
         TweenMax.killChildTweensOf(this);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.CLICK,this.onClick);
         this.txt_label.dispose();
         var _loc1_:Bitmap = this.mc_icon as Bitmap;
         if(_loc1_ != null)
         {
            if(_loc1_.bitmapData != null)
            {
               _loc1_.bitmapData.dispose();
               _loc1_.bitmapData = null;
            }
            _loc1_ = null;
         }
         if(this.mc_icon != null)
         {
            this.mc_icon.filters = [];
            this.mc_icon = null;
         }
         this.mc_iconBackground.filters = [];
         this.mc_background = null;
         this.mc_grime = null;
         this.mc_paint = null;
         super.dispose();
      }
      
      public function highlight(param1:Boolean) : void
      {
         if(!this._enabled)
         {
            return;
         }
         if(param1)
         {
            TweenMax.to(this.mc_background.mc_rollover,0,{
               "alpha":0.5,
               "overwrite":true
            });
            if(this.mc_icon != null)
            {
               TweenMax.to(this.mc_icon,0.15,{"glowFilter":{
                  "color":16777215,
                  "alpha":0.75,
                  "blurX":10,
                  "blurY":10,
                  "strength":1,
                  "quality":2
               }});
            }
         }
         else
         {
            TweenMax.to(this.mc_background.mc_rollover,0.25,{
               "alpha":0,
               "overwrite":true
            });
            if(this.mc_icon != null)
            {
               TweenMax.to(this.mc_icon,0.25,{"glowFilter":{
                  "alpha":0,
                  "remove":true,
                  "overwrite":true
               }});
            }
         }
      }
      
      protected function setSize(param1:int, param2:int) : void
      {
         if(this._autoSize)
         {
            param1 = this.txt_label.width + (this.mc_icon != null ? Math.round(this._height * 1.16) : 0) + 26;
         }
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
         var _loc3_:ColorTransform = this.mc_background.mc_color.transform.colorTransform;
         _loc3_.color = this._color;
         this.mc_background.mc_color.transform.colorTransform = _loc3_;
         this.mc_background.mc_color.width = this.mc_background.mc_innerGlow.width = this.mc_background.mc_rollover.width = this.mc_background.mc_stroke.width = this._width;
         this.mc_background.mc_outline.width = this._width + 8;
         this.mc_background.mc_color.height = this.mc_background.mc_innerGlow.height = this.mc_background.mc_rollover.height = this.mc_background.mc_stroke.height = this._height;
         this.mc_background.mc_outline.height = this._height + 8;
         var _loc4_:Matrix = new Matrix();
         _loc4_.createBox(this._width / BMP_PAINT.width,this._height / BMP_PAINT.height);
         this.mc_paint.graphics.clear();
         this.mc_paint.graphics.beginBitmapFill(BMP_PAINT,_loc4_,false);
         this.mc_paint.graphics.drawRect(0,0,this._width,this._height);
         this.mc_paint.graphics.endFill();
         _loc4_.createBox(1,this._height / BMP_GRIME.height);
         this.mc_grime.graphics.clear();
         this.mc_grime.graphics.beginBitmapFill(BMP_GRIME,_loc4_);
         this.mc_grime.graphics.drawRect(0,0,this._width,this._height);
         this.mc_grime.graphics.endFill();
         var _loc5_:Shape = this.mc_iconBackground.getChildByName("mc_color") as Shape;
         _loc5_.graphics.clear();
         _loc5_.graphics.beginFill(0);
         _loc5_.graphics.drawRect(0,0,Math.round(this._height * 1.16),this._height);
         _loc5_.graphics.endFill();
         _loc5_.alpha = 0.6;
         _loc5_.blendMode = BlendMode.OVERLAY;
         this.positionElements();
      }
      
      protected function positionElements() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         if(this.mc_iconBackground.parent != null && this.mc_iconBackground.visible)
         {
            _loc1_ = this.mc_iconBackground.x + this.mc_iconBackground.width;
         }
         if(this.mc_icon != null)
         {
            this.mc_icon.scaleX = this.mc_icon.scaleY = 1;
            _loc2_ = this._height / (this.mc_icon.height * 0.95);
            if(_loc2_ > 1)
            {
               _loc2_ = 1;
            }
            this.mc_icon.scaleX = this.mc_icon.scaleY = _loc2_;
            this.mc_icon.x = Math.round(((this._label.length > 0 ? this.mc_iconBackground.width : this._width) - this.mc_icon.width) * 0.5);
            this.mc_icon.y = Math.round((this.mc_iconBackground.height - this.mc_icon.height) * 0.5);
            if(!this.mc_iconBackground.visible)
            {
               _loc1_ = this.mc_icon.x + this.mc_icon.width;
            }
         }
         if(this.txt_label.parent != null)
         {
            this.txt_label.x = _loc1_ + int((this._width - _loc1_ - this.txt_label.width) * 0.5) + this._labelOffset;
            this.txt_label.y = int((this._height - this.txt_label.height) * 0.5);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.highlight(true);
         if(this._enabled)
         {
            Audio.sound.play("sound/interface/int-over.mp3");
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.highlight(false);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
         TweenMax.to(this.mc_background.mc_rollover,0,{"alpha":1});
         TweenMax.to(this.mc_background.mc_rollover,0.25,{
            "delay":0.05,
            "alpha":0
         });
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
      }
      
      override public function get autoSize() : Boolean
      {
         return this._autoSize;
      }
      
      override public function set autoSize(param1:Boolean) : void
      {
         this._autoSize = param1;
         this.setSize(this._width,this._height);
      }
      
      public function get backgroundColor() : uint
      {
         return this._color;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         this._color = param1;
         var _loc2_:ColorTransform = this.mc_background.mc_color.transform.colorTransform;
         _loc2_.color = this._color;
         this.mc_background.mc_color.transform.colorTransform = _loc2_;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         if(this.mc_icon != null)
         {
            this.mc_icon.alpha = this._enabled ? 1 : 0.1;
         }
         if(this.txt_label != null)
         {
            this.txt_label.alpha = this._enabled ? 1 : 0.25;
         }
         if(this.mc_iconBackground != null)
         {
            this.mc_iconBackground.alpha = this._enabled ? 1 : 0.3;
         }
         if(this.mc_background != null && this.mc_background.mc_color != null)
         {
            this.mc_background.mc_color.alpha = this._enabled ? 1 : 0.5;
         }
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         if(this._label.length > 0)
         {
            addChild(this.txt_label);
            this.txt_label.text = this._label.toUpperCase();
         }
         else if(this.txt_label.parent != null)
         {
            this.txt_label.parent.removeChild(this.txt_label);
         }
         if(this._autoSize)
         {
            this.setSize(this._width,this._height);
         }
         else
         {
            this.positionElements();
         }
      }
      
      public function get labelOffset() : int
      {
         return this._labelOffset;
      }
      
      public function set labelOffset(param1:int) : void
      {
         this._labelOffset = param1;
         this.positionElements();
      }
      
      public function get icon() : DisplayObject
      {
         return this.mc_icon;
      }
      
      public function set icon(param1:DisplayObject) : void
      {
         if(this.mc_icon != null)
         {
            if(this.mc_icon.parent != null)
            {
               this.mc_icon.parent.removeChild(this.mc_icon);
            }
            if(this.mc_iconBackground.parent != null)
            {
               this.mc_iconBackground.parent.removeChild(this.mc_iconBackground);
            }
            this.mc_icon = null;
         }
         this.mc_icon = param1;
         if(this.mc_icon != null)
         {
            addChild(this.mc_iconBackground);
            addChild(this.mc_icon);
         }
         if(this._autoSize)
         {
            this.setSize(this._width,this._height);
         }
         else
         {
            this.positionElements();
         }
      }
      
      public function get iconBackgroundColor() : uint
      {
         return this._iconBackgroundColor;
      }
      
      public function set iconBackgroundColor(param1:uint) : void
      {
         var _loc2_:Shape = null;
         var _loc3_:ColorTransform = null;
         this._iconBackgroundColor = param1;
         if(this._iconBackgroundColor >= 0)
         {
            _loc2_ = this.mc_iconBackground.getChildByName("mc_color") as Shape;
            _loc3_ = _loc2_.transform.colorTransform;
            _loc3_.color = this._iconBackgroundColor;
            _loc2_.transform.colorTransform = _loc3_;
            this.mc_iconBackground.visible = true;
         }
         else
         {
            this.mc_iconBackground.visible = false;
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         TweenMax.to(this.mc_background.mc_color,0,{"tint":(this._selected ? this._selectedColor : this._color)});
      }
      
      public function get showBorder() : Boolean
      {
         return this.mc_background.mc_outline.visible;
      }
      
      public function set showBorder(param1:Boolean) : void
      {
         this.mc_background.mc_outline.visible = param1;
      }
      
      public function get selectedColor() : uint
      {
         return this._selectedColor;
      }
      
      public function set selectedColor(param1:uint) : void
      {
         this._selectedColor = param1;
      }
      
      public function get strokeColor() : int
      {
         if(this.mc_background.mc_stroke.transform.colorTransform)
         {
            return this.mc_background.mc_stroke.transform.colorTransform.color;
         }
         return -1;
      }
      
      public function set strokeColor(param1:int) : void
      {
         var _loc2_:ColorTransform = null;
         if(param1 < 0)
         {
            this.mc_background.mc_stroke.transform.colorTransform = null;
         }
         else
         {
            _loc2_ = new ColorTransform();
            _loc2_.color = param1;
            this.mc_background.mc_stroke.transform.colorTransform = _loc2_;
         }
      }
      
      public function get outlineColor() : int
      {
         if(this.mc_background.mc_outline.transform.colorTransform)
         {
            return this.mc_background.mc_outline.transform.colorTransform.color;
         }
         return -1;
      }
      
      public function set outlineColor(param1:int) : void
      {
         var _loc2_:ColorTransform = null;
         if(param1 < 0)
         {
            this.mc_background.mc_outline.transform.colorTransform = null;
         }
         else
         {
            _loc2_ = new ColorTransform();
            _loc2_.color = param1;
            this.mc_background.mc_outline.transform.colorTransform = _loc2_;
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1,this._height);
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this.setSize(this._width,param1);
      }
   }
}

