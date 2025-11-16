package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.common.lang.Language;
   
   public class BuyFuelDialogue extends BaseDialogue
   {
      
      private static var _selectedCurrency:String;
      
      private var _lang:Language;
      
      private var _panels:Vector.<FuelPurchasePanel>;
      
      private var _options:Vector.<Object>;
      
      private var mc_container:Sprite = new Sprite();
      
      public function BuyFuelDialogue()
      {
         super("buy-fuel",this.mc_container,true);
         _padding = 10;
         _contentOffset.y = _padding;
         this._lang = Language.getInstance();
         this._panels = new Vector.<FuelPurchasePanel>();
         addTitle(this._lang.getString("buy_fuel"),BaseDialogue.TITLE_COLOR_BUY);
         if(_selectedCurrency == null)
         {
            _selectedCurrency = PlayerIOConnector.getInstance().user.defaultCurrency;
         }
         this.setPurchaseOptions();
      }
      
      override public function dispose() : void
      {
         var _loc1_:FuelPurchasePanel = null;
         super.dispose();
         for each(_loc1_ in this._panels)
         {
            _loc1_.dispose();
         }
         this._panels = null;
         this._options = null;
         this._lang = null;
      }
      
      private function setPurchaseOptions() : void
      {
         var tx:int;
         var desciptions:Array;
         var tags:Array;
         var i:int = 0;
         var optionData:Object = null;
         var panel:FuelPurchasePanel = null;
         var optionList:Vector.<Object> = Network.getInstance().data.costTable.getItems("buy_coins_" + Network.getInstance().service);
         this._options = new Vector.<Object>();
         i = 0;
         for(; i < optionList.length; i++)
         {
            optionData = optionList[i];
            if(optionData.pack != null)
            {
               optionData = Network.getInstance().data.costTable.getItemByKey(optionData.pack);
               if(optionData == null)
               {
                  continue;
               }
               optionData.order = optionList[i].order;
               optionData.isPack = true;
            }
            if(optionData.hasOwnProperty("Price" + _selectedCurrency))
            {
               this._options.push(optionData);
            }
         }
         this._options.sort(function(param1:Object, param2:Object):int
         {
            var _loc3_:Number = Number(param1.order);
            var _loc4_:Number = Number(param2.order);
            if(_loc3_ < _loc4_)
            {
               return -1;
            }
            if(_loc4_ < _loc3_)
            {
               return 1;
            }
            return 0;
         });
         tx = 0;
         desciptions = this._lang.getEnum("buy_coins_desc");
         tags = this._lang.getEnum("buy_coins_tag");
         i = 0;
         while(i < this._options.length)
         {
            optionData = this._options[i];
            if(optionData != null)
            {
               panel = new FuelPurchasePanel(optionData,_selectedCurrency,desciptions[i],tags[i]);
               panel.selected.add(this.onOptionSelected);
               panel.x = tx;
               tx += int(panel.width + 8);
               this.mc_container.addChild(panel);
               this._panels.push(panel);
            }
            i++;
         }
      }
      
      private function onOptionSelected(param1:Object) : void
      {
         if(param1.isPack)
         {
            Tracking.trackPageview("buyFuel/buy" + param1.key);
            PaymentSystem.getInstance().buyPackage(param1);
            return;
         }
         Tracking.trackPageview("buyFuel/buy" + param1.key);
         if(param1.payPayURL != null)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("openWindow",param1.payPayURL);
            }
            else
            {
               navigateToURL(new URLRequest(param1.payPayURL),"_blank");
            }
         }
         else
         {
            PaymentSystem.getInstance().buyCoins(int(param1.fuel),_selectedCurrency,Number(param1["Price" + _selectedCurrency]));
         }
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import org.osflash.signals.Signal;
import thelaststand.app.data.Currency;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.Item;
import thelaststand.app.game.data.ItemFactory;
import thelaststand.app.game.gui.UIItemImage;
import thelaststand.app.game.gui.UIItemInfo;
import thelaststand.app.gui.UIBusySpinner;
import thelaststand.app.gui.UIImage;
import thelaststand.app.gui.buttons.PushButton;
import thelaststand.app.network.PaymentSystem;
import thelaststand.app.network.payments.PayPalPayments;
import thelaststand.app.utils.GraphicUtils;
import thelaststand.common.lang.Language;

class FuelPurchasePanel extends Sprite
{
   
   private var _data:Object;
   
   private var _padding:int = 4;
   
   private var _width:int = 138;
   
   private var _height:int = 386;
   
   private var _itemImages:Vector.<UIItemImage>;
   
