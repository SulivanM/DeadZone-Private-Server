package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceSummaryCache;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerPanelDisplay;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class AllianceInvitationDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _network:Network;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _allianceId:String;
      
      private var _inviterNickname:String;
      
      private var _channel:String;
      
      private var _spinner:UIBusySpinner;
      
      private var mc_container:Sprite = new Sprite();
      
      private var bannerPanel:AllianceBannerPanelDisplay;
      
      private var btn_accept:PushButton;
      
      private var btn_reject:PushButton;
      
      private var dlg_busyAccepting:BusyDialogue;
      
      private var _disposed:Boolean = false;
      
      public function AllianceInvitationDialogue(param1:String, param2:String, param3:String)
      {
         super("alliance-invite",this.mc_container,false);
         this._network = Network.getInstance();
         this._lang = Language.getInstance();
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceId = param1;
         this._inviterNickname = param2;
         this._channel = param3;
         _autoSize = false;
         _width = 260;
         _height = 435;
         addTitle(this._lang.getString("alliance.invite_title"),TITLE_COLOR_GREY);
         this.bannerPanel = new AllianceBannerPanelDisplay(null);
         this.mc_container.addChild(this.bannerPanel);
         this._spinner = new UIBusySpinner();
         this._spinner.x = int(this.bannerPanel.width * 0.5);
         this._spinner.y = int(this.bannerPanel.height * 0.5);
         this.mc_container.addChild(this._spinner);
         AllianceSummaryCache.getInstance().getSummary(param1,this.onSummaryLoaded);
         var _loc4_:int = _padding * 0.5;
         this.btn_accept = new PushButton(this._lang.getString("alliance.invite_acceptBtn"));
         this.btn_accept.clicked.add(this.onButtonClick);
         this.btn_accept.width = int((this.bannerPanel.width - 18) * 0.5);
         this.btn_accept.x = int(this.bannerPanel.x + 4);
         this.btn_accept.y = int(this.bannerPanel.y + this.bannerPanel.height + 10);
         this.btn_accept.backgroundColor = Effects.BUTTON_GREEN;
         this.mc_container.addChild(this.btn_accept);
         this.btn_reject = new PushButton(this._lang.getString("alliance.invite_rejectBtn"));
         this.btn_reject.clicked.add(this.onButtonClick);
         this.btn_reject.width = this.btn_accept.width;
         this.btn_reject.x = int(this.bannerPanel.x + this.bannerPanel.width - (this.btn_reject.width + 4));
         this.btn_reject.y = this.btn_accept.y;
         this.btn_reject.backgroundColor = Effects.BUTTON_WARNING_RED;
         this.mc_container.addChild(this.btn_reject);
      }
      
      override public function dispose() : void
      {
         this._disposed = true;
         super.dispose();
         this.btn_accept.dispose();
         this.btn_reject.dispose();
         this.bannerPanel.dispose();
         this._spinner.dispose();
         this._lang = null;
         this._network = null;
         this._allianceSystem.inviteResponseAccepted.remove(this.onInviteAccepted);
         this._allianceSystem.inviteResponseDeclined.remove(this.onInviteDeclined);
         this._allianceSystem.connectionFailed.remove(this.onInviteDeclined);
         this._allianceSystem.connected.remove(this.onAllianceSystemConnected);
         this._allianceSystem = null;
      }
      
      private function onSummaryLoaded(param1:AllianceDataSummary) : void
      {
         if(this._disposed)
         {
            return;
         }
         this._spinner.visible = false;
         if(param1 == null || param1.id != this._allianceId)
         {
            return;
         }
         this.bannerPanel.allianceData = param1;
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_reject:
               this._network.chatSystem.sendAllianceInviteResponse(this._inviterNickname,0,this._channel);
               close();
               break;
            case this.btn_accept:
               this.dlg_busyAccepting = new BusyDialogue(this._lang.getString("alliance.invite_joining"));
               this.dlg_busyAccepting.open();
               this._allianceSystem.inviteResponseAccepted.addOnce(this.onInviteAccepted);
               this._allianceSystem.inviteResponseDeclined.addOnce(this.onInviteDeclined);
               this._allianceSystem.connectionFailed.addOnce(this.onInviteDeclined);
               this._allianceSystem.acceptInvite(this._allianceId);
         }
      }
      
      private function onInviteAccepted() : void
      {
         AllianceSystem.getInstance().inviteResponseDeclined.remove(this.onInviteDeclined);
         AllianceSystem.getInstance().connected.addOnce(this.onAllianceSystemConnected);
         Network.getInstance().chatSystem.sendAllianceInviteResponse(this._inviterNickname,2,this._channel);
      }
      
      private function onInviteDeclined(param1:String = "") : void
      {
         var isFull:Boolean;
         var msgBody:String;
         var msg:MessageBox;
         var reason:String = param1;
         this.dlg_busyAccepting.close();
         AllianceSystem.getInstance().inviteResponseAccepted.remove(this.onInviteAccepted);
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnected);
         isFull = reason == "full";
         msgBody = "";
         switch(reason)
         {
            case "full":
               msgBody = Language.getInstance().getString("alliance.invite_joinErrorMessageFull");
               break;
            case "error":
            default:
               msgBody = Language.getInstance().getString("alliance.invite_joinErrorMessageGeneric");
         }
         msg = new MessageBox(msgBody,"joinError");
         msg.addTitle(Language.getInstance().getString("alliance.invite_joinErrorTitle"));
         msg.addButton(Language.getInstance().getString("alliance.invite_joinErrorOK"));
         msg.open();
         if(reason == "full")
         {
            msg.closed.addOnce(function(param1:Dialogue):void
            {
               Network.getInstance().chatSystem.sendAllianceInviteResponse(_inviterNickname,-3,_channel);
               close();
            });
         }
      }
      
      private function onAllianceSystemConnected() : void
      {
         this.dlg_busyAccepting.close();
         if(DialogueManager.getInstance().getDialogueById("allianceDialogue") == null)
         {
            new AllianceDialogue().open();
         }
         var _loc1_:String = "alliance.invite_joinSuccessMessage";
         if(this._allianceSystem.clientMember.joinDate.time > this._allianceSystem.round.activeTime.time)
         {
            _loc1_ = "alliance.invite_joinSuccessMessage_enlisting";
         }
         var _loc2_:MessageBox = new MessageBox(Language.getInstance().getString(_loc1_,this._allianceSystem.alliance.name),"joinSuccess");
         _loc2_.addTitle(Language.getInstance().getString("alliance.invite_joinSuccessTitle"),BaseDialogue.TITLE_COLOR_GREEN);
         _loc2_.addButton(Language.getInstance().getString("alliance.invite_joinSuccessOK"));
         _loc2_.open();
         close();
      }
   }
}

