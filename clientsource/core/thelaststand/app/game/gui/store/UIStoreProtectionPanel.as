package thelaststand.app.game.gui.store
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UIStoreProtectionPanel extends UIComponent
   {
      
      private const PADDING:int = 6;
      
      private var _backgroundColor:uint = 1118481;
      
      private var _storeItem:Object;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _imageURI:String;
      
      private var btn_buy:PurchasePushButton;
      
      private var mc_titleBG:Sprite;
      
      private var txt_title:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_cooldown:BodyTextField;
      
      private var ui_image:UIImage;
      
      public var purchasedClicked:Signal = new Signal(Object);
      
      public function UIStoreProtectionPanel()
      {
         super();
         this.ui_image = new UIImage(120,134);
         addChild(this.ui_image);
         this.btn_buy = new PurchasePushButton();
         this.btn_buy.clicked.add(this.onClickPurchase);
         this.btn_buy.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         addChild(this.btn_buy);
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":13,
            "multiline":true
         });
         addChild(this.txt_desc);
         this.txt_cooldown = new BodyTextField({
            "color":9292762,
            "size":13,
            "bold":true
         });
         addChild(this.txt_cooldown);
         this.mc_titleBG = new Sprite();
         addChild(this.mc_titleBG);
         this.txt_title = new BodyTextField({
            "color":16777215,
            "size":12,
            "antiAliasType":"advanced",
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_title);
      }
      
      public function get backgroundColor() : uint
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         this._backgroundColor = param1;
         invalidate();
      }
      
      public function get storeItem() : Object
      {
         return this._storeItem;
      }
      
      public function set storeItem(param1:Object) : void
      {
         this._storeItem = param1;
         invalidate();
      }
      
      public function get imageURI() : String
      {
         return this._imageURI;
      }
      
      public function set imageURI(param1:String) : void
      {
         this._imageURI = param1;
         this.ui_image.uri = this._imageURI;
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
         this._height = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.btn_buy.dispose();
         this.txt_cooldown.dispose();
         this.txt_desc.dispose();
         this.txt_title.dispose();
         this.ui_image.dispose();
         this.purchasedClicked.removeAll();
      }
      
      override protected function draw() : void
      {
         var _loc6_:int = 0;
         graphics.clear();
         graphics.beginFill(this._backgroundColor);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         this.ui_image.width = int(this._width - 4 - this.PADDING * 2);
         this.ui_image.height = this.ui_image.width;
         this.ui_image.x = int((this._width - this.ui_image.width) * 0.5);
         this.ui_image.y = this.ui_image.x;
         this.ui_image.uri = this._imageURI;
         var _loc1_:int = 2;
         var _loc2_:int = this.ui_image.height + 18;
         graphics.beginFill(4671303);
         graphics.drawRect(this.ui_image.x - _loc1_,this.ui_image.y - _loc1_,this.ui_image.width + _loc1_ * 2,_loc2_ + _loc1_ * 2);
         graphics.endFill();
         graphics.beginFill(0);
         graphics.drawRect(this.ui_image.x,this.ui_image.y,this.ui_image.width,_loc2_);
         graphics.endFill();
         var _loc3_:int = int(this._storeItem.PriceCoins);
         this.btn_buy.x = this.PADDING + 4;
         this.btn_buy.y = int(this._height - this.btn_buy.height - this.PADDING - 4);
         this.btn_buy.width = int(this._width - this.btn_buy.x * 2);
         this.btn_buy.cost = _loc3_;
         this.btn_buy.enabled = _loc3_ > 0;
         var _loc4_:int = int(this._storeItem.length);
         var _loc5_:String = this._storeItem.length <= 24 * 60 * 60 ? int(_loc4_ / 60 / 60).toString() + " hrs" : DateTimeUtils.secondsToString(_loc4_);
         this.txt_title.text = Language.getInstance().getString("store_protection_item_label",_loc5_.toUpperCase());
         this.mc_titleBG.graphics.clear();
         this.mc_titleBG.graphics.beginFill(8355711,0.35);
         this.mc_titleBG.graphics.drawRect(0,0,this.ui_image.width - 8,18);
         this.mc_titleBG.graphics.endFill();
         this.mc_titleBG.x = int(this.ui_image.x + 4);
         this.mc_titleBG.y = int(this.ui_image.y + _loc2_ - this.mc_titleBG.height - 4);
         this.txt_title.x = int(this.mc_titleBG.x + (this.mc_titleBG.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.mc_titleBG.y + (this.mc_titleBG.height - this.txt_title.height) * 0.5);
         this.txt_desc.htmlText = Language.getInstance().getString("store_protection_item_desc");
         this.txt_cooldown.htmlText = Language.getInstance().getString("store_protection_item_cooldown",DateTimeUtils.secondsToString(int(this._storeItem.cooldown)));
         _loc6_ = 4;
         var _loc7_:int = this.txt_cooldown.height + this.txt_desc.height + _loc6_;
         var _loc8_:int = this.ui_image.y + this.ui_image.height;
         this.txt_desc.x = this.PADDING + 6;
         this.txt_desc.width = int(this._width - this.txt_desc.x * 2);
         this.txt_desc.y = int(_loc8_ + (this.btn_buy.y - _loc8_ - _loc7_) * 0.5);
         this.txt_cooldown.x = int(this.txt_desc.x);
         this.txt_cooldown.y = int(this.txt_desc.y + this.txt_desc.height + _loc6_);
      }
      
      private function onClickPurchase(param1:MouseEvent) : void
      {
         this.purchasedClicked.dispatch(this._storeItem);
      }
   }
}