   private var bmp_fuelIcon:Bitmap;
   
   private var bmp_currency:Bitmap;
   
   private var bmp_sash:Bitmap;
   
   private var btn_buy:PushButton;
   
   private var mc_fuelBg:Shape;
   
   private var txt_cost:BodyTextField;
   
   private var txt_fuel:BodyTextField;
   
   private var txt_fuelBonus:BodyTextField;
   
   private var txt_promo:BodyTextField;
   
   private var txt_sash:BodyTextField;
   
   private var ui_image:UIImage;
   
   private var ui_itemInfo:UIItemInfo;
   
   private var mc_busy:UIBusySpinner;
   
   public var selected:Signal;
   
   public function FuelPurchasePanel(param1:Object, param2:String, param3:String, param4:String)
   {
      var fuelWidth:int;
      var costHeight:int;
      var fuelBonusHeight:int;
      var bonusHeight:int;
      var items:Array;
      var fuelAmount:int = 0;
      var currencyCost:Number = NaN;
      var tx:int = 0;
      var ty:int = 0;
      var bmd:BitmapData = null;
      var currencyWidth:int = 0;
      var data:Object = param1;
      var currency:String = param2;
      var desc:String = param3;
      var tag:String = param4;
      this.selected = new Signal(Object);
      super();
      this._data = data;
      this._itemImages = new Vector.<UIItemImage>();
      fuelAmount = int(this._data.fuel);
      currencyCost = Number(this._data["Price" + currency]);
      GraphicUtils.drawUIBlock(graphics,this._width,this._height);
      this.ui_image = new UIImage(130,154,0,0);
      this.ui_image.uri = data.image.toString();
      this.ui_image.x = this.ui_image.y = this._padding;
      addChild(this.ui_image);
      if(tag != null && tag.length > 0)
      {
         this.drawSash(tag);
      }
      this.mc_fuelBg = new Shape();
      this.mc_fuelBg.graphics.beginFill(1184274,0.45);
      this.mc_fuelBg.graphics.drawRect(0,0,this.ui_image.width,34);
      this.mc_fuelBg.graphics.endFill();
      this.mc_fuelBg.x = this.ui_image.x;
      this.mc_fuelBg.y = int(this.ui_image.y + this.ui_image.height - this.mc_fuelBg.height);
      addChild(this.mc_fuelBg);
      this.txt_fuel = new BodyTextField({
         "color":16760832,
         "size":28,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_fuel.htmlText = NumberFormatter.format(fuelAmount,0);
      addChild(this.txt_fuel);
      this.bmp_fuelIcon = new Bitmap(new BmpIconFuel(),"auto",true);
      this.bmp_fuelIcon.height = 22;
      this.bmp_fuelIcon.scaleX = this.bmp_fuelIcon.scaleY;
      this.bmp_fuelIcon.filters = [Effects.ICON_SHADOW];
      addChild(this.bmp_fuelIcon);
      fuelWidth = this.txt_fuel.width + this.bmp_fuelIcon.width + 4;
      this.txt_fuel.x = int(this.mc_fuelBg.x + (this.mc_fuelBg.width - fuelWidth) * 0.5);
      this.txt_fuel.y = int(this.mc_fuelBg.y + (this.mc_fuelBg.height - this.txt_fuel.height) * 0.5);
      this.bmp_fuelIcon.x = int(this.txt_fuel.x + this.txt_fuel.width + 4);
      this.bmp_fuelIcon.y = int(this.mc_fuelBg.y + (this.mc_fuelBg.height - this.bmp_fuelIcon.height) * 0.5);
      this.btn_buy = new PushButton(Language.getInstance().getString("buy_now"));
      this.btn_buy.clicked.add(this.onClickedBuy);
      this.btn_buy.width = 112;
      this.btn_buy.x = int((this._width - this.btn_buy.width) * 0.5);
      this.btn_buy.y = int(this._height - this.btn_buy.height - 14);
      addChild(this.btn_buy);
      tx = int(this._padding);
      ty = int(this.ui_image.y + this.ui_image.height);
      costHeight = 34;
      graphics.beginFill(1184274);
      graphics.drawRect(tx,ty,this.ui_image.width,costHeight);
      graphics.endFill();
      this.txt_cost = new BodyTextField({
         "color":11250603,
         "size":16,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      addChild(this.txt_cost);
      if(currency == Currency.US_DOLLARS)
      {
         switch(currency)
         {
            case Currency.US_DOLLARS:
         }
         this.txt_cost.text = "$" + NumberFormatter.format(Number(currencyCost / 100),2,",",false) + " USD";
         this.txt_cost.x = int(tx + (this.ui_image.width - this.txt_cost.width) * 0.5);
         this.txt_cost.y = int(ty + (costHeight - this.txt_cost.height) * 0.5);
      }
      else
      {
         switch(currency)
         {
            case Currency.FACEBOOK_CREDITS:
               bmd = new BmpIconFBCredit();
               break;
            case Currency.KONGREGATE_KREDS:
               bmd = new BmpIconKongKreds();
         }
         this.txt_cost.text = NumberFormatter.format(currencyCost,2,",",false);
         currencyWidth = int(this.txt_cost.width + bmd.width + 6);
         this.txt_cost.x = int(tx + (this.ui_image.width - currencyWidth) * 0.5);
         this.txt_cost.y = int(ty + (costHeight - this.txt_cost.height) * 0.5);
         this.bmp_currency = new Bitmap(bmd);
         this.bmp_currency.filters = [Effects.ICON_SHADOW];
         this.bmp_currency.x = int(this.txt_cost.x + this.txt_cost.width + 6);
         this.bmp_currency.y = int(ty + (costHeight - this.bmp_currency.height) * 0.5);
         addChild(this.bmp_currency);
      }
      ty += costHeight + this._padding;
      fuelBonusHeight = 24;
      graphics.beginFill(1184274);
      graphics.drawRect(tx,ty,this.ui_image.width,fuelBonusHeight);
      graphics.endFill();
      this.txt_fuelBonus = new BodyTextField({
         "color":6054234,
         "size":15,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_fuelBonus.htmlText = desc;
      this.txt_fuelBonus.x = int(tx + (this.ui_image.width - this.txt_fuelBonus.width) * 0.5);
      this.txt_fuelBonus.y = int(ty + (fuelBonusHeight - this.txt_fuelBonus.height) * 0.5);
      addChild(this.txt_fuelBonus);
      ty += fuelBonusHeight + this._padding;
      bonusHeight = this.btn_buy.y - 10 - ty;
      graphics.beginFill(1184274);
      graphics.drawRect(tx,ty,this.ui_image.width,bonusHeight);
      graphics.endFill();
      this.txt_promo = new BodyTextField({
         "color":3026478,
         "size":15,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      addChild(this.txt_promo);
      items = this._data.items as Array;
      if(items == null || items.length == 0)
      {
         this.txt_promo.htmlText = Language.getInstance().getString("buy_no_bonus");
         this.txt_promo.x = int(tx + (this.ui_image.width - this.txt_promo.width) * 0.5);
         this.txt_promo.y = int(ty + (bonusHeight - this.txt_promo.height) * 0.5);
      }
      else
      {
         this.ui_itemInfo = new UIItemInfo();
         this.txt_promo.htmlText = Language.getInstance().getString("buy_bonus");
         this.txt_promo.textColor = 7960953;
         this.txt_promo.x = int(tx + (this.ui_image.width - this.txt_promo.width) * 0.5);
         this.txt_promo.y = int(ty + 3);
         this.drawItems(ty);
      }
      if(this._data.isPack)
      {
         this.mc_busy = new UIBusySpinner();
         this.mc_busy.x = int(this.btn_buy.x + this.btn_buy.width * 0.5);
         this.mc_busy.y = int(this.btn_buy.y + this.btn_buy.height * 0.5);
         addChild(this.mc_busy);
         this.btn_buy.label = "";
         this.btn_buy.enabled = false;
         PaymentSystem.getInstance().getBuyItemDirectData(this._data.key,null,function(param1:Object):void
         {
            _data.buyInfo = param1;
            btn_buy.enabled = true;
            btn_buy.label = Language.getInstance().getString("buy_now");
            if(mc_busy.parent != null)
            {
               mc_busy.parent.removeChild(mc_busy);
            }
         });
      }
      else if(PaymentSystem.getInstance() is PayPalPayments && currency == Currency.US_DOLLARS)
      {
         this.mc_busy = new UIBusySpinner();
         this.mc_busy.x = int(this.btn_buy.x + this.btn_buy.width * 0.5);
         this.mc_busy.y = int(this.btn_buy.y + this.btn_buy.height * 0.5);
         addChild(this.mc_busy);
         this.btn_buy.label = "";
         this.btn_buy.enabled = false;
         PaymentSystem.getInstance().getPayPalCoinsURL(fuelAmount,currency,currencyCost,function(param1:String):void
         {
            _data.payPayURL = param1;
            btn_buy.enabled = true;
            btn_buy.label = Language.getInstance().getString("buy_now");
            if(mc_busy.parent != null)
            {
               mc_busy.parent.removeChild(mc_busy);
            }
         });
      }
   }
   
   public function get data() : Object
   {
      return this._data;
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
      var _loc1_:UIItemImage = null;
      if(parent != null)
      {
         parent.removeChild(this);
      }
      this.selected.removeAll();
      this.ui_image.dispose();
      this.txt_fuel.dispose();
      this.txt_cost.dispose();
      this.txt_fuelBonus.dispose();
      this.txt_promo.dispose();
      this.bmp_fuelIcon.bitmapData.dispose();
      this.btn_buy.dispose();
      if(this.bmp_currency != null)
      {
         this.bmp_currency.bitmapData.dispose();
      }
      if(this.bmp_sash != null)
      {
         this.bmp_sash.bitmapData.dispose();
      }
      if(this.txt_sash != null)
      {
         this.txt_sash.dispose();
      }
      if(this.ui_itemInfo != null)
      {
         this.ui_itemInfo.dispose();
      }
      if(this.mc_busy != null)
      {
         this.mc_busy.dispose();
      }
      for each(_loc1_ in this._itemImages)
      {
         _loc1_.dispose();
      }
      this._itemImages = null;
   }
   
   private function drawSash(param1:String) : void
   {
      this.bmp_sash = new Bitmap(new BmpLargeSash());
      this.bmp_sash.x = this.ui_image.x + 1;
      this.bmp_sash.y = this.ui_image.y + 1;
      addChild(this.bmp_sash);
      this.txt_sash = new BodyTextField({
         "color":16777215,
         "size":14,
         "bold":true,
         "filters":[Effects.STROKE]
      });
      this.txt_sash.maxWidth = 64;
      this.txt_sash.htmlText = param1;
      addChild(this.txt_sash);
      var _loc2_:Matrix = new Matrix();
      _loc2_.scale(this.txt_sash.scaleX,this.txt_sash.scaleY);
      this.txt_sash.transform.matrix = _loc2_;
      var _loc3_:Number = this.txt_sash.width * 0.5;
      var _loc4_:Number = this.txt_sash.height * 0.5;
      var _loc5_:Number = 36;
      var _loc6_:Number = 20;
      _loc2_.translate(-_loc3_,-_loc4_);
      _loc2_.rotate(-25.3 * Math.PI / 180);
      _loc2_.translate(this.bmp_sash.x + _loc5_,this.bmp_sash.y + _loc6_);
      this.txt_sash.transform.matrix = _loc2_;
   }
   
   private function drawItems(param1:int) : void
   {
      var _loc10_:Item = null;
      var _loc11_:UIItemImage = null;
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      var _loc4_:int = 3;
      var _loc5_:int = 10;
      var _loc6_:Sprite = new Sprite();
      var _loc7_:Array = [_loc6_];
      var _loc8_:int = 0;
      while(_loc8_ < this._data.items.length)
      {
         _loc10_ = ItemFactory.createItemFromObject(this._data.items[_loc8_]);
         if(_loc10_ != null)
         {
            _loc11_ = new UIItemImage(32,32,1);
            _loc11_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverItem,false,0,true);
            _loc11_.item = _loc10_;
            _loc11_.x = _loc2_;
            this.ui_itemInfo.addRolloverTarget(_loc11_);
            _loc6_.addChild(_loc11_);
            this._itemImages.push(_loc11_);
            if(_loc8_ >= this._data.length - 1)
            {
               break;
            }
            if(++_loc3_ >= _loc4_)
            {
               _loc6_ = new Sprite();
               _loc7_.push(_loc6_);
               _loc2_ = 0;
               _loc3_ = 0;
            }
            else
            {
               _loc2_ += int(_loc11_.width + _loc5_);
            }
         }
         _loc8_++;
      }
      var _loc9_:int = param1 + 30;
      _loc8_ = 0;
      while(_loc8_ < _loc7_.length)
      {
         _loc6_ = _loc7_[_loc8_];
         _loc6_.x = int((this._width - _loc6_.width) * 0.5);
         _loc6_.y = _loc9_;
         addChild(_loc6_);
         _loc9_ += int(_loc6_.height + _loc5_);
         _loc8_++;
      }
   }
   
   private function onMouseOverItem(param1:MouseEvent) : void
   {
      this.ui_itemInfo.setItem(UIItemImage(param1.currentTarget).item);
   }
   
   private function onClickedBuy(param1:MouseEvent) : void
   {
      this.selected.dispatch(this._data);
   }
}
