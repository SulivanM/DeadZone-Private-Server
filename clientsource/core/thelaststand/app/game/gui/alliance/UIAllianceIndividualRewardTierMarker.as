package thelaststand.app.game.gui.alliance
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.text.TextFieldAutoSize;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   
   public class UIAllianceIndividualRewardTierMarker extends AllianceRewardMarker
   {
      
      public static const STATE_INACTIVE:int = 0;
      
      public static const STATE_ACTIVE_PASSED:int = 1;
      
      public static const STATE_ACTIVE_CURRENT:int = 2;
      
      private var _gem:Bitmap;
      
      private var txt_label:BodyTextField;
      
      private var _hitAreaShape:Shape;
      
      private var _state:int = 0;
      
      private var _items:Vector.<Item>;
      
      private var _value:int;
      
      private var _data:XML;
      
      public function UIAllianceIndividualRewardTierMarker(param1:XML)
      {
         var _loc2_:XML = null;
         var _loc3_:Item = null;
         this._items = new Vector.<Item>();
         super();
         this._data = param1;
         this._value = parseInt(param1.@score);
         mouseChildren = false;
         this._gem = new Bitmap();
         this._gem.bitmapData = new BmpAllianceRewardGem();
         this._gem.x = -10;
         this._gem.y = 26;
         addChild(this._gem);
         this.txt_label = new BodyTextField({
            "text":this._value.toString(),
            "color":16777215,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_label.x = -(this.txt_label.textWidth + 17);
         this.txt_label.y = 25;
         addChild(this.txt_label);
         this._hitAreaShape = new Shape();
         this._hitAreaShape.graphics.beginFill(16711680,0);
         this._hitAreaShape.graphics.drawRect(-15,0,30,MarkerHigh.height);
         addChild(this._hitAreaShape);
         for each(_loc2_ in this._data.itm)
         {
            _loc3_ = ItemFactory.createItemFromXML(_loc2_);
            if(_loc3_ == null)
            {
               throw new Error("Invalid item generated");
            }
            this._items.push(_loc3_);
         }
         this.state = STATE_INACTIVE;
      }
      
      public function get Items() : Vector.<Item>
      {
         return this._items;
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function get data() : XML
      {
         return this._data;
      }
      
      public function dispose() : void
      {
         this._gem.bitmapData.dispose();
         this.txt_label.dispose();
      }
      
      public function get state() : int
      {
         return this._state;
      }
      
      public function set state(param1:int) : void
      {
         this._state = param1;
         this._gem.visible = this._state == STATE_ACTIVE_CURRENT;
         MarkerHigh.visible = this._state > 0;
         MarkerLow.visible = this._state == STATE_INACTIVE;
         this.txt_label.textColor = this._state == STATE_INACTIVE ? 8684419 : 16777215;
      }
   }
}

