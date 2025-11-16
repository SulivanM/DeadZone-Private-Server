package thelaststand.app.game.gui.lists
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIInventoryCategoryListItem extends UIPagedListItem
   {
      
      private static const BG_COLOR_NORMAL:uint = 3486515;
      
      private static const BG_COLOR_ALT:uint = 2434341;
      
      private static const BG_COLOR_OVER:uint = 4670789;
      
      private static const BG_COLOR_SELECTED:uint = 8138780;
      
      private static const BMP_NEW:BitmapData = new BmpIconNewItem();
      
      private var _backgroundColor:uint = 3486515;
      
      private var _backgroundColorAlt:uint = 2434341;
      
      private var _backgroundColorOver:uint = 4670789;
      
      private var _alternating:Boolean = false;
      
      private var _category:String;
      
      private var _label:String;
      
      private var _showNew:Boolean = false;
      
      private var _quantity:int = 0;
      
      private var _bgColor:ColorTransform = new ColorTransform();
      
      private var mc_background:Sprite;
      
      private var mc_square:Shape;
      
      private var bmp_iconNew:Bitmap;
      
      private var txt_label:BodyTextField;
      
      private var txt_quantity:BodyTextField;
      
      public function UIInventoryCategoryListItem()
      {
         super();
         _height = 24;
         _width = 188;
         this.mc_background = new Sprite();
         addChild(this.mc_background);
         this.mc_square = new Shape();
         this.mc_square.graphics.beginFill(16777215,0.25);
         this.mc_square.graphics.drawRect(0,0,6,6);
         this.mc_square.graphics.endFill();
         this.mc_square.y = int((_height - this.mc_square.height) * 0.5);
         this.mc_square.x = int(this.mc_square.y);
         addChild(this.mc_square);
         this.bmp_iconNew = new Bitmap(BMP_NEW);
         this.bmp_iconNew.y = int((_height - this.bmp_iconNew.height) * 0.5);
         this.bmp_iconNew.x = int(this.bmp_iconNew.y);
         this.bmp_iconNew.visible = false;
         addChild(this.bmp_iconNew);
         this.txt_label = new BodyTextField({
            "text":" ",
            "color":11974326,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_label.x = int(this.mc_square.x * 2 + this.mc_square.width);
         this.txt_label.y = int((_height - this.txt_label.height) * 0.5);
         addChild(this.txt_label);
         this.txt_quantity = new BodyTextField({
            "text":"(0)",
            "color":6052185,
            "size":12
         });
         addChild(this.txt_quantity);
         this.draw();
         mouseChildren = false;
         hitArea = this.mc_background;
         mouseOver.add(this.onMouseOver);
         mouseOut.add(this.onMouseOut);
         mouseDown.add(this.onMouseDown);
      }
      
      public function get backgroundColor() : uint
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         this._backgroundColor = param1;
         this._backgroundColorOver = Color.scale(param1,1.25);
         this._backgroundColorAlt = Color.scale(param1,0.5);
         this.updateStateDisplay();
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         this._alternating = param1;
         this.updateStateDisplay();
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function set category(param1:String) : void
      {
         this._category = param1;
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         this.txt_label.text = this._label ? this._label.toUpperCase() : "";
      }
      
      public function get quantity() : int
      {
         return this._quantity;
      }
      
      public function set quantity(param1:int) : void
      {
         this._quantity = param1;
         this.txt_quantity.text = "(" + NumberFormatter.format(this._quantity,0) + ")";
         this.updateLabelPosition();
      }
      
      public function get showNew() : Boolean
      {
         return this._showNew;
      }
      
      public function set showNew(param1:Boolean) : void
      {
         this._showNew = param1;
         this.bmp_iconNew.visible = this._showNew;
         this.mc_square.visible = !this._showNew;
      }
      
      public function get showQuantity() : Boolean
      {
         return this.txt_quantity.visible;
      }
      
      public function set showQuantity(param1:Boolean) : void
      {
         this.txt_quantity.visible = param1;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         this.updateStateDisplay();
      }
      
      override public function set width(param1:Number) : void
      {
         _width = param1;
         this.draw();
      }
      
      private function draw() : void
      {
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(0);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         this.txt_quantity.x = int(_width - this.txt_quantity.width - 4);
         this.txt_quantity.y = int((_height - this.txt_quantity.height) * 0.5);
         this.updateLabelPosition();
         this.updateStateDisplay();
      }
      
      private function updateLabelPosition() : void
      {
         this.txt_quantity.x = int(_width - this.txt_quantity.width - 4);
         this.txt_label.maxWidth = int(this.txt_quantity.x - this.txt_label.x - 6);
         this.txt_label.y = int((_height - this.txt_label.height) * 0.5);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp_iconNew.bitmapData = null;
         this.txt_label.dispose();
         this.txt_quantity.dispose();
      }
      
      private function updateStateDisplay() : void
      {
         this._bgColor.color = this.getBackgroundColor();
         if(super.selected)
         {
            this.txt_label.textColor = 16767439;
            this.txt_quantity.textColor = 13793119;
         }
         else
         {
            this.txt_label.textColor = 11974326;
            this.txt_quantity.textColor = 6052185;
         }
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function getBackgroundColor() : uint
      {
         return selected ? BG_COLOR_SELECTED : (this._alternating ? this._backgroundColorAlt : this._backgroundColor);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         this._bgColor.color = this._backgroundColorOver;
         this._bgColor.alphaMultiplier = 1;
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         this._bgColor.color = this.getBackgroundColor();
         this._bgColor.alphaMultiplier = this._alternating ? 0 : 1;
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
   }
}

