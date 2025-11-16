package thelaststand.app.game.gui.dialogues
{
   import com.adobe.images.JPGEncoder;
   import com.dynamicflash.util.Base64;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerPanelEditor;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class AllianceBannerEditDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _orgBannerHex:String;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _network:Network;
      
      private var _chargedCost:int;
      
      private var _actualItemCost:int;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_bannerEditor:AllianceBannerPanelEditor;
      
      private var btn_save:PushButton;
      
      private var btn_cancel:PushButton;
      
      public function AllianceBannerEditDialogue()
      {
         super("alliance-bannerEdit",this.mc_container,false);
         this._allianceSystem = AllianceSystem.getInstance();
         if(!this._allianceSystem.isConnected || this._allianceSystem.alliance == null || !this._allianceSystem.inAlliance)
         {
            return;
         }
         this._network = Network.getInstance();
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 260;
         _height = 435;
         addTitle(this._lang.getString("alliance.editbanner_title"),TITLE_COLOR_GREY);
         var _loc1_:int = _padding * 0.5;
         this.ui_bannerEditor = new AllianceBannerPanelEditor(true);
         this.ui_bannerEditor.changed.add(this.onBannerChanged);
         this.ui_bannerEditor.byteArray = this._allianceSystem.alliance.banner.byteArray;
         this.mc_container.addChild(this.ui_bannerEditor);
         this._orgBannerHex = this.ui_bannerEditor.hexString;
         this._actualItemCost = int(this._network.data.costTable.getItemByKey("AllianceBannerEdit").PriceCoins);
         this._chargedCost = 0;
         if(this._allianceSystem.alliance.numBannerEdits > 0)
         {
            this._chargedCost = this._actualItemCost;
         }
         if(this._chargedCost == 0)
         {
            this.btn_save = new PushButton(this._lang.getString("alliance.editbanner_saveFree"),null,-1,null,Effects.BUTTON_GREEN);
         }
         else
         {
            this.btn_save = new PurchasePushButton(this._lang.getString("alliance.editbanner_save"),this._chargedCost);
         }
         this.btn_save.clicked.add(this.onButtonClick);
         this.btn_save.width = 130;
         this.btn_save.x = this.ui_bannerEditor.x + 4;
         this.btn_save.y = this.ui_bannerEditor.y + this.ui_bannerEditor.height + 10;
         this.btn_save.enabled = false;
         this.mc_container.addChild(this.btn_save);
         this.btn_cancel = new PushButton(this._lang.getString("alliance.editbanner_cancel"));
         this.btn_cancel.clicked.add(this.onButtonClick);
         this.btn_cancel.width = 84;
         this.btn_cancel.x = this.ui_bannerEditor.x + this.ui_bannerEditor.width - (this.btn_cancel.width + 4);
         this.btn_cancel.y = this.btn_save.y;
         this.mc_container.addChild(this.btn_cancel);
         if(this._chargedCost == 0)
         {
            opened.addOnce(this.displayFirstTimeWarning);
         }
         this._allianceSystem.clientMember.rankChanged.addOnce(this.onAllianceClientRankChanged);
         this._allianceSystem.disconnected.addOnce(this.onAllianceSystemDisconnected);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.btn_save.dispose();
         this.btn_cancel.dispose();
         this.ui_bannerEditor.dispose();
         this._network = null;
         if(this._allianceSystem.clientMember != null)
         {
            this._allianceSystem.clientMember.rankChanged.remove(this.onAllianceClientRankChanged);
         }
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem = null;
      }
      
      private function displayFirstTimeWarning(param1:Dialogue) : void
      {
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("alliance.editbanner_firstFreeMsg",NumberFormatter.format(this._actualItemCost,0)),"firstFreeWarning",false,true,100,380);
         _loc2_.addTitle(this._lang.getString("alliance.editbanner_firstFreeTitle"));
         _loc2_.addButton(this._lang.getString("alliance.editbanner_firstFreeOk"));
         _loc2_.open();
      }
      
      private function save(param1:MouseEvent = null) : void
      {
         var jpeg:JPGEncoder;
         var thumb64:String;
         var dlgBusy:BusyDialogue = null;
         var e:MouseEvent = param1;
         dlgBusy = new BusyDialogue(this._lang.getString("alliance.editbanner_saving"));
         dlgBusy.open();
         jpeg = new JPGEncoder(90);
         thumb64 = Base64.encodeByteArray(jpeg.encode(this.ui_bannerEditor.generateThumbnail()));
         this._allianceSystem.saveBanner(this.ui_bannerEditor.bannerData,thumb64,function(param1:RPCResponse):void
         {
            var _loc2_:MessageBox = null;
            dlgBusy.close();
            var _loc3_:Language = Language.getInstance();
            if(!param1.success)
            {
               _loc2_ = new MessageBox(_loc3_.getString("alliance.editbanner_error"),null);
               _loc2_.addTitle(_loc3_.getString("alliance.editbanner_errorTitle"),BaseDialogue.TITLE_COLOR_RUST);
               _loc2_.addButton(_loc3_.getString("alliance.editbanner_ok"));
               _loc2_.open();
               return;
            }
            _loc2_ = new MessageBox(_loc3_.getString("alliance.editbanner_success"),null);
            _loc2_.addTitle(_loc3_.getString("alliance.editbanner_successTitle"),BaseDialogue.TITLE_COLOR_GREEN);
            _loc2_.addButton(_loc3_.getString("alliance.editbanner_ok"));
            _loc2_.open();
            close();
         });
      }
      
      private function onBannerChanged() : void
      {
         this.btn_save.enabled = this.ui_bannerEditor.hexString != this._orgBannerHex;
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:MessageBox = null;
         switch(param1.target)
         {
            case this.btn_cancel:
               close();
               break;
            case this.btn_save:
               if(this._chargedCost > this._network.playerData.compound.resources.getAmount(GameResources.CASH))
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen(true);
                  return;
               }
               _loc2_ = new MessageBox(this._lang.getString(this._chargedCost > 0 ? "alliance.editbanner_confirmMsg" : "alliance.editbanner_confirmMsgFree",NumberFormatter.format(this._actualItemCost,0)),null,true,true,1,380);
               _loc2_.addTitle(this._lang.getString("alliance.editbanner_confirmTitle"),BaseDialogue.TITLE_COLOR_BUY);
               _loc2_.addButton(this._lang.getString("alliance.editbanner_confirmCancel"));
               if(this._chargedCost > 0)
               {
                  _loc2_.addButton(this._lang.getString("alliance.editbanner_confirmYes"),true,{
                     "width":130,
                     "buttonClass":PurchasePushButton,
                     "cost":this._chargedCost
                  }).clicked.addOnce(this.save);
               }
               else
               {
                  _loc2_.addButton(this._lang.getString("alliance.editbanner_confirmYes"),true,{
                     "width":130,
                     "backgroundColor":Effects.BUTTON_GREEN
                  }).clicked.addOnce(this.save);
               }
               _loc2_.open();
         }
      }
      
      private function onAllianceClientRankChanged(param1:AllianceMember) : void
      {
         close();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         close();
      }
   }
}

