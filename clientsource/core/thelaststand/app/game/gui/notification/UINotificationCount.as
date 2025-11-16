package thelaststand.app.game.gui.notification
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.BevelFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import thelaststand.app.display.BodyTextField;
   
   public class UINotificationCount extends Sprite
   {
      
      private var _label:String;
      
      private var _width:int = 0;
      
      private var _height:int = 18;
      
      private var _padding:int = 6;
      
      private var _color:uint;
      
      private var bmp_background:Bitmap;
      
      private var txt_label:BodyTextField;
      
      public function UINotificationCount(param1:uint = 10030858)
      {
         super();
         this._color = param1;
         this.bmp_background = new Bitmap();
         addChild(this.bmp_background);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "bold":true,
            "size":13,
            "filters":[new GlowFilter(3345419,1,2,2,10,1)]
         });
         addChild(this.txt_label);
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = param1;
         this.drawBackground();
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this.bmp_background.bitmapData != null)
         {
            this.bmp_background.bitmapData.dispose();
         }
         filters = [];
         this.txt_label.dispose();
      }
      
      private function drawBackground() : void
      {
         var _loc5_:Shape = null;
         if(this.bmp_background.bitmapData != null)
         {
            this.bmp_background.bitmapData.dispose();
         }
         var _loc1_:Matrix = new Matrix();
         _loc1_.createGradientBox(this._width,this._height,Math.PI * 0.48);
         var _loc2_:uint = new Color(this._color).tint(0,0.5).RGB;
         var _loc3_:uint = new Color(this._color).tint(16777215,0.5).RGB;
         var _loc4_:uint = new Color(_loc3_).tint(0,0.75).RGB;
         _loc5_ = new Shape();
         _loc5_.graphics.beginGradientFill("linear",[this._color,_loc2_],[1,1],[100,160],_loc1_);
         _loc5_.graphics.drawRoundRect(0,0,this._width,this._height,this._height,this._height);
         _loc5_.graphics.endFill();
         _loc5_.filters = [new BevelFilter(1,50,_loc3_,1,0,1,6,6,1,1,"inner"),new GlowFilter(_loc4_,1,3,3,5,1,true),new GlowFilter(16777215,0.5,4,4,1,1)];
         var _loc6_:int = 4;
         var _loc7_:BitmapData = new BitmapData(_loc5_.width + _loc6_ * 2,_loc5_.height + _loc6_ * 2,true,0);
         _loc7_.draw(_loc5_,new Matrix(1,0,0,1,_loc6_,_loc6_));
         this.bmp_background.bitmapData = _loc7_;
         this.bmp_background.smoothing = true;
         this.bmp_background.pixelSnapping = "never";
         this.bmp_background.x = -int(this.bmp_background.width * 0.5);
         this.bmp_background.y = -int(this.bmp_background.height * 0.5);
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         var _loc2_:int = this._width;
         this._label = param1;
         this.txt_label.text = this._label;
         this.txt_label.x = -Math.round(this.txt_label.width * 0.5);
         this.txt_label.y = -Math.round(this.txt_label.height * 0.5);
         this._width = int(this.txt_label.width) + this._padding * 2;
         if(this._width != _loc2_)
         {
            this.drawBackground();
         }
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

