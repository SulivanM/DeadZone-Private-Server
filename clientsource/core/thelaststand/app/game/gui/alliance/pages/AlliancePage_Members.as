package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.game.gui.dialogues.AllianceRankDialogue;
   import thelaststand.app.game.gui.lists.UIAllianceMemberList;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_Members extends Sprite implements IAlliancePage
   {
      
      private var _lang:Language;
      
      private var _network:Network;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _dialogue:AllianceDialogue;
      
      private var _disposed:Boolean;
      
      private var ui_memberList:UIAllianceMemberList;
      
      private var ui_memberPage:UIPagination;
      
      private var btn_disband:PushButton;
      
      private var btn_ranks:PushButton;
      
      private var btn_help:HelpButton;
      
      public function AlliancePage_Members()
      {
         super();
         this._allianceSystem = AllianceSystem.getInstance();
         this._lang = Language.getInstance();
         this._network = Network.getInstance();
         this.ui_memberList = new UIAllianceMemberList();
         this.ui_memberList.width = 722;
         this.ui_memberList.height = 370;
         addChild(this.ui_memberList);
         this.ui_memberPage = new UIPagination(this.ui_memberList.numPages,0);
         this.ui_memberPage.x = int(this.ui_memberList.x + (this.ui_memberList.width - this.ui_memberPage.width) * 0.5);
         this.ui_memberPage.y = this.ui_memberList.y + this.ui_memberList.height + 10;
         this.ui_memberPage.changed.add(this.onMemberListPageChanged);
         addChild(this.ui_memberPage);
         this.btn_ranks = new PushButton(this._lang.getString("alliance.viewrank_btnPreview"));
         this.btn_ranks.width = 160;
         this.btn_ranks.x = int(this.ui_memberList.x + this.ui_memberList.width - this.btn_ranks.width - 2);
         this.btn_ranks.y = int(this.ui_memberList.y + this.ui_memberList.height + 10);
         this.btn_ranks.clicked.add(this.onRankButtonClicked);
         addChild(this.btn_ranks);
         this.btn_help = new HelpButton("alliance.members_help");
         this.btn_help.x = 0;
         this.btn_help.y = int(this.btn_ranks.y + (this.btn_ranks.height - this.btn_help.height) * 0.5);
         addChild(this.btn_help);
         this.btn_disband = new PushButton(this._lang.getString("alliance.disband_btn"));
         this.btn_disband.backgroundColor = Effects.BUTTON_WARNING_RED;
         this.btn_disband.width = 120;
         this.btn_disband.x = int(this.btn_help.x + this.btn_help.width + 30);
         this.btn_disband.y = this.ui_memberList.y + this.ui_memberList.height + 10;
         this.btn_disband.clicked.add(this.disbandAlliancePart1);
         if(this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.Disband))
         {
            addChild(this.btn_disband);
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         if(parent)
         {
            parent.removeChild(this);
         }
         this._allianceSystem = null;
         this._lang = null;
         this._network = null;
         this._dialogue = null;
         this.ui_memberList.dispose();
         this.ui_memberPage.dispose();
         this.btn_ranks.dispose();
         this.btn_help.dispose();
         this.btn_disband.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function onMemberRankChanged(param1:AllianceMember) : void
      {
         if(param1.id == Network.getInstance().playerData.id)
         {
            if(this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.Disband))
            {
               addChild(this.btn_disband);
            }
            else if(this.btn_disband.parent)
            {
               this.btn_disband.parent.removeChild(this.btn_disband);
            }
         }
      }
      
      private function onRankButtonClicked(param1:MouseEvent) : void
      {
         new AllianceRankDialogue(AllianceRankDialogue.MODE_PREVIEW_RANKS).open();
      }
      
      private function disbandAlliancePart1(param1:MouseEvent) : void
      {
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("alliance.disband_warn1_message"),null,true);
         _loc2_.addTitle(this._lang.getString("alliance.disband_warn1_title"));
         _loc2_.addButton(this._lang.getString("alliance.disband_cancel"));
         _loc2_.addButton(this._lang.getString("alliance.disband_warn1_ok"),true,{"backgroundColor":Effects.BUTTON_WARNING_RED}).clicked.addOnce(this.disbandAlliancePart2);
         _loc2_.open();
      }
      
      private function disbandAlliancePart2(param1:MouseEvent = null) : void
      {
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("alliance.disband_warn2_message"),null,true,true,100,240);
         _loc2_.addTitle(this._lang.getString("alliance.disband_warn2_title"));
         _loc2_.addButton(this._lang.getString("alliance.disband_cancel"));
         _loc2_.addButton(this._lang.getString("alliance.disband_warn2_ok"),true,{"backgroundColor":Effects.BUTTON_WARNING_RED}).clicked.addOnce(this.disbandAlliancePart3);
         _loc2_.open();
      }
      
      private function disbandAlliancePart3(param1:MouseEvent = null) : void
      {
         var busyDlg:BusyDialogue = null;
         var e:MouseEvent = param1;
         busyDlg = new BusyDialogue(this._lang.getString("alliance.disband_busy"));
         busyDlg.open();
         this._allianceSystem.disbandAlliance(function(param1:RPCResponse):void
         {
            var _loc3_:MessageBox = null;
            busyDlg.close();
            if(_disposed)
            {
               return;
            }
            var _loc2_:Language = Language.getInstance();
            if(!param1.success)
            {
               _loc3_ = new MessageBox(_loc2_.getString("alliance.disband_fail"));
               _loc3_.addTitle(_loc2_.getString("alliance.disband_failTitle"),BaseDialogue.TITLE_COLOR_RUST);
            }
            else
            {
               _loc3_ = new MessageBox(_loc2_.getString("alliance.disband_success"));
               _loc3_.addTitle(_loc2_.getString("alliance.disband_successTitle"),BaseDialogue.TITLE_COLOR_GREEN);
               _dialogue.refreshBanner();
            }
            _loc3_.addButton(_loc2_.getString("alliance.disband_ok"));
            _loc3_.open();
         });
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._allianceSystem.alliance != null)
         {
            this.ui_memberList.members = this._allianceSystem.alliance.members;
            this.onMembersChanged(null);
            this._allianceSystem.alliance.members.memberRankChanged.add(this.onMemberRankChanged);
            this._allianceSystem.alliance.members.memberAdded.add(this.onMembersChanged);
            this._allianceSystem.alliance.members.memberRemoved.add(this.onMembersChanged);
            this._allianceSystem.alliance.rankNameChanged.add(this.onRankNameChanged);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         if(this._allianceSystem.alliance != null)
         {
            this._allianceSystem.alliance.members.memberRankChanged.remove(this.onMemberRankChanged);
            this._allianceSystem.alliance.members.memberAdded.remove(this.onMembersChanged);
            this._allianceSystem.alliance.members.memberRemoved.remove(this.onMembersChanged);
            this._allianceSystem.alliance.rankNameChanged.remove(this.onRankNameChanged);
         }
      }
      
      private function onMemberListPageChanged(param1:int) : void
      {
         this.ui_memberList.gotoPage(param1);
      }
      
      private function onMembersChanged(param1:AllianceMember) : void
      {
         this.ui_memberPage.numPages = this.ui_memberList.numPages;
         this.ui_memberPage.x = int(this.ui_memberList.x + (this.ui_memberList.width - this.ui_memberPage.width) * 0.5);
      }
      
      private function onRankNameChanged(param1:int) : void
      {
         this.ui_memberList.refreshAllRanks();
      }
      
      public function get dialogue() : AllianceDialogue
      {
         return this._dialogue;
      }
      
      public function set dialogue(param1:AllianceDialogue) : void
      {
         this._dialogue = param1;
      }
   }
}

