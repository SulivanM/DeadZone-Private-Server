package thelaststand.app.game.gui
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   
   public class UIMessageArrow extends Sprite
   {
      
      private var _label:String;
      
      private var bmp_background:Bitmap;
      
      private var txt_label:TitleTextField;
      
      public function UIMessageArrow(param1:String = null)
      {
         super();
         this.bmp_background = new Bitmap(new BmpMessageArrow());
         addChild(this.bmp_background);
         this.txt_label = new TitleTextField({
            "color":16777215,
            "size":14,
            "multiline":true,
            "leading":-2,
            "align":"center"
         });
         this.txt_label.width = int(this.bmp_background.width - 10);
         this.txt_label.htmlText = " ";
         this.txt_label.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.txt_label);
         this.label = param1;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_background.bitmapData.dispose();
         this.bmp_background.bitmapData = null;
         this.bmp_background = null;
         this.txt_label.dispose();
         this.txt_label = null;
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         this.txt_label.htmlText = this._label != null ? this._label.toUpperCase() : " ";
         this.txt_label.y = int(this.bmp_background.y + (this.bmp_background.height - this.txt_label.height) * 0.5);
      }
   }
}

