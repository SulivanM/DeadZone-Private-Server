package thelaststand.app.gui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   
   public class UITitleBar extends Sprite
   {
      
      private static const BMP_BACKGROUND:BitmapData = new BmpTopBarBackground();
      
      private var _color:uint = 9582109;
      
      private var _title:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _titlePadding:int;
      
      private var bmp_bg:Bitmap;
      
      private var mc_color:Shape;
      
      private var txt_title:TitleTextField;
      
      public function UITitleBar(param1:Object = null, param2:uint = 9582109)
      {
         super();
         this.bmp_bg = new Bitmap(BMP_BACKGROUND);
         this._width = this.bmp_bg.width;
         this._height = this.bmp_bg.height;
         this._color = param2;
         this._titlePadding = param1 == null ? 8 : (param1.hasOwnProperty("padding") ? int(param1.padding) : 8);
         this.mc_color = new Shape();
         this.mc_color.graphics.beginFill(this._color,1);
         this.mc_color.graphics.drawRect(0,0,this.bmp_bg.width,this.bmp_bg.height);
         this.mc_color.graphics.endFill();
         this.mc_color.blendMode = BlendMode.OVERLAY;
         addChild(this.bmp_bg);
         addChild(this.mc_color);
         if(param1 != null)
         {
            this.txt_title = new TitleTextField(param1);
            this.txt_title.text = " ";
            this.txt_title.filters = [Effects.TEXT_SHADOW_DARK];
            addChild(this.txt_title);
         }
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         filters = [];
         this.bmp_bg.bitmapData = null;
         if(this.txt_title != null)
         {
            this.txt_title.dispose();
            this.txt_title = null;
         }
      }
      
      public function setTitleProperties(param1:Object) : void
      {
         this.txt_title.setProperties(param1);
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
         this.bmp_bg.width = this.mc_color.width = this._width;
         this.bmp_bg.height = this.mc_color.height = this._height;
         if(this.txt_title != null)
         {
            this.txt_title.maxWidth = this._width - this._titlePadding - 4;
            this.txt_title.x = this._titlePadding;
            this.txt_title.y = Math.round((this._height - this.txt_title.height) * 0.5);
         }
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = param1;
         var _loc2_:ColorTransform = this.mc_color.transform.colorTransform;
         _loc2_.color = this._color;
         this.mc_color.transform.colorTransform = _loc2_;
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set title(param1:String) : void
      {
         this._title = param1;
         if(this.txt_title != null)
         {
            this.txt_title.text = this._title.toUpperCase();
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

