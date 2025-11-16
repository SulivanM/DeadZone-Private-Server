package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.common.lang.Language;
   
   public class InventoryUpgradeDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _buyInfo:Object = null;
      
      private var _panels:Vector.<Panel>;
      
      private var mc_container:Sprite;
      
      private var mc_panels:Sprite;
      
      private var txt_info:BodyTextField;
      
      public function InventoryUpgradeDialogue()
      {
         var _loc1_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:Panel = null;
         this._lang = Language.getInstance();
         this.mc_container = new Sprite();
         super("inventory-upgrade",this.mc_container,true);
         var _loc2_:Vector.<Object> = new Vector.<Object>();
         var _loc3_:int = 3;
         _loc1_ = 1;
         while(_loc1_ <= _loc3_)
         {
            _loc6_ = "InventoryUpgrade" + _loc1_;
            if(Network.getInstance().service == PlayerIOConnector.SERVICE_KONGREGATE)
            {
               _loc6_ = _loc6_.toLowerCase();
            }
            if(Network.getInstance().playerData.canBuyInventoryUpgrade(_loc6_))
            {
               _loc7_ = Network.getInstance().data.costTable.getItemByKey(_loc6_);
               _loc2_.push(_loc7_);
            }
            _loc1_++;
         }
         this._panels = new Vector.<Panel>(_loc2_.length);
         this.mc_panels = new Sprite();
         this.mc_container.addChild(this.mc_panels);
         var _loc4_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc8_ = new Panel(_loc2_[_loc1_]);
            _loc8_.x = _loc4_;
            _loc8_.purchaseClicked.add(this.onPurchaseButtonClicked);
            _loc4_ += _loc8_.width + _padding;
            this._panels[_loc1_] = _loc8_;
            this.mc_panels.addChild(_loc8_);
            _loc1_++;
         }
         _width = Math.max(int(_loc4_ + _padding),300);
         _height = int(this._panels[0].height + 44);
         _autoSize = false;
         this.mc_panels.x = int((_width - this.mc_panels.width) * 0.5 - _padding);
         this.txt_info = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.STROKE],
            "align":TextFormatAlign.CENTER
         });
         this.txt_info.text = Language.getInstance().getString("inventory_upgrade_desc",NumberFormatter.format(Config.constant.INVENTORY_MAX,0));
         var _loc5_:int = _width - _padding * 2;
         if(this.txt_info.width > _loc5_)
         {
            this.txt_info.multiline = true;
            this.txt_info.wordWrap = true;
            this.txt_info.autoSize = TextFieldAutoSize.CENTER;
            this.txt_info.width = _loc5_;
            this.txt_info.text = this.txt_info.text;
         }
         this.txt_info.x = int((_width - this.txt_info.width) * 0.5 - _padding);
         this.txt_info.y = int(this._panels[0].height + 8);
         this.mc_container.addChild(this.txt_info);
         _height = int(this.txt_info.y + this.txt_info.height + _padding + 16);
         addTitle(this._lang.getString("inventory_upgrade_title"),BaseDialogue.TITLE_COLOR_BUY);
      }
      
      override public function dispose() : void
      {
         var _loc1_:Panel = null;
         super.dispose();
         this._lang = null;
         for each(_loc1_ in this._panels)
         {
            _loc1_.dispose();
         }
         this.txt_info.dispose();
      }
      
      override public function open() : void
      {
         var _loc1_:Panel = null;
         super.open();
         for each(_loc1_ in this._panels)
         {
            _loc1_.loadBuyItemData();
         }
      }
      
      private function onPurchaseButtonClicked(param1:Object, param2:Object) : void
      {
         var p:Panel = null;
         var itemData:Object = param1;
         var buyInfo:Object = param2;
         if(itemData == null || buyInfo == null)
         {
            return;
         }
         for each(p in this._panels)
         {
            p.lock();
         }
         PaymentSystem.getInstance().buyDirectItem(itemData.key,buyInfo,"Upgrading inventory...",function(param1:Boolean):void
         {
            var _loc2_:Panel = null;
            if(!isOpen)
            {
               return;
            }
            if(param1)
            {
               close();
            }
            else
            {
               for each(_loc2_ in _panels)
               {
                  _loc2_.unlock();
               }
            }
         });
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.events.MouseEvent;
import org.osflash.signals.Signal;
import thelaststand.app.data.Currency;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.gui.buttons.PurchasePushButton;
import thelaststand.app.gui.UIComponent;
import thelaststand.app.gui.UIImage;
import thelaststand.app.network.Network;
import thelaststand.app.network.PaymentSystem;
import thelaststand.app.network.PlayerIOConnector;
import thelaststand.app.utils.GraphicUtils;
import thelaststand.common.lang.Language;

class Panel extends UIComponent
{
   
   private var _width:int = 158;
   
   private var _height:int = 234;
   
   private var _data:Object;
   
   private var _buyInfo:Object;
   
   private var _disposed:Boolean = false;
   
   private var ui_image:UIImage;
   
   private var btn_buy:PurchasePushButton;
   
   private var txt_amount:BodyTextField;
   
   private var txt_total:BodyTextField;
   
   public var purchaseClicked:Signal;
   
   public function Panel(param1:Object)
   {
      var _loc2_:String = null;
      this.purchaseClicked = new Signal(Object,Object);
      super();
      this._data = param1;
      var _loc3_:Number = 0;
      switch(Network.getInstance().service)
      {
         case PlayerIOConnector.SERVICE_FACEBOOK:
         case PlayerIOConnector.SERVICE_ARMOR_GAMES:
         case PlayerIOConnector.SERVICE_YAHOO:
         case PlayerIOConnector.SERVICE_PLAYER_IO:
            _loc2_ = Currency.US_DOLLARS;
            _loc3_ = this._data.PriceUSD / 100;
            break;
         case PlayerIOConnector.SERVICE_KONGREGATE:
            _loc2_ = Currency.KONGREGATE_KREDS;
            _loc3_ = Number(this._data.PriceKKR);
      }
      this.btn_buy = new PurchasePushButton("",_loc3_);
      this.btn_buy.currency = _loc2_;
      this.btn_buy.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
      this.btn_buy.height = 24;
      this.btn_buy.width = int(this._width * 0.75);
      this.btn_buy.clicked.add(this.onClickedPurchase);
      this.ui_image = new UIImage(this._width - 3,164,0,0,true);
      this.ui_image.uri = "images/ui/" + this._data.key.toLowerCase() + ".jpg";
      this.txt_amount = new BodyTextField({
         "text":" ",
         "color":16300048,
         "size":18,
         "bold":true,
         "filters":[Effects.STROKE]
      });
      this.txt_amount.maxWidth = int(this._width - 20);
      this.txt_amount.text = Language.getInstance().getString("inventory_upgrade_slots",NumberFormatter.format(this._data.amount,0));
      var _loc4_:int = Network.getInstance().playerData.inventoryBaseSize + int(this._data.amount);
      this.txt_total = new BodyTextField({
         "text":" ",
         "color":6269517,
         "size":14,
         "bold":true,
         "filters":[Effects.STROKE]
      });
      this.txt_total.maxWidth = int(this._width - 20);
      this.txt_total.text = Language.getInstance().getString("inventory_upgrade_total",NumberFormatter.format(_loc4_,0));
      addChild(this.ui_image);
      addChild(this.txt_amount);
      addChild(this.txt_total);
      addChild(this.btn_buy);
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
   
   override public function dispose() : void
   {
      this._disposed = true;
      super.dispose();
      this.ui_image.dispose();
      this.btn_buy.dispose();
      this.txt_amount.dispose();
      this.txt_total.dispose();
   }
   
   public function loadBuyItemData() : void
   {
      this.btn_buy.enabled = false;
      PaymentSystem.getInstance().getBuyItemDirectData(this._data.key,null,function(param1:Object):void
      {
         if(_disposed)
         {
            return;
         }
         _buyInfo = param1;
         btn_buy.enabled = true;
      });
   }
   
   public function lock() : void
   {
      this.btn_buy.enabled = false;
   }
   
   public function unlock() : void
   {
      this.btn_buy.enabled = this._buyInfo != null;
   }
   
   override protected function draw() : void
   {
      graphics.clear();
      GraphicUtils.drawUIBlock(graphics,this._width,this._height);
      this.ui_image.x = this.ui_image.y = 3;
      this.ui_image.width = int(this._width - this.ui_image.x * 2);
      this.btn_buy.x = int((this._width - this.btn_buy.width) * 0.5);
      this.btn_buy.y = int(this._height - this.btn_buy.height - 18);
      this.txt_amount.x = int((this._width - this.txt_amount.width) * 0.5);
      this.txt_amount.y = int(this.btn_buy.y - this.txt_amount.height - 28);
      this.txt_total.x = int((this._width - this.txt_total.width) * 0.5);
      this.txt_total.y = int(this.txt_amount.y + this.txt_amount.height - 4);
   }
   
   private function onClickedPurchase(param1:MouseEvent) : void
   {
      this.purchaseClicked.dispatch(this._data,this._buyInfo);
   }
}
