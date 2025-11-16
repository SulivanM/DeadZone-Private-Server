package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.alliance.AllianceMessageBoard;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.game.gui.dialogues.AllianceMessageCreateDialogue;
   import thelaststand.app.game.gui.lists.UIAllianceEnemyList;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_Activity extends Sprite implements IAlliancePage
   {
      
      private var _dialogue:AllianceDialogue;
      
      private var _allianceSystem:AllianceSystem;
      
      private var btn_new:PushButton;
      
      private var newMsgDialogue:AllianceMessageCreateDialogue;
      
      private var ui_messageBoard:AllianceMessageBoard;
      
      private var ui_enemyList:UIAllianceEnemyList;
      
      private var ui_enemyPage:UIPagination;
      
      private var txt_comingSoon:BodyTextField;
      
      public function AlliancePage_Activity()
      {
         super();
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.alliance.members.memberRankChanged.add(this.onMemberRankChanged);
         this.ui_messageBoard = new AllianceMessageBoard();
         this.ui_messageBoard.x = 0;
         addChild(this.ui_messageBoard);
         this.btn_new = new PushButton(Language.getInstance().getString("alliance.messages_btnNew"));
         this.btn_new.clicked.add(this.onButtonClicked);
         this.btn_new.x = int(this.ui_messageBoard.x + this.ui_messageBoard.width - this.btn_new.width - 5);
         this.btn_new.y = int(this.ui_messageBoard.y + this.ui_messageBoard.height + 10);
         this.ui_enemyList = new UIAllianceEnemyList();
         this.ui_enemyList.width = 240;
         this.ui_enemyList.height = 368;
         this.ui_enemyList.x = int(this.ui_messageBoard.x + this.ui_messageBoard.width + 10);
         addChild(this.ui_enemyList);
         this.ui_enemyList.launchEnabled = this._allianceSystem.canContributeToRound && Network.getInstance().playerData.compound.globalEffects.hasEffectType(EffectType.getTypeValue("DisableAlliancePvP")) == false;
         this.ui_enemyPage = new UIPagination(this.ui_enemyList.numPages,0);
         this.ui_enemyPage.x = int(this.ui_enemyList.x + (this.ui_enemyList.width - this.ui_enemyPage.width) * 0.5);
         this.ui_enemyPage.y = int(this.ui_enemyList.y + this.ui_enemyList.height + 10);
         this.ui_enemyPage.changed.add(this.onEnemyListPageChanged);
         addChild(this.ui_enemyPage);
         if(this._allianceSystem.warActive == false || this._allianceSystem.round.number < 1)
         {
            this.txt_comingSoon = new BodyTextField({
               "color":15066597,
               "size":14,
               "bold":true,
               "filters":[Effects.TEXT_SHADOW]
            });
            this.txt_comingSoon.htmlText = Language.getInstance().getString("alliance.overview_comingSoon").toUpperCase();
            this.txt_comingSoon.x = this.ui_enemyList.x + (this.ui_enemyList.width - this.txt_comingSoon.width) * 0.5;
            this.txt_comingSoon.y = this.ui_enemyList.y + (this.ui_enemyList.height - this.txt_comingSoon.height) * 0.5;
            addChild(this.txt_comingSoon);
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this._allianceSystem.alliance != null)
         {
            this._allianceSystem.alliance.enemies.changed.remove(this.onEnemyListChanged);
            this._allianceSystem.alliance.members.memberRankChanged.remove(this.onMemberRankChanged);
         }
         this._allianceSystem = null;
         this._dialogue = null;
         this.ui_messageBoard.dispose();
         this.ui_enemyList.dispose();
         this.ui_enemyPage.dispose();
         this.btn_new.dispose();
         if(this.newMsgDialogue != null)
         {
            this.newMsgDialogue.close();
            this.newMsgDialogue = null;
         }
         if(this.txt_comingSoon)
         {
            this.txt_comingSoon.dispose();
            this.txt_comingSoon = null;
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function onMemberRankChanged(param1:AllianceMember) : void
      {
         if(param1.id == Network.getInstance().playerData.id)
         {
            if(this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.PostMessages))
            {
               addChild(this.btn_new);
            }
            else if(this.btn_new.parent)
            {
               this.btn_new.parent.removeChild(this.btn_new);
            }
            this.ui_messageBoard.forceRefresh();
         }
      }
      
      private function update() : void
      {
         if(this._allianceSystem.inAlliance && this._allianceSystem.isConnected)
         {
            if(this._allianceSystem.alliance != null)
            {
               this.ui_messageBoard.messages = this._allianceSystem.alliance.messages;
               this.ui_enemyList.allianceList = this._allianceSystem.alliance.enemies;
               this._allianceSystem.alliance.enemies.changed.add(this.onEnemyListChanged);
               this.onEnemyListChanged();
            }
            if(this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.PostMessages))
            {
               addChild(this.btn_new);
            }
         }
         else
         {
            this.ui_messageBoard.messages = null;
            this.ui_enemyList.allianceList = null;
            this.ui_enemyPage.numPages = 0;
            if(this.btn_new.parent != null)
            {
               this.btn_new.parent.removeChild(this.btn_new);
            }
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._allianceSystem.connected.add(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this.update();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._allianceSystem.connected.remove(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_new:
               this.newMsgDialogue = new AllianceMessageCreateDialogue();
               this.newMsgDialogue.closed.addOnce(this.onNewDialogueClosed);
               this.newMsgDialogue.open();
         }
      }
      
      private function onEnemyListPageChanged(param1:int) : void
      {
         this.ui_enemyList.gotoPage(param1);
      }
      
      private function onEnemyListChanged() : void
      {
         this.ui_enemyPage.numPages = this.ui_enemyList.numPages;
         this.ui_enemyPage.x = int(this.ui_enemyList.x + (this.ui_enemyList.width - this.ui_enemyPage.width) * 0.5);
      }
      
      private function onNewDialogueClosed(param1:AllianceMessageCreateDialogue) : void
      {
         this.newMsgDialogue = null;
      }
      
      private function onAllianceSystemConnected() : void
      {
         this.update();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         this.update();
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

