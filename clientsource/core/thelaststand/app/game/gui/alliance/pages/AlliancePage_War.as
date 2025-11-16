package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.alliance.AllianceMemberLeaderboard;
   import thelaststand.app.game.gui.alliance.AllianceTargetAllianceListPanel;
   import thelaststand.app.game.gui.alliance.AllianceTargetIndividualsListPanel;
   import thelaststand.app.game.gui.alliance.UIAllianceWarBanner;
   import thelaststand.app.game.gui.alliance.leaderboard.AllianceLeaderboardList;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.game.gui.dialogues.AllianceOpponentMemberListDialogue;
   import thelaststand.app.game.gui.dialogues.AllianceViewMemberListDialogue;
   import thelaststand.app.game.gui.tab.TabBar;
   import thelaststand.app.game.gui.tab.TabBarButton;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_War extends Sprite implements IAlliancePage
   {
      
      private var _dialogue:AllianceDialogue;
      
      private var warBanner:UIAllianceWarBanner;
      
      private var tabBarLeft:TabBar;
      
      private var tab_top100:TabBarButton;
      
      private var tab_members:TabBarButton;
      
      private var tabBarRight:TabBar;
      
      private var tab_targetAlliances:TabBarButton;
      
      private var tab_targetIndividuals:TabBarButton;
      
      private var _lang:Language = Language.getInstance();
      
      private var _allianceSystem:AllianceSystem = AllianceSystem.getInstance();
      
      private var currentPage:Sprite;
      
      private var ui_leaderboard:AllianceLeaderboardList;
      
      private var ui_targetAlliancesList:AllianceTargetAllianceListPanel;
      
      private var ui_targetIndividualsList:AllianceTargetIndividualsListPanel;
      
      private var ui_memberlist:AllianceMemberLeaderboard;
      
      private var btn_help:HelpButton;
      
      private var _tooltips:TooltipManager;
      
      public function AlliancePage_War()
      {
         super();
         this.warBanner = new UIAllianceWarBanner();
         addChild(this.warBanner);
         var _loc1_:int = Network.getInstance().serverTime >= this._allianceSystem.round.activeTime.time ? this._allianceSystem.round.number : this._allianceSystem.round.number - 1;
         var _loc2_:int = 0;
         if(AllianceDialogState.getInstance().allianceDialogReturnType == AllianceDialogState.SHOW_TOP_100)
         {
            _loc2_ = AllianceDialogState.getInstance().alliancePage;
         }
         this.ui_leaderboard = new AllianceLeaderboardList(_loc1_,_loc2_);
         this.ui_leaderboard.x = this.warBanner.x + this.warBanner.width + 10;
         this.ui_leaderboard.y = this.warBanner.y + 23;
         addChild(this.ui_leaderboard);
         this.currentPage = this.ui_leaderboard;
         this.tabBarLeft = new TabBar();
         this.tabBarLeft.x = this.ui_leaderboard.x + 2;
         this.tabBarLeft.y = this.ui_leaderboard.y - (this.tabBarLeft.height - 1);
         this.tabBarLeft.onChange.add(this.onTabBarChange);
         addChild(this.tabBarLeft);
         this.tab_top100 = new TabBarButton("top100",this._lang.getString("alliance.warpage_tab_top100",_loc1_));
         this.tab_members = new TabBarButton("members","[---]");
         this.tabBarLeft.addButton(this.tab_top100);
         this.tabBarRight = new TabBar(TabBar.ALIGN_RIGHT);
         this.tabBarRight.x = this.ui_leaderboard.x + this.ui_leaderboard.width - 2;
         this.tabBarRight.y = this.tabBarLeft.y;
         this.tabBarRight.onChange.add(this.onTabBarChange);
         this.tab_targetAlliances = new TabBarButton("targetAlliances",this._lang.getString("alliance.warpage_tab_targetAlliances"),{
            "icon":new BmpIconAllianceTarget(),
            "iconOffsetX":-2,
            "iconOffsetY":-1,
            "iconSpace":-2
         });
         this.tab_targetIndividuals = new TabBarButton("targetIndividuals",this._lang.getString("alliance.warpage_tab_targetIndividuals"),{
            "icon":new BmpIconAllianceTarget(),
            "iconOffsetX":-2,
            "iconOffsetY":-1,
            "iconSpace":-2
         });
         this.tabBarRight.addButton(this.tab_targetIndividuals);
         this.tabBarLeft.selected = this.tab_top100;
         this._tooltips = TooltipManager.getInstance();
         this._tooltips.add(this.tab_top100,this._lang.getString("alliance.warpage_tooltip_top100"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltips.add(this.tab_members,this._lang.getString("alliance.warpage_tooltip_members"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_help = new HelpButton("alliance.war_help");
         this.btn_help.height = 28;
         this.btn_help.scaleX = this.btn_help.scaleY;
         this.btn_help.x = int(this.ui_leaderboard.x);
         this.btn_help.y = int(this.warBanner.y + this.warBanner.height - this.btn_help.height - 1);
         addChild(this.btn_help);
         this._allianceSystem.connected.add(this.onAllianceConnected);
         this._allianceSystem.disconnected.add(this.onAllianceDisconnected);
         this._allianceSystem.roundEnded.add(this.onRoundEnded);
         this._allianceSystem.roundStarted.add(this.onRoundStarted);
         if(this._allianceSystem.isConnected)
         {
            this.onAllianceConnected();
         }
         if(AllianceDialogState.getInstance().allianceDialogReturnType != AllianceDialogState.SHOW_NONE)
         {
            addEventListener(Event.ADDED_TO_STAGE,this.handleDialogReturn,false,0,true);
         }
      }
      
      private function handleDialogReturn(param1:Event) : void
      {
         var _loc3_:AllianceOpponentMemberListDialogue = null;
         var _loc4_:AllianceViewMemberListDialogue = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.handleDialogReturn);
         var _loc2_:AllianceDialogState = AllianceDialogState.getInstance();
         if(_loc2_.allianceDialogReturnType == AllianceDialogState.SHOW_ALLIANCE_DIALOG)
         {
            this.onTabBarChange("targetAlliances");
            if(this.ui_targetAlliancesList != null)
            {
               this.ui_targetAlliancesList.defaultPageNum = _loc2_.alliancePage;
            }
            _loc3_ = new AllianceOpponentMemberListDialogue(_loc2_.allianceId,_loc2_.allianceName,_loc2_.allianceTag);
            _loc3_.open();
         }
         if(_loc2_.allianceDialogReturnType == AllianceDialogState.SHOW_TOP_100)
         {
            this.onTabBarChange("top100");
            _loc4_ = new AllianceViewMemberListDialogue(_loc2_.allianceId,_loc2_.allianceName,_loc2_.allianceTag);
            _loc4_.open();
         }
         if(_loc2_.allianceDialogReturnType == AllianceDialogState.SHOW_INDIVIDUALS)
         {
            this.onTabBarChange("targetIndividuals");
         }
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.warBanner.dispose();
         this.tabBarLeft.dispose(false);
         this.tabBarRight.dispose();
         this.btn_help.dispose();
         this.tab_members.dispose();
         this.tab_targetAlliances.dispose();
         this.tab_targetIndividuals.dispose();
         this.tab_top100.dispose();
         if(this.ui_leaderboard)
         {
            this.ui_leaderboard.dispose();
            this.ui_leaderboard = null;
         }
         if(this.ui_memberlist)
         {
            this.ui_memberlist.dispose();
            this.ui_memberlist = null;
         }
         this._dialogue = null;
         this._lang = null;
         this._tooltips.remove(this.tab_top100);
         this._tooltips.remove(this.tab_members);
         this._tooltips.remove(this.tab_targetAlliances);
         this._tooltips.remove(this.tab_targetIndividuals);
         this._tooltips = null;
         this._allianceSystem.connected.remove(this.onAllianceConnected);
         this._allianceSystem.disconnected.remove(this.onAllianceDisconnected);
         this._allianceSystem.roundEnded.remove(this.onRoundEnded);
         this._allianceSystem.roundStarted.remove(this.onRoundStarted);
         this._allianceSystem = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.handleDialogReturn);
      }
      
      private function onTabBarChange(param1:String) : void
      {
         if(param1 == "")
         {
            return;
         }
         if(this.currentPage.parent)
         {
            this.currentPage.parent.removeChild(this.currentPage);
         }
         switch(param1)
         {
            case "top100":
               this.tabBarRight.selected = null;
               this.currentPage = this.ui_leaderboard;
               break;
            case "members":
               this.tabBarRight.selected = null;
               if(this.ui_memberlist == null)
               {
                  this.ui_memberlist = new AllianceMemberLeaderboard(this.ui_leaderboard.round);
                  this.ui_memberlist.x = this.ui_leaderboard.x;
                  this.ui_memberlist.y = this.ui_leaderboard.y;
               }
               this.currentPage = this.ui_memberlist;
               break;
            case "targetAlliances":
               this.tabBarLeft.selected = null;
               if(this.ui_targetAlliancesList == null)
               {
                  this.ui_targetAlliancesList = new AllianceTargetAllianceListPanel();
                  this.ui_targetAlliancesList.x = this.ui_leaderboard.x;
                  this.ui_targetAlliancesList.y = this.ui_leaderboard.y;
               }
               this.currentPage = this.ui_targetAlliancesList;
               break;
            case "targetIndividuals":
               this.tabBarLeft.selected = null;
               if(this.ui_targetIndividualsList == null)
               {
                  this.ui_targetIndividualsList = new AllianceTargetIndividualsListPanel();
                  this.ui_targetIndividualsList.x = this.ui_leaderboard.x;
                  this.ui_targetIndividualsList.y = this.ui_leaderboard.y;
               }
               this.currentPage = this.ui_targetIndividualsList;
         }
         if(this.currentPage != null)
         {
            addChildAt(this.currentPage,0);
         }
      }
      
      private function onTabClicked(param1:MouseEvent) : void
      {
         var _loc2_:TabBarButton = TabBarButton(param1.target);
         _loc2_.selected = true;
         this.onTabBarChange(_loc2_.id);
      }
      
      private function onAllianceConnected() : void
      {
         if(this._allianceSystem.alliance == null)
         {
            return;
         }
         this.tab_members.label = this._allianceSystem.alliance.tagBracketed;
         this.tabBarLeft.addButton(this.tab_members);
         addChild(this.tabBarRight);
         this.updateTargetTabButtons();
         this.tabBarLeft.selected = this.tab_top100;
      }
      
      private function onAllianceDisconnected() : void
      {
         this.tabBarLeft.removeButton(this.tab_members);
         if(this.tabBarRight.parent)
         {
            this.tabBarRight.parent.removeChild(this.tabBarRight);
         }
         if(this.ui_targetAlliancesList)
         {
            this.ui_targetAlliancesList.dispose();
            this.ui_targetAlliancesList = null;
         }
         if(this.ui_targetIndividualsList)
         {
            this.ui_targetIndividualsList.dispose();
            this.ui_targetIndividualsList = null;
         }
         if(this.ui_memberlist)
         {
            this.ui_memberlist.dispose();
            this.ui_memberlist = null;
         }
         this.tabBarLeft.selected = this.tab_top100;
      }
      
      private function onRoundStarted() : void
      {
         var _loc1_:int = this._allianceSystem.round.number;
         this.tab_top100.label = this._lang.getString("alliance.warpage_tab_top100",_loc1_);
         if(this.ui_leaderboard)
         {
            this.ui_leaderboard.round = _loc1_;
         }
         if(this.ui_memberlist)
         {
            this.ui_memberlist.round = _loc1_;
         }
         this.updateTargetTabButtons();
      }
      
      private function onRoundEnded() : void
      {
         this.updateTargetTabButtons();
      }
      
      private function updateTargetTabButtons() : void
      {
         var _loc1_:* = this.tabBarRight.selected == null;
         var _loc2_:Boolean = this._allianceSystem.canContributeToRound;
         var _loc3_:* = Network.getInstance().serverTime >= this._allianceSystem.round.activeTime.time;
         var _loc4_:Boolean = Network.getInstance().playerData.compound.globalEffects.hasEffectType(EffectType.getTypeValue("DisableAlliancePvP"));
         this._tooltips.remove(this.tab_targetAlliances);
         this._tooltips.remove(this.tab_targetIndividuals);
         if(_loc2_ && _loc3_ && !_loc4_)
         {
            this.tab_targetAlliances.enabled = true;
            this._tooltips.add(this.tab_targetAlliances,this._lang.getString("alliance.warpage_tooltip_targetAlliances"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            this.tab_targetIndividuals.enabled = true;
            this._tooltips.add(this.tab_targetIndividuals,this._lang.getString("alliance.warpage_tooltip_targetIndividuals"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
         else
         {
            this.tab_targetAlliances.enabled = false;
            this._tooltips.add(this.tab_targetAlliances,this._lang.getString(_loc4_ ? "alliance.warpage_tooltip_targetsLockdown" : "alliance.warpage_tooltip_targetsDisabled"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            this.tab_targetIndividuals.enabled = false;
            this._tooltips.add(this.tab_targetIndividuals,this._lang.getString(_loc4_ ? "alliance.warpage_tooltip_targetsLockdown" : "alliance.warpage_tooltip_targetsDisabled"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
         if(_loc1_)
         {
            this.tabBarLeft.selected = this.tab_top100;
         }
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

