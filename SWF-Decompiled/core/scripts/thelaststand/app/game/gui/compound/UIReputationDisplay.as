package thelaststand.app.game.gui.compound
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIReputationDisplay extends Sprite
   {
      private static const BMP_ICON_BAD:BitmapData = new BmpIconReputationBad();
      
      private static const BMP_ICON_GOOD:BitmapData = new BmpIconReputationGood();
      
      private var _value:Number = 0;
      
      private var bmp_icon:Bitmap;
      
      private var mc_hitArea:Sprite;
      
      private var txt_value:BodyTextField;
      
      public function UIReputationDisplay()
      {
         super();
         mouseChildren = false;
         this.bmp_icon = new Bitmap(BMP_ICON_GOOD);
         this.bmp_icon.y = -int(this.bmp_icon.height * 0.5);
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_icon);
         this.txt_value = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_value.text = "0000";
         this.txt_value.x = int(this.bmp_icon.x + this.bmp_icon.width + 4);
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
         this.txt_value.text = int(this._value * 100).toString();
         var _loc2_:BitmapData = this.value >= 0 ? BMP_ICON_GOOD : BMP_ICON_BAD;
         if(this.bmp_icon.bitmapData != _loc2_)
         {
            this.bmp_icon.bitmapData = _loc2_;
            this.bmp_icon.y = -int(this.bmp_icon.height * 0.5);
            this.txt_value.textColor = this.value >= 0 ? Effects.COLOR_NEUTRAL : Effects.COLOR_WARNING;
         }
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
