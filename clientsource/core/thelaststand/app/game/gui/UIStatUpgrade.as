package thelaststand.app.game.gui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.gui.TooltipManager;
   
   public class UIStatUpgrade extends Sprite
   {
      
      private var _currentValue:Number = 0;
      
      private var _nextValue:Number = 0;
      
      private var bmp_icon:Bitmap;
      
      private var bmp_arrow:Bitmap;
      
      private var mc_hitArea:Sprite;
      
      private var txt_currValue:BodyTextField;
      
      private var txt_nextValue:BodyTextField;
      
      public function UIStatUpgrade(param1:BitmapData)
      {
         super();
         mouseChildren = false;
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,10);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         this.bmp_icon = new Bitmap(param1);
         addChild(this.bmp_icon);
         this.txt_currValue = new BodyTextField({
            "text":"0",
            "color":16777215,
            "size":14,
            "bold":true
         });
         this.txt_currValue.x = int(this.bmp_icon.x + this.bmp_icon.width + 3);
         addChild(this.txt_currValue);
         this.txt_nextValue = new BodyTextField({
            "text":"0",
            "color":16777215,
            "size":14,
            "bold":true
         });
         this.bmp_arrow = new Bitmap(new BmpIconStatUpgrade());
         this.bmp_arrow.y = int(this.txt_nextValue.y + (this.txt_nextValue.height - this.bmp_arrow.height) * 0.5);
         this.bmp_icon.y = int(this.txt_currValue.y + (this.txt_currValue.height - this.bmp_icon.height) * 0.5);
         hitArea = this.mc_hitArea;
         this.currentValue = 0;
      }
      
      public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.bmp_arrow.bitmapData.dispose();
         this.bmp_arrow.bitmapData = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.txt_currValue.dispose();
         this.txt_nextValue.dispose();
      }
      
      private function updateDisplay() : void
      {
         if(this._currentValue == 0 && this._nextValue == 0)
         {
            if(this.txt_currValue.parent != null)
            {
               this.txt_currValue.parent.removeChild(this.txt_currValue);
            }
         }
         else
         {
            this.txt_currValue.text = this._currentValue.toString();
            addChild(this.txt_currValue);
         }
         if(this._nextValue == 0)
         {
            if(this.txt_nextValue.parent != null)
            {
               this.txt_nextValue.parent.removeChild(this.txt_nextValue);
            }
            if(this.bmp_arrow.parent != null)
            {
               this.bmp_arrow.parent.removeChild(this.bmp_arrow);
            }
            this.mc_hitArea.width = this.txt_nextValue.parent != null ? int(this.txt_currValue.x + this.txt_currValue.width) : int(this.bmp_icon.x + this.bmp_icon.width);
         }
         else
         {
            this.txt_nextValue.text = this._nextValue.toString();
            this.bmp_arrow.x = int(this.txt_currValue.x + this.txt_currValue.width + 4);
            this.txt_nextValue.x = int(this.bmp_arrow.x + this.bmp_arrow.width + 4);
            this.mc_hitArea.width = int(this.txt_nextValue.x + this.txt_nextValue.width);
            addChild(this.txt_nextValue);
            addChild(this.bmp_arrow);
         }
         this.mc_hitArea.height = int(this.txt_currValue.y + this.txt_currValue.height);
         this.mc_hitArea.y = int(this.txt_currValue.y);
      }
      
      public function get currentValue() : Number
      {
         return this._currentValue;
      }
      
      public function set currentValue(param1:Number) : void
      {
         this._currentValue = param1;
         this.updateDisplay();
      }
      
      public function get nextValue() : Number
      {
         return this._nextValue;
      }
      
      public function set nextValue(param1:Number) : void
      {
         this._nextValue = param1;
         this.updateDisplay();
      }
      
      override public function get height() : Number
      {
         return this.txt_currValue.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

