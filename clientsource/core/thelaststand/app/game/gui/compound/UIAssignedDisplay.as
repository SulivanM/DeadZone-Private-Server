package thelaststand.app.game.gui.compound
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIAssignedDisplay extends Sprite
   {
      
      private var _value:int = 0;
      
      private var _maxValue:int = 0;
      
      private var mc_hitArea:Sprite;
      
      private var bmp_icon:Bitmap;
      
      private var txt_value:BodyTextField;
      
      public function UIAssignedDisplay()
      {
         super();
         mouseChildren = false;
         this.bmp_icon = new Bitmap(new BmpIconAssignedHUD());
         this.bmp_icon.y = -int(this.bmp_icon.height * 0.5) - 1;
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_icon);
         this.txt_value = new BodyTextField({
            "text":" ",
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_value.x = int(this.bmp_icon.x + this.bmp_icon.width + 4);
         this.txt_value.y = -int(this.txt_value.height * 0.5);
         this.txt_value.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_value);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,10);
         this.mc_hitArea.graphics.endFill();
         this.mc_hitArea.y = this.bmp_icon.y;
         addChildAt(this.mc_hitArea,0);
         hitArea = this.mc_hitArea;
         this.updateDisplay();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon.filters = [];
         this.bmp_icon = null;
         this.txt_value.dispose();
         this.txt_value = null;
      }
      
      private function updateDisplay() : void
      {
         this.txt_value.text = this._value + " / " + this._maxValue;
         this.mc_hitArea.width = this.txt_value.x + this.txt_value.width;
         this.mc_hitArea.height = this.bmp_icon.height;
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function set value(param1:int) : void
      {
         if(param1 == this._value)
         {
            return;
         }
         this._value = param1;
         this.updateDisplay();
      }
      
      public function get maxValue() : int
      {
         return this._maxValue;
      }
      
      public function set maxValue(param1:int) : void
      {
         if(param1 == this._maxValue)
         {
            return;
         }
         this._maxValue = param1;
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

