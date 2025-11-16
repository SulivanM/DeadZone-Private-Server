package thelaststand.app.game.gui.tooltip
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.text.TextFieldAutoSize;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.common.lang.Language;
   
   public class UIRewardTierTooltip extends Sprite
   {
      
      public static const STATE_PAST:uint = 0;
      
      public static const STATE_ACTIVE:uint = 1;
      
      public static const STATE_FUTURE:uint = 2;
      
      protected var _width:int = 270;
      
      protected var _height:int = 170;
      
      private var _state:uint = 2;
      
      private var _tierXML:XML;
      
      private var ui_titleBar:UITitleBar;
      
      private var ui_itemImage:UIImage;
      
      private var mc_itemBorder:Shape;
      
      private var bmp_gem:Bitmap;
      
      private var txt_title:BodyTextField;
      
      private var txt_rewardInstruction:BodyTextField;
      
      private var txt_contains:BodyTextField;
      
      private var txt_items:BodyTextField;
      
      private var txt_disclaimer:BodyTextField;
      
      public function UIRewardTierTooltip()
      {
         super();
         this.ui_titleBar = new UITitleBar();
         addChild(this.ui_titleBar);
         this.mc_itemBorder = new Shape();
         addChild(this.mc_itemBorder);
         this.ui_itemImage = new UIImage(64,64,0,1,false);
         addChild(this.ui_itemImage);
         this.txt_title = new BodyTextField({
            "text":" ",
            "color":15188587,
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         addChild(this.txt_title);
         this.bmp_gem = new Bitmap(new BmpAllianceRewardGem());
         addChild(this.bmp_gem);
         this.txt_rewardInstruction = new BodyTextField({
            "text":"title",
            "color":16777215,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":165
         });
         addChild(this.txt_rewardInstruction);
         this.txt_contains = new BodyTextField({
            "text":"contains",
            "color":16777215,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":180
         });
         addChild(this.txt_contains);
         this.txt_items = new BodyTextField({
            "text":"+50 item",
            "color":8048236,
            "size":14,
            "bold":false,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":180
         });
         addChild(this.txt_items);
         this.txt_disclaimer = new BodyTextField({
            "text":"disclaimer",
            "color":6250077,
            "size":14,
            "bold":false,
            "multiline":true,
            "autoSize":TextFieldAutoSize.LEFT,
            "multiline":true,
            "width":this.ui_titleBar.width - 5
         });
         addChild(this.txt_disclaimer);
      }
      
      protected function get tierXML() : XML
      {
         return this._tierXML;
      }
      
      protected function get state() : uint
      {
         return this._state;
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
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_gem.bitmapData.dispose();
         this.ui_titleBar.dispose();
         this.ui_itemImage.dispose();
         this.txt_contains.dispose();
         this.txt_items.dispose();
         this.txt_rewardInstruction.dispose();
         this._tierXML = null;
      }
      
      public function populate(param1:XML, param2:uint) : void
      {
         var _loc5_:uint = 0;
         this._tierXML = param1;
         this._state = param2;
         var _loc3_:int = 10;
         var _loc4_:int = 2;
         this.ui_titleBar.width = this._width;
         this.ui_titleBar.height = 26;
         this.txt_title.text = this.getTitle();
         this.txt_title.x = int(this.ui_titleBar.x + (this.ui_titleBar.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         this.ui_itemImage.x = 4;
         this.ui_itemImage.y = int(this.ui_titleBar.y + this.ui_titleBar.height + _loc3_ + _loc4_);
         this.ui_itemImage.uri = this._tierXML.@img.toString();
         this.bmp_gem.x = int(this.ui_itemImage.x + this.ui_itemImage.width + _loc3_);
         this.bmp_gem.y = int(this.ui_itemImage.y);
         this.txt_rewardInstruction.y = int(this.bmp_gem.y);
         switch(this._state)
         {
            case STATE_ACTIVE:
               this.bmp_gem.visible = true;
               this.txt_rewardInstruction.textColor = 16102685;
               this.txt_rewardInstruction.x = int(this.bmp_gem.x + this.bmp_gem.width);
               _loc5_ = 12358190;
               this.txt_title.textColor = 15188587;
               this.ui_titleBar.color = 12358190;
               this.ui_itemImage.filters = [];
               break;
            default:
               this.bmp_gem.visible = false;
               this.txt_rewardInstruction.textColor = 13421772;
               this.txt_rewardInstruction.x = int(this.bmp_gem.x);
               _loc5_ = 6710886;
               this.txt_title.textColor = 6710886;
               this.ui_titleBar.color = 6710886;
               this.ui_itemImage.filters = [Effects.GREYSCALE.filter];
         }
         this.txt_rewardInstruction.text = this.getRewardInstruction();
         this.txt_rewardInstruction.width = int(this._width - this.txt_rewardInstruction.x);
         this.mc_itemBorder.graphics.clear();
         this.mc_itemBorder.graphics.beginFill(_loc5_);
         this.mc_itemBorder.graphics.drawRect(0,0,this.ui_itemImage.width + _loc4_ * 2,this.ui_itemImage.height + _loc4_ * 2);
         this.mc_itemBorder.graphics.endFill();
         this.mc_itemBorder.x = int(this.ui_itemImage.x - _loc4_);
         this.mc_itemBorder.y = int(this.ui_itemImage.y - _loc4_);
         this.txt_contains.x = int(this.bmp_gem.x);
         this.txt_contains.y = int(this.txt_rewardInstruction.y + this.txt_rewardInstruction.height);
         this.txt_contains.width = int(this._width - this.txt_contains.x);
         this.txt_contains.text = Language.getInstance().getString("alliance.indiReward_tooltip_contains");
         this.txt_items.x = int(this.txt_contains.x);
         this.txt_items.y = int(this.txt_contains.y + this.txt_contains.height);
         this.txt_items.width = int(this._width - this.txt_items.x);
         this.txt_items.htmlText = this.getItemNameList();
         this.txt_disclaimer.width = this._width;
         this.txt_disclaimer.htmlText = this.getDisclaimer();
         this.txt_disclaimer.x = 0;
         this.txt_disclaimer.y = Math.max(int(this.txt_items.y + this.txt_items.height + _loc3_),int(this.ui_itemImage.y + this.ui_itemImage.height + _loc4_ + _loc3_));
         this._height = int(this.txt_disclaimer.y + this.txt_disclaimer.height);
      }
      
      protected function getTitle() : String
      {
         return "";
      }
      
      protected function getRewardInstruction() : String
      {
         return "";
      }
      
      protected function getItemNameList() : String
      {
         var _loc2_:XML = null;
         var _loc3_:Item = null;
         var _loc4_:String = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this._tierXML.itm)
         {
            _loc3_ = ItemFactory.createItemFromXML(_loc2_);
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.getName();
               if(_loc3_.quantifiable && _loc3_.quantity > 1)
               {
                  _loc4_ += " x " + NumberFormatter.format(_loc3_.quantity,0);
               }
               _loc1_.push(_loc4_);
               _loc3_.dispose();
            }
         }
         return _loc1_.join("<br/>");
      }
      
      protected function getDisclaimer() : String
      {
         return "";
      }
   }
}

