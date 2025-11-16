package thelaststand.app.game.gui.iteminfo
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.ItemCounterType;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIItemInfoCounterPanel extends UIComponent
   {
      
      private var _width:int = 100;
      
      private var _height:int = 22;
      
      private var bmp_icon:Bitmap;
      
      private var txt_type:BodyTextField;
      
      private var txt_count:BodyTextField;
      
      public function UIItemInfoCounterPanel()
      {
         super();
         this.bmp_icon = new Bitmap();
         addChild(this.bmp_icon);
         this.txt_type = new BodyTextField({
            "color":8487297,
            "size":13,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_type);
         this.txt_count = new BodyTextField({
            "color":8487297,
            "size":13,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_count);
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
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
         }
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         graphics.beginFill(0,1);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         this.bmp_icon.x = 4;
         this.bmp_icon.y = int((this._height - this.bmp_icon.height) * 0.5);
         this.txt_type.x = int(this.bmp_icon.x + this.bmp_icon.width + 4);
         this.txt_type.y = int((this._height - this.txt_type.height) * 0.5);
         this.txt_count.x = int(this._width - this.txt_count.width - 4);
         this.txt_count.y = int((this._height - this.txt_count.height) * 0.5);
      }
      
      public function setContent(param1:uint, param2:int) : void
      {
         var _loc3_:Class = null;
         switch(param1)
         {
            case ItemCounterType.ZombieKills:
            case ItemCounterType.HumanKills:
            case ItemCounterType.SurvivorKills:
               _loc3_ = BmpIconSkull;
         }
         if(!(this.bmp_icon.bitmapData is _loc3_))
         {
            if(this.bmp_icon.bitmapData != null)
            {
               this.bmp_icon.bitmapData.dispose();
            }
            if(_loc3_ != null)
            {
               this.bmp_icon.bitmapData = BitmapData(new _loc3_());
            }
         }
         this.txt_type.text = Language.getInstance().getString("counters." + ItemCounterType.getName(param1)).toUpperCase();
         this.txt_count.text = NumberFormatter.format(param2,0);
         invalidate();
      }
   }
}

