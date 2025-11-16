package thelaststand.app.game.gui.lists
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.utils.Timer;
   import playerio.PlayerIOError;
   import thelaststand.app.data.Currency;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.effects.CooldownType;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.OfferSystem;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UIOffersListItem extends UIPagedListItem
   {
      
      private var _offer:Object;
      
      private var _itemImages:Vector.<UIItemImage>;
      
      private var _expired:Boolean = false;
      
      private var _expiresTimer:Timer;
      
      private var btn_buy:PurchasePushButton;
      
      private var bmp_timer:Bitmap;
      
      private var bmp_header:Bitmap;
      
      private var bmp_footer:Bitmap;
      
      private var bmp_fuel:Bitmap;
      
      private var txt_title:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var txt_fuel:BodyTextField;
      
      private var txt_items:BodyTextField;
      
      private var mc_graphics:Shape;
      
      private var mc_items:Sprite;
      
      private var ui_image:UIImage;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var _itemOptions:Object;
      
      public function UIOffersListItem()
      {
         super();
         _width = 326;
         _height = 355;
         this._itemImages = new Vector.<UIItemImage>();
         this.mc_items = new Sprite();
         this.ui_itemInfo = new UIItemInfo();
         this.ui_image = new UIImage(_width,220,2434341);
         addChild(this.ui_image);
         this.mc_graphics = new Shape();
         addChild(this.mc_graphics);
         this.bmp_header = new Bitmap(new BmpOffersHeader());
         addChild(this.bmp_header);
         this.txt_title = new BodyTextField({
            "size":26,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.maxWidth = this.bmp_header.width - 10;
         addChild(this.txt_title);
         this.bmp_footer = new Bitmap(new BmpOffersFooter());
         this.bmp_footer.y = int(_height - this.bmp_footer.height);
         addChild(this.bmp_footer);
         this.btn_buy = new PurchasePushButton();
         this.btn_buy.y = int(this.bmp_footer.y + (this.bmp_footer.height - this.btn_buy.height) * 0.5);
         this.btn_buy.visible = false;
         this.btn_buy.clicked.add(this.onPurchaseClicked);
         addChild(this.btn_buy);
      }
      
      public function get offer() : Object
      {
         return this._offer;
      }
      
      public function set offer(param1:Object) : void
      {
         var value:Object = param1;
         this._offer = value;
         this.updateDisplay();
         if(this._offer.PriceCoins == null && this._offer.buyInfo == null && this.isPurchasable())
         {
            PaymentSystem.getInstance().getBuyItemDirectData(this._offer.key,null,function(param1:Object):void
            {
               if(_offer == null)
               {
                  return;
               }
               if(param1 != null)
               {
                  _offer.buyInfo = param1;
                  btn_buy.enabled = isPurchasable();
               }
            },function(param1:PlayerIOError):void
            {
               if(_offer == null)
               {
                  return;
               }
               OfferSystem.getInstance().removeOffer(_offer.key);
            });
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIItemImage = null;
         super.dispose();
         this._offer = null;
         if(this._expiresTimer != null)
         {
            this._expiresTimer.stop();
         }
         this.btn_buy.dispose();
         this.txt_title.dispose();
         this.ui_itemInfo.dispose();
         this.bmp_header.bitmapData.dispose();
         this.bmp_footer.bitmapData.dispose();
         for each(_loc1_ in this._itemImages)
         {
            _loc1_.item.dispose();
            _loc1_.dispose();
         }
      }
      
      private function isPurchasable() : Boolean
      {
         if(this._offer == null)
         {
            return false;
         }
         if(this._expired)
         {
            return false;
         }
         if(Boolean(this._offer.oneTime) && Network.getInstance().playerData.hasOneTimePurchase(this._offer.oneTime))
         {
            return false;
         }
         if(Network.getInstance().playerData.cooldowns.hasActive(CooldownType.Purchase,this._offer.key))
         {
            return false;
         }
         if(Boolean(this._offer.upgrade) && Network.getInstance().playerData.upgrades.get(PlayerUpgrades[this._offer.upgrade]))
         {
            return false;
         }
         return true;
      }
      
      private function updateDisplay() : void
      {
         var _loc1_:UIItemImage = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:String = null;
         var _loc12_:int = 0;
         var _loc13_:Matrix = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:* = false;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:Sprite = null;
         var _loc22_:Vector.<Sprite> = null;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc4_:uint = this._offer.headerBgColor != null ? Color.hexToColor(this._offer.headerBgColor) : 11543074;
         var _loc5_:ColorMatrix = new ColorMatrix();
         _loc5_.colorize(_loc4_);
         this.bmp_header.filters = [_loc5_.filter];
         this.txt_title.textColor = this._offer.headerTitleColor != null ? Color.hexToColor(this._offer.headerTitleColor) : 16760832;
         this.txt_title.htmlText = Language.getInstance().getString("offers." + this._offer.key).toUpperCase();
         this.txt_title.x = int(this.bmp_header.x + (this.bmp_header.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.bmp_header.y + (this.bmp_header.height - this.txt_title.height) * 0.5);
         var _loc7_:Number = 0;
         if(this._offer.PriceCoins != null)
         {
            _loc7_ = int(this._offer.PriceCoins);
            if(_loc7_ > 0)
            {
               this.btn_buy.showIcon = true;
               _loc6_ = Language.getInstance().getString("offers.buyfor");
            }
            else
            {
               this.btn_buy.showIcon = false;
               _loc6_ = Language.getInstance().getString("offers.claim");
            }
         }
         else
         {
            this.btn_buy.showIcon = true;
            _loc6_ = Language.getInstance().getString("offers.buyfor");
            switch(Network.getInstance().service)
            {
               case PlayerIOConnector.SERVICE_FACEBOOK:
               case PlayerIOConnector.SERVICE_ARMOR_GAMES:
               case PlayerIOConnector.SERVICE_YAHOO:
               case PlayerIOConnector.SERVICE_PLAYER_IO:
                  this.btn_buy.currency = Currency.US_DOLLARS;
                  _loc7_ = Number((this._offer.PriceUSD / 100).toFixed(2));
                  break;
               case PlayerIOConnector.SERVICE_KONGREGATE:
                  this.btn_buy.currency = Currency.KONGREGATE_KREDS;
                  _loc7_ = int(this._offer.PriceKKR);
            }
         }
         this.btn_buy.label = _loc6_;
         this.btn_buy.cost = _loc7_;
         this.btn_buy.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         this.btn_buy.width = 140;
         this.btn_buy.x = int(this.bmp_footer.x + (this.bmp_footer.width - this.btn_buy.width) * 0.5);
         this.btn_buy.visible = this._offer.type != "codepackage";
         var _loc8_:int = int(this.bmp_header.y + this.bmp_header.height + 3);
         var _loc9_:String = Language.getInstance().getString("offers." + this._offer.key + "_desc");
         if((Boolean(_loc9_)) && _loc9_ != "?")
         {
            _loc3_ = 24;
            this.mc_graphics.graphics.beginFill(592137);
            this.mc_graphics.graphics.drawRect(0,_loc8_,this.bmp_header.width,_loc3_);
            this.mc_graphics.graphics.endFill();
            this.txt_desc = new BodyTextField({
               "color":14606046,
               "size":14,
               "bold":true
            });
            this.txt_desc.htmlText = _loc9_;
            this.txt_desc.x = int(this.bmp_header.x + (this.bmp_header.width - this.txt_desc.width) * 0.5);
            this.txt_desc.y = int(_loc8_ + (_loc3_ - this.txt_desc.height) * 0.5);
            addChild(this.txt_desc);
            _loc8_ += int(_loc3_ + 3);
         }
         this.ui_image.y = _loc8_;
         if(this._offer.image)
         {
            this.ui_image.uri = String(this._offer.image);
         }
         var _loc10_:int = this.bmp_footer.y - 3;
         if(this._offer.expires != null || this._offer.levelMax != null && !this._offer.hideLevels)
         {
            if(this.bmp_timer == null)
            {
               this.bmp_timer = new Bitmap(new BmpIconSearchTimer());
            }
            this.txt_time = new BodyTextField({
               "color":16777215,
               "size":15,
               "bold":true,
               "filters":[Effects.STROKE]
            });
            if(this._offer.expires != null)
            {
               _loc14_ = new Date().time;
               _loc15_ = Number(this._offer.expires.time - _loc14_) / 1000;
               _loc16_ = this._offer.expires.time < _loc14_;
               if(_loc16_)
               {
                  this._expired = true;
                  this.txt_time.htmlText = Language.getInstance().getString("offers.expired");
               }
               else
               {
                  this.txt_time.htmlText = Language.getInstance().getString("offers.limited_time_deadline",DateTimeUtils.secondsToString(_loc15_,true,true));
                  this._expiresTimer = new Timer(500);
                  this._expiresTimer.addEventListener(TimerEvent.TIMER,this.onExpiresTimerTick,false,0,true);
                  this._expiresTimer.start();
               }
            }
            else
            {
               this.txt_time.htmlText = Language.getInstance().getString("offers.limited_level",int(this._offer.levelMax) + 1);
            }
            addChild(this.txt_time);
            _loc2_ = this.txt_time.width + this.bmp_timer.width + 6;
            _loc3_ = 24;
            _loc13_ = new Matrix();
            _loc13_.createGradientBox(_width,24);
            this.mc_graphics.graphics.beginGradientFill("linear",[4408131,4408131,4408131,4408131],[0,1,1,0],[0,100,155,255],_loc13_);
            this.mc_graphics.graphics.drawRect(0,_loc10_ - _loc3_,_width,24);
            this.mc_graphics.graphics.endFill();
            this.bmp_timer.y = int(_loc10_ - _loc3_ + (_loc3_ - this.bmp_timer.height) * 0.5);
            addChild(this.bmp_timer);
            this.txt_time.y = int(_loc10_ - _loc3_ + (_loc3_ - this.txt_time.height) * 0.5);
            this.alignTimeDisplay();
            _loc10_ -= int(_loc3_ + 3);
         }
         var _loc11_:Array = this._offer.items as Array;
         if(_loc11_ != null)
         {
            _loc17_ = 0;
            _loc18_ = 0;
            _loc19_ = 8;
            _loc20_ = 0;
            _loc21_ = new Sprite();
            this.mc_items.addChild(_loc21_);
            _loc22_ = new <Sprite>[_loc21_];
            _loc23_ = 0;
            while(_loc23_ < _loc11_.length)
            {
               _loc1_ = new UIItemImage(48,48,1);
               _loc1_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverItem,false,0,true);
               _loc1_.item = ItemFactory.createItemFromObject(_loc11_[_loc23_]);
               _loc1_.x = _loc17_;
               _loc21_.addChild(_loc1_);
               if(_loc21_.width > _loc20_)
               {
                  _loc20_ = _loc21_.width;
               }
               this._itemImages.push(_loc1_);
               this.ui_itemInfo.addRolloverTarget(_loc1_);
               if(++_loc18_ >= _loc19_)
               {
                  _loc21_ = new Sprite();
                  this.mc_items.addChild(_loc21_);
                  _loc22_.push(_loc21_);
                  _loc18_ = 0;
                  _loc17_ = 0;
               }
               else
               {
                  _loc17_ += int(_loc1_.width + 12);
               }
               _loc23_++;
            }
            _loc24_ = 0;
            _loc23_ = 0;
            while(_loc23_ < _loc22_.length)
            {
               _loc21_ = _loc22_[_loc23_];
               _loc21_.x = int((_loc20_ - _loc21_.width) * 0.5);
               _loc21_.y = _loc24_;
               _loc24_ += int(_loc21_.height + 12);
               _loc23_++;
            }
            _loc25_ = _width - 10;
            if(this.mc_items.width > _loc25_)
            {
               this.mc_items.width = _loc25_;
               this.mc_items.scaleY = this.mc_items.scaleX;
            }
            _loc3_ = this.mc_items.height + 12;
            this.mc_graphics.graphics.beginFill(1184274);
            this.mc_graphics.graphics.drawRect(0,_loc10_ - _loc3_,_width,_loc3_);
            this.mc_graphics.graphics.endFill();
            this.mc_items.x = int((_width - this.mc_items.width) * 0.5);
            this.mc_items.y = int(_loc10_ - _loc3_ + (_loc3_ - this.mc_items.height) * 0.5);
            addChild(this.mc_items);
            _loc10_ -= _loc3_ + 3;
         }
         if(_loc11_ != null)
         {
            this.txt_items = new BodyTextField({
               "color":10855845,
               "size":14,
               "bold":true,
               "filters":[Effects.TEXT_SHADOW_DARK]
            });
            addChild(this.txt_items);
         }
         _loc12_ = int(this._offer.fuel);
         if(_loc12_ > 0)
         {
            _loc3_ = 52;
            this.mc_graphics.graphics.beginFill(2767873,0.75);
            this.mc_graphics.graphics.drawRect(0,_loc10_ - _loc3_,_width,_loc3_);
            this.mc_graphics.graphics.endFill();
            if(this.bmp_fuel == null)
            {
               this.bmp_fuel = new Bitmap(new BmpOffersFuel());
            }
            this.bmp_fuel.x = 14;
            this.bmp_fuel.y = int(_loc10_ - _loc3_ + (_loc3_ - this.bmp_fuel.width) * 0.5);
            addChild(this.bmp_fuel);
            this.txt_fuel = new BodyTextField({
               "color":16761093,
               "size":32,
               "bold":true,
               "filters":[Effects.TEXT_SHADOW_DARK]
            });
            this.txt_fuel.htmlText = Language.getInstance().getString("offers.fuel",NumberFormatter.format(_loc12_,0));
            this.txt_fuel.x = int((_width - this.txt_fuel.width) * 0.5);
            this.txt_fuel.y = int(_loc10_ - _loc3_ + (_loc3_ - this.txt_fuel.height) * 0.5);
            addChild(this.txt_fuel);
            if(_loc11_ != null)
            {
               this.txt_items.htmlText = Language.getInstance().getString("offers.bonus_items");
               this.txt_fuel.y -= int((this.txt_items.height - 4) * 0.5);
               this.txt_items.x = int(this.txt_fuel.x + (this.txt_fuel.width - this.txt_items.width) * 0.5);
               this.txt_items.y = int(this.txt_fuel.y + this.txt_fuel.height - 4);
            }
         }
         else if(_loc11_ != null)
         {
            this.txt_items.htmlText = Language.getInstance().getString("offers.items");
            this.txt_items.x = int((_width - this.txt_items.width) * 0.5);
            this.txt_items.y = int(this.mc_items.y - this.txt_items.height - 8);
         }
         this.btn_buy.enabled = this.isPurchasable() && (this._offer.PriceCoins != null || this._offer.buyInfo != null);
      }
      
      private function alignTimeDisplay() : void
      {
         var _loc1_:int = this.txt_time.width + this.bmp_timer.width + 6;
         this.bmp_timer.x = int((_width - (_loc1_ - this.bmp_timer.width)) * 0.5);
         this.txt_time.x = int(this.bmp_timer.x + this.bmp_timer.width + 6);
      }
      
      private function onExpiresTimerTick(param1:TimerEvent) : void
      {
         var _loc2_:int = int(this._offer.expires.time - new Date().time) / 1000;
         if(_loc2_ <= 0)
         {
            this._expiresTimer.stop();
            this._expired = true;
            this.btn_buy.enabled = false;
            this.txt_time.htmlText = Language.getInstance().getString("offers.expired");
            this.alignTimeDisplay();
            return;
         }
         this.txt_time.htmlText = Language.getInstance().getString("offers.limited_time_deadline",DateTimeUtils.secondsToString(_loc2_,true,true));
         this.alignTimeDisplay();
      }
      
      private function onMouseOverItem(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:UIItemImage = UIItemImage(param1.currentTarget);
         if(_loc2_.item != null)
         {
            _loc3_ = _loc2_.item.getMaxLevel();
            this.ui_itemInfo.extraInfo = _loc2_.item.isUpgradable && _loc2_.item.level < _loc3_ ? Language.getInstance().getString("crafting_info_maxlevel",_loc3_ + 1) : null;
            this.ui_itemInfo.setItem(_loc2_.item);
         }
      }
      
      private function onPurchaseClicked(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         PaymentSystem.getInstance().buyPackage(this._offer,function(param1:Boolean):void
         {
            if(!param1)
            {
               return;
            }
            if(_expired || _offer.upgrade || Boolean(_offer.oneTime) || Network.getInstance().playerData.cooldowns.hasActive(CooldownType.Purchase,_offer.key))
            {
               btn_buy.enabled = false;
            }
         });
      }
      
      private function onBuyInfoReceived() : void
      {
         if(this._offer.buyInfo != null)
         {
            this.btn_buy.enabled = this.isPurchasable();
         }
      }
   }
}

