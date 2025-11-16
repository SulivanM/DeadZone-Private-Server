package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   
   public class TradeSlotUpgradeDialogue extends BaseDialogue
   {
      
      public var slotUpgradePurchased:Signal = new Signal();
      
      private var _lang:Language;
      
      private var _buyInfo:Object;
      
      private var mc_container:Sprite = new Sprite();
      
      private var btn_buy:PurchasePushButton;
      
      private var txt_desc:BodyTextField;
      
      private var ui_image:UIImage;
      
      public function TradeSlotUpgradeDialogue()
      {
         super("upgrade-car",this.mc_container,true);
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 480;
         _height = 240;
         addTitle(this._lang.getString("upgrade_trade_title"),BaseDialogue.TITLE_COLOR_BUY);
         var _loc1_:int = _padding * 0.5;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,234,194,0,_loc1_);
         this.ui_image = new UIImage(230,190);
         this.ui_image.uri = "images/ui/buy-tradeslots.jpg";
         this.ui_image.x = 2;
         this.ui_image.y = _loc1_ + 2;
         this.mc_container.addChild(this.ui_image);
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_desc.htmlText = StringUtils.htmlSetDoubleBreakLeading(this._lang.getString("upgrade_trade_desc"));
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.txt_desc.x = int(this.ui_image.x + this.ui_image.width + 8);
         this.txt_desc.y = int(this.ui_image.y);
         this.txt_desc.width = int(_width - this.txt_desc.x - _padding * 2);
         this.mc_container.addChild(this.txt_desc);
         var _loc2_:int = int(Network.getInstance().data.costTable.getItemByKey("TradeSlotUpgrade").PriceCoins);
         this.btn_buy = new PurchasePushButton(this._lang.getString("upgrade_trade_buy"),_loc2_,true);
         this.btn_buy.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         this.btn_buy.clicked.add(this.onClickBuy);
         this.btn_buy.width = 194;
         this.btn_buy.x = int(this.txt_desc.x + (this.txt_desc.width - this.btn_buy.width) * 0.5);
         this.btn_buy.y = int(this.ui_image.y + this.ui_image.height - this.btn_buy.height - 4);
         this.mc_container.addChild(this.btn_buy);
      }
      
      override public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         super.dispose();
         this.btn_buy.dispose();
         this.txt_desc.dispose();
         this.ui_image.dispose();
         this.slotUpgradePurchased.removeAll();
      }
      
      private function onClickBuy(param1:MouseEvent) : void
      {
         var lang:Language = null;
         var itemKey:String = null;
         var msg:BusyDialogue = null;
         var e:MouseEvent = param1;
         lang = Language.getInstance();
         itemKey = PlayerUpgrades.getName(PlayerUpgrades.TradeSlotUpgrade);
         this.btn_buy.enabled = false;
         msg = new BusyDialogue(lang.getString("upgrading_trade"),"trade-purchasing");
         msg.open();
         PaymentSystem.getInstance().buyPayVaultItem(itemKey,true,function(param1:Boolean):void
         {
            msg.close();
            if(param1)
            {
               slotUpgradePurchased.dispatch();
               new ItemPurchasedDialogue(lang.getString("buy_tradeUpgrade_complete_title"),lang.getString("buy_tradeUpgrade_complete_msg"),"images/ui/buy-tradeslots.jpg",230,190).open();
               Tracking.trackEvent("Player","Purchase",itemKey + "_Level" + Network.getInstance().playerData.getPlayerSurvivor().level);
               close();
            }
            else
            {
               btn_buy.enabled = true;
            }
         });
      }
   }
}

