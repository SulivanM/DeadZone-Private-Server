package thelaststand.app.game.gui.compound
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIMoraleDisplay extends Sprite
   {
      
      private static const BITMAPS:Array = [new BmpIconMorale1(),new BmpIconMorale2(),new BmpIconMorale3(),new BmpIconMorale4(),new BmpIconMorale5()];
      
      public static const COLORS:Array = [Effects.COLOR_WARNING,14844195,13224393,7316944,Effects.COLOR_GOOD];
      
      private var _index:int = 2;
      
      private var _value:Number = 0;
      
      private var mc_hitArea:Sprite;
      
      private var bmp_icon:Bitmap;
      
      private var txt_value:BodyTextField;
      
      public function UIMoraleDisplay()
      {
         super();
         mouseChildren = false;
         this.bmp_icon = new Bitmap(BITMAPS[this._index]);
         this.bmp_icon.y = -int(this.bmp_icon.height * 0.5);
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_icon);
         this.txt_value = new BodyTextField({
            "color":COLORS[this._index],
            "size":13,
            "bold":true
         });
         this.txt_value.text = "0000";
         this.txt_value.x = int(this.bmp_icon.x + this.bmp_icon.width + 2);
         this.txt_value.y = -int(this.txt_value.height * 0.5);
         this.txt_value.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_value);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,this.txt_value.x + this.txt_value.width,this.bmp_icon.height);
         this.mc_hitArea.graphics.endFill();
         this.mc_hitArea.y = this.bmp_icon.y;
         addChildAt(this.mc_hitArea,0);
         hitArea = this.mc_hitArea;
         this.txt_value.text = "0";
      }
      
      public static function getMoraleDisplayIndex(param1:int) : int
      {
         var _loc2_:Number = Math.round(param1);
         if(_loc2_ <= -20)
         {
            return 0;
         }
         if(_loc2_ <= -10)
         {
            return 1;
         }
         if(_loc2_ < 10)
         {
            return 2;
         }
         if(_loc2_ < 20)
         {
            return 3;
         }
         return 4;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_icon.bitmapData = null;
         this.bmp_icon.filters = [];
         this.bmp_icon = null;
         this.txt_value.dispose();
         this.txt_value = null;
      }
      
      private function updateDisplay() : void
      {
         this._index = getMoraleDisplayIndex(this._value);
         this.txt_value.textColor = COLORS[this._index];
         var _loc1_:BitmapData = BITMAPS[this._index];
         if(this.bmp_icon.bitmapData != _loc1_)
         {
            this.bmp_icon.bitmapData = _loc1_;
            this.bmp_icon.y = -int(this.bmp_icon.height * 0.5);
         }
      }
      
      public function get showValue() : Boolean
      {
         return this.txt_value.visible;
      }
      
      public function set showValue(param1:Boolean) : void
      {
         this.txt_value.visible = param1;
         this.mc_hitArea.width = int(this.txt_value.visible ? this.txt_value.x + this.txt_value.width : this.bmp_icon.x + this.bmp_icon.width);
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 < -1)
         {
            this.value = -1;
         }
         else if(param1 > 1)
         {
            this.value = 1;
         }
         if(param1 == this._value)
         {
            return;
         }
         this._value = param1;
         this.txt_value.text = (this._value > 0 ? "+" : "") + this._value.toString();
         this.showValue = this.txt_value.visible;
         this.updateDisplay();
      }
      
      override public function get width() : Number
      {
         return this.mc_hitArea.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.mc_hitArea.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

