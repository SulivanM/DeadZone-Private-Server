package thelaststand.app.gui
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.utils.GraphicUtils;
   
   public class UISpinner extends UIComponent
   {
      
      private var _backgroundColor:uint = 2434341;
      
      private var _labelColor:uint = 16777215;
      
      private var _width:int = 172;
      
      private var _height:int = 24;
      
      private var _index:int = 0;
      
      private var _items:Array = [];
      
      private var _showBorder:Boolean = true;
      
      private var btn_prev:UISpinButton;
      
      private var btn_next:UISpinButton;
      
      private var txt_value:BodyTextField;
      
      public var changed:Signal = new Signal();
      
      public function UISpinner()
      {
         super();
         this.btn_prev = new UISpinButton(-1);
         this.btn_prev.clicked.add(this.onClickNav);
         addChild(this.btn_prev);
         this.btn_next = new UISpinButton(1);
         this.btn_next.clicked.add(this.onClickNav);
         addChild(this.btn_next);
         this.txt_value = new BodyTextField({
            "color":this._labelColor,
            "size":13,
            "bold":true
         });
         addChild(this.txt_value);
      }
      
      public function get selectedData() : *
      {
         return this._items.length > 0 ? this._items[this._index].data : null;
      }
      
      public function get selectedLabel() : String
      {
         return this._items.length > 0 ? this._items[this._index].label : null;
      }
      
      public function get backgroundColor() : uint
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         this._backgroundColor = param1;
         invalidate();
      }
      
      public function get labelColor() : uint
      {
         return this._labelColor;
      }
      
      public function set labelColor(param1:uint) : void
      {
         this._labelColor = param1;
         this.txt_value.textColor = this._labelColor;
      }
      
      public function get showBorder() : Boolean
      {
         return this._showBorder;
      }
      
      public function set showBorder(param1:Boolean) : void
      {
         this._showBorder = param1;
         invalidate();
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
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      public function addItem(param1:String, param2:*) : void
      {
         this._items.push({
            "label":param1,
            "data":param2
         });
      }
      
      public function clear() : void
      {
         this._items.length = 0;
         this._index = 0;
         this.txt_value.htmlText = "";
      }
      
      public function selectItem(param1:int) : void
      {
         if(param1 < 0 || param1 >= this._items.length)
         {
            return;
         }
         this._index = param1;
         this.txt_value.htmlText = (this._items[this._index].label || "").toUpperCase();
         this.txt_value.x = int((this._width - this.txt_value.width) * 0.5);
      }
      
      public function selectItemByData(param1:*) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._items.length)
         {
            if(this._items[_loc2_].data == param1)
            {
               this.selectItem(_loc2_);
               return;
            }
            _loc2_++;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.changed.removeAll();
         this.btn_next.dispose();
         this.btn_prev.dispose();
         this.txt_value.dispose();
      }
      
      private function gotoIndex(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = int(this._items.length - 1);
         }
         else if(param1 >= this._items.length)
         {
            param1 = 0;
         }
         this.selectItem(param1);
         this.changed.dispatch();
      }
      
      override protected function draw() : void
      {
         GraphicUtils.drawUIBlock(this.graphics,this._width,this._height,0,0,this._backgroundColor,this._showBorder ? 7631988 : 2434341);
         this.btn_prev.y = int((this._height - this.btn_prev.height) * 0.5);
         this.btn_prev.x = this.btn_prev.y;
         this.btn_next.y = int(this.btn_prev.y);
         this.btn_next.x = int(this._width - this.btn_next.width - this.btn_prev.x);
         this.txt_value.x = int((this._width - this.txt_value.width) * 0.5);
         this.txt_value.y = int((this._height - this.txt_value.height) * 0.5);
      }
      
      private function onClickNav(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_prev:
               this.gotoIndex(this._index - 1);
               break;
            case this.btn_next:
               this.gotoIndex(this._index + 1);
         }
      }
   }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.MouseEvent;
import org.osflash.signals.natives.NativeSignal;
import thelaststand.app.audio.Audio;

class UISpinButton extends UIComponent
{
   
   private var _dir:int = 1;
   
   private var _width:int = 18;
   
   private var _height:int = 18;
   
   private var bmp_arrow:Bitmap;
   
   private var mc_background:Shape;
   
   public var clicked:NativeSignal;
   
   public var mouseOver:NativeSignal;
   
   public var mouseOut:NativeSignal;
   
   public var mouseDown:NativeSignal;
   
   public function UISpinButton(param1:int)
   {
      super();
      mouseChildren = false;
      this._dir = param1;
      this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
      this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
      this.mouseOut = new NativeSignal(this,MouseEvent.MOUSE_OUT,MouseEvent);
      this.mouseDown = new NativeSignal(this,MouseEvent.MOUSE_DOWN,MouseEvent);
      this.mc_background = new Shape();
      this.mc_background.graphics.beginFill(6710886);
      this.mc_background.graphics.drawRect(0,0,this._width,this._height);
      this.mc_background.graphics.endFill();
      this.mc_background.alpha = 0.5;
      addChild(this.mc_background);
      var _loc2_:BitmapData = this._dir == -1 ? new BmpIconButtonPrev() : new BmpIconButtonNext();
      this.bmp_arrow = new Bitmap(_loc2_);
      this.bmp_arrow.x = int((this._width - this.bmp_arrow.width) * 0.5);
      this.bmp_arrow.y = int((this._height - this.bmp_arrow.height) * 0.5);
      addChild(this.bmp_arrow);
      this.mouseOver.add(this.onMouseOver);
      this.mouseOut.add(this.onMouseOut);
      this.mouseDown.add(this.onMouseDown);
   }
   
   override public function dispose() : void
   {
      super.dispose();
      this.bmp_arrow.bitmapData.dispose();
      this.clicked.removeAll();
      this.mouseOver.removeAll();
      this.mouseOut.removeAll();
      this.mouseDown.removeAll();
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      this.mc_background.alpha = 1;
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      this.mc_background.alpha = 0.5;
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      Audio.sound.play("sound/interface/int-click.mp3");
   }
}
