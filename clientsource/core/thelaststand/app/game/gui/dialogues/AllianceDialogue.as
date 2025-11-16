package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerPanelDisplay;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_About;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_Activity;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_Create;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_History;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_Members;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_Overview;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_Tasks;
   import thelaststand.app.game.gui.alliance.pages.AlliancePage_War;
   import thelaststand.app.game.gui.alliance.pages.IAlliancePage;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class AllianceDialogue extends BaseDialogue
   {
      
      public static const ID_OVERVIEW:String = "overview";
      
      public static const ID_TASKS:String = "tasks";
      
      public static const ID_MEMBERS:String = "members";
      
      public static const ID_ACTIVITY:String = "activity";
      
      public static const ID_WAR:String = "leaderboard";
      
      public static const ID_HISTORY:String = "history";
      
      public static const ID_ABOUT:String = "about";
      
      public static const ID_CREATE:String = "create";
      
      public static const NON_MEMBER_PAGES:Array = [ID_ABOUT,ID_WAR,ID_HISTORY,ID_CREATE];
      
      public static const MEMBER_PAGES:Array = [ID_OVERVIEW,ID_WAR,ID_TASKS,ID_MEMBERS,ID_ACTIVITY,ID_HISTORY];
      
      public static const NON_MEMBER_PAGES_NOWAR:Array = [ID_ABOUT,ID_CREATE];
      
      public static const MEMBER_PAGES_NOWAR:Array = [ID_OVERVIEW,ID_MEMBERS,ID_ACTIVITY,ID_ABOUT];
      
      private var _lang:Language;
      
      private var _tooltip:TooltipManager;
      
      private var _network:Network;
      
      private var _player:PlayerData;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _alliance:AllianceData;
      
      private var _pagesById:Dictionary = new Dictionary();
      
      private var btn_help:HelpButton;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_menu:AllianceDialogueMenu;
      
      private var page_container:Sprite;
      
      private var currentPage:Sprite;
      
      private var bannerContainer:Sprite;
      
      private var btn_edit:PushButton;
      
      public var ui_banner:AllianceBannerPanelDisplay;
      
      public function AllianceDialogue(param1:String = null)
      {
         super("allianceDialogue",this.mc_container,true);
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         this._network = Network.getInstance();
         this._allianceSystem = AllianceSystem.getInstance();
         _autoSize = false;
         _width = 750;
         _height = 480;
         addTitle(" ",BaseDialogue.TITLE_COLOR_GREY);
         this.updateTitleBar();
         this.ui_menu = new AllianceDialogueMenu(this._alliance != null);
         this.ui_menu.x = 4;
         this.ui_menu.y = 10;
         this.ui_menu.menuItemSelected.add(this.changePage);
         this.mc_container.addChild(this.ui_menu);
         this.bannerContainer = new Sprite();
         this.page_container = new Sprite();
         this.page_container.y = int(this.ui_menu.y + 34);
         this.mc_container.addChild(this.page_container);
         this.changePage(param1 || this.ui_menu.selected);
         this._allianceSystem.connected.add(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.add(this.onRoundStarted);
         this._allianceSystem.roundEnded.add(this.onRoundEnded);
         this.btn_help = new HelpButton("alliance.alliance_help");
         this.btn_help.x = int(_width - _padding * 2 - this.btn_help.width);
         this.btn_help.y = 6;
         this.mc_container.addChild(this.btn_help);
         sprite.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         sprite.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         sprite.addEventListener("allianceLeaderboard",this.onAllianceLeaderboardRequested,false,0,true);
         if(this._allianceSystem.alliance != null)
         {
            this.onAllianceSystemConnected();
         }
      }
      
      public static function getButtonList(param1:Boolean) : Array
      {
         if(AllianceSystem.getInstance().warActive)
         {
            return param1 ? MEMBER_PAGES : NON_MEMBER_PAGES;
         }
         return param1 ? MEMBER_PAGES_NOWAR : NON_MEMBER_PAGES_NOWAR;
      }
      
      override public function dispose() : void
      {
         var _loc1_:String = null;
         var _loc2_:IAlliancePage = null;
         super.dispose();
         sprite.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         sprite.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this._lang = null;
         this._tooltip = null;
         this._network = null;
         this._allianceSystem.connected.remove(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.remove(this.onRoundStarted);
         this._allianceSystem.roundEnded.remove(this.onRoundEnded);
         this._allianceSystem = null;
         this._alliance = null;
         for(_loc1_ in this._pagesById)
         {
            _loc2_ = this._pagesById[_loc1_];
            _loc2_.dispose();
         }
         this._pagesById = null;
         this.btn_help.dispose();
         this.ui_menu.dispose();
         if(this.ui_banner != null)
         {
            this.ui_banner.dispose();
         }
         if(this.btn_edit != null)
         {
            this.btn_edit.dispose();
         }
      }
      
      override public function open() : void
      {
         super.open();
         if(AllianceDialogState.getInstance().allianceDialogReturnType != AllianceDialogState.SHOW_NONE)
         {
            this.showPage(AllianceDialogue.ID_WAR);
         }
      }
      
      public function showPage(param1:String) : void
      {
         if(AllianceDialogue.getButtonList(this.ui_menu.memberMode).indexOf(param1) == -1)
         {
            return;
         }
         this.changePage(param1);
      }
      
      public function showBanner() : void
      {
         if(!this.ui_banner)
         {
            this.refreshBanner();
         }
         this.mc_container.addChildAt(this.bannerContainer,this.mc_container.getChildIndex(this.page_container));
      }
      
      public function refreshBanner() : void
      {
         if(this.ui_banner)
         {
            this.ui_banner.dispose();
            this.ui_banner = null;
         }
         if(this.btn_edit)
         {
            this.btn_edit.dispose();
            this.btn_edit = null;
         }
         this.ui_banner = new AllianceBannerPanelDisplay(this._alliance,this._allianceSystem.isFounder ? AllianceBannerPanelDisplay.LAYOUT_DIALOGUE_ADMIN : AllianceBannerPanelDisplay.LAYOUT_DIALOGUE);
         this.ui_banner.x = this.page_container.x;
         this.ui_banner.y = this.page_container.y;
         this.bannerContainer.addChild(this.ui_banner);
         if(this._allianceSystem.clientMember != null && this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.EditBanner))
         {
            this.btn_edit = new PushButton(this._lang.getString("alliance.editbanner_editBtn"));
            this.btn_edit.backgroundColor = Effects.BUTTON_GREEN;
            this.btn_edit.clicked.add(this.onButtonClicked);
            this.btn_edit.x = 4;
            this.btn_edit.y = int(this.ui_banner.y + this.ui_banner.height + 5);
            this.btn_edit.width = int(this.ui_banner.width - this.btn_edit.x * 2);
            this.bannerContainer.addChild(this.btn_edit);
         }
      }
      
      private function changePage(param1:String) : void
      {
         var _loc2_:Sprite = null;
         if(this._pagesById[param1])
         {
            _loc2_ = this._pagesById[param1];
         }
         else
         {
            switch(param1)
            {
               case ID_ABOUT:
                  _loc2_ = new AlliancePage_About();
                  break;
               case ID_CREATE:
                  _loc2_ = new AlliancePage_Create();
                  break;
               case ID_WAR:
                  _loc2_ = new AlliancePage_War();
                  break;
               case ID_MEMBERS:
                  _loc2_ = new AlliancePage_Members();
                  break;
               case ID_OVERVIEW:
                  _loc2_ = new AlliancePage_Overview();
                  break;
               case ID_TASKS:
                  _loc2_ = new AlliancePage_Tasks();
                  break;
               case ID_ACTIVITY:
                  _loc2_ = new AlliancePage_Activity();
                  break;
               case ID_HISTORY:
                  _loc2_ = new AlliancePage_History();
            }
            this._pagesById[param1] = _loc2_;
            IAlliancePage(_loc2_).dialogue = this;
         }
         this.ui_menu.selected = param1;
         if(_loc2_ != this.currentPage)
         {
            if(this.bannerContainer.parent)
            {
               this.bannerContainer.parent.removeChild(this.bannerContainer);
            }
            if(Boolean(this.currentPage) && Boolean(this.currentPage.parent))
            {
               this.currentPage.parent.removeChild(this.currentPage);
            }
            if(_loc2_)
            {
               this.page_container.addChild(_loc2_);
            }
            this.currentPage = _loc2_;
         }
      }
      
      private function updateTitleBar() : void
      {
         var _loc1_:String = null;
         if(this._alliance != null)
         {
            _loc1_ = (this._alliance.name + " " + this._alliance.tagBracketed).toUpperCase();
            if(this._allianceSystem.isEnlisting)
            {
               _loc1_ += " <font color=\'#A2A2A2\'>[" + this._lang.getString("alliance.enlisting").toUpperCase() + "]</font>";
            }
            if(Network.getInstance().playerData.compound.globalEffects.hasEffectType(EffectType.getTypeValue("DisableAlliancePvP")))
            {
               _loc1_ += " <font color=\'#B70000\'>[" + this._lang.getString("alliance.disabledPvP").toUpperCase() + "]</font>";
            }
            txt_title.htmlText = _loc1_;
         }
         else
         {
            txt_title.text = this._lang.getString("alliance.windowTitle");
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateTitleBar();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onRoundStarted() : void
      {
         this.updateTitleBar();
         this.ui_menu.updatelayout();
      }
      
      private function onRoundEnded() : void
      {
         this.ui_menu.updatelayout();
      }
      
      private function onAllianceSystemConnected() : void
      {
         var _loc3_:String = null;
         if(Boolean(this._alliance) && Boolean(this._alliance.banner))
         {
            this._alliance.banner.onChange.remove(this.onBannerUpdate);
         }
         this._alliance = this._allianceSystem.alliance;
         if(this._alliance == null)
         {
            this.onAllianceSystemDisconnected();
            return;
         }
         var _loc1_:Array = AllianceDialogue.getButtonList(false);
         var _loc2_:Array = AllianceDialogue.getButtonList(false);
         for each(_loc3_ in _loc1_)
         {
            if(_loc2_.indexOf(_loc3_) <= -1)
            {
               if(this._pagesById[_loc3_] != null)
               {
                  IAlliancePage(this._pagesById[_loc3_]).dispose();
                  delete this._pagesById[_loc3_];
               }
            }
         }
         if(this.ui_banner != null)
         {
            this.ui_banner.allianceData = this._alliance;
         }
         if(this._alliance.banner)
         {
            this._alliance.banner.onChange.add(this.onBannerUpdate);
         }
         this.ui_menu.memberMode = true;
         this.changePage(this.ui_menu.selected);
         this.updateTitleBar();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         var _loc3_:String = null;
         if(Boolean(this._alliance) && Boolean(this._alliance.banner))
         {
            this._alliance.banner.onChange.remove(this.onBannerUpdate);
         }
         this._alliance = null;
         var _loc1_:Array = AllianceDialogue.getButtonList(false);
         var _loc2_:Array = AllianceDialogue.getButtonList(false);
         for each(_loc3_ in _loc2_)
         {
            if(this._pagesById[_loc3_] != null)
            {
               if(_loc1_.indexOf(_loc3_) <= -1)
               {
                  IAlliancePage(this._pagesById[_loc3_]).dispose();
                  delete this._pagesById[_loc3_];
               }
            }
         }
         this.ui_menu.memberMode = false;
         this.changePage(this.ui_menu.selected);
         this.updateTitleBar();
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_edit:
               new AllianceBannerEditDialogue().open();
         }
      }
      
      private function onAllianceLeaderboardRequested(param1:Event) : void
      {
         this.changePage(ID_WAR);
      }
      
      private function onBannerUpdate() : void
      {
         this.ui_banner.allianceData = this._alliance;
      }
   }
}

import flash.display.Sprite;
import flash.events.MouseEvent;
import org.osflash.signals.Signal;
import thelaststand.app.data.PlayerData;
import thelaststand.app.game.data.alliance.AllianceSystem;
import thelaststand.app.game.gui.notification.UINotificationCount;
import thelaststand.app.gui.buttons.PushButton;
import thelaststand.app.network.Network;
import thelaststand.common.lang.Language;

class AllianceDialogueMenu extends Sprite
{
   
   private var _btns:Array = [];
   
   private var _memberMode:Boolean;
   
   private var _selected:String;
   
   private var _allianceSystem:AllianceSystem;
   
   public var menuItemSelected:Signal = new Signal(String);
   
   private var ui_uncollectedWinningsNotification:UINotificationCount;
   
   private var ui_newMessageNotification:UINotificationCount;
   
   private var playerData:PlayerData;
   
   public function AllianceDialogueMenu(param1:Boolean)
   {
      super();
      this._memberMode = param1;
      this.ui_newMessageNotification = new UINotificationCount();
      this.ui_newMessageNotification.label = "0";
      this.ui_uncollectedWinningsNotification = new UINotificationCount(622336);
      this.ui_uncollectedWinningsNotification.label = "1";
      this.updatelayout();
      this.playerData = Network.getInstance().playerData;
      this.playerData.uncollectedWinningsChanged.add(this.updateUncollectedWinnings);
      this.updateUncollectedWinnings();
   }
   
   public function dispose() : void
   {
      var _loc1_:PushButton = null;
      for each(_loc1_ in this._btns)
      {
         _loc1_.dispose();
      }
      this._btns = null;
      this.menuItemSelected.removeAll();
      this.menuItemSelected = null;
      if(this._allianceSystem.alliance)
      {
         this._allianceSystem.alliance.messages.unreadMessageCountChange.remove(this.updateNewMessageNotification);
      }
      this.ui_newMessageNotification.dispose();
      this._allianceSystem = null;
      this.ui_uncollectedWinningsNotification.dispose();
      this.playerData.uncollectedWinningsChanged.remove(this.updateUncollectedWinnings);
      this.playerData = null;
   }
   
   public function updatelayout() : void
   {
      var _loc1_:PushButton = null;
      var _loc2_:PushButton = null;
      var _loc6_:String = null;
      for each(_loc1_ in this._btns)
      {
         _loc1_.dispose();
      }
      this._btns.length = 0;
      if(this.ui_uncollectedWinningsNotification.parent)
      {
         this.ui_uncollectedWinningsNotification.parent.removeChild(this.ui_uncollectedWinningsNotification);
      }
      if(this.ui_newMessageNotification.parent)
      {
         this.ui_newMessageNotification.parent.removeChild(this.ui_newMessageNotification);
      }
      var _loc3_:int = AllianceSystem.getInstance().round.number;
      var _loc4_:Array = AllianceDialogue.getButtonList(this._memberMode);
      var _loc5_:int = 0;
      while(_loc5_ < _loc4_.length)
      {
         _loc6_ = _loc4_[_loc5_];
         if(!(_loc6_ == AllianceDialogue.ID_HISTORY && _loc3_ < 1))
         {
            if(!(_loc6_ == AllianceDialogue.ID_WAR && _loc3_ < 0))
            {
               _loc1_ = this.createButton(_loc6_);
               _loc1_.x = _loc2_ == null ? 0 : _loc2_.x + _loc2_.width + 15;
               this._btns.push(_loc1_);
               addChild(_loc1_);
               switch(_loc6_)
               {
                  case AllianceDialogue.ID_HISTORY:
                     this.ui_uncollectedWinningsNotification.x = _loc1_.x + _loc1_.width;
                     addChild(this.ui_uncollectedWinningsNotification);
                     break;
                  case AllianceDialogue.ID_ACTIVITY:
                     this.ui_newMessageNotification.x = _loc1_.x + _loc1_.width;
                     addChild(this.ui_newMessageNotification);
               }
               _loc2_ = _loc1_;
            }
         }
         _loc5_++;
      }
      if(_loc4_.indexOf(this._selected) > -1)
      {
         this.selected = this._selected;
      }
      else
      {
         this.selected = _loc4_[0];
      }
      this._allianceSystem = AllianceSystem.getInstance();
      if(this._allianceSystem.alliance != null)
      {
         this._allianceSystem.alliance.messages.unreadMessageCountChange.remove(this.updateNewMessageNotification);
         if(this._memberMode)
         {
            this._allianceSystem.alliance.messages.unreadMessageCountChange.add(this.updateNewMessageNotification);
         }
      }
      this.updateNewMessageNotification(0);
   }
   
   private function createButton(param1:String) : PushButton
   {
      var _loc2_:PushButton = new PushButton(Language.getInstance().getString("alliance.menu_" + param1));
      _loc2_.width = 98;
      _loc2_.data = param1;
      _loc2_.clicked.add(this.onButtonClicked);
      return _loc2_;
   }
   
   private function updateUncollectedWinnings() : void
   {
      this.ui_uncollectedWinningsNotification.visible = this.playerData.uncollectedWinnings;
   }
   
   private function updateNewMessageNotification(param1:int = 0) : void
   {
      var _loc2_:int = 0;
      if(this._allianceSystem.alliance)
      {
         _loc2_ = int(this._allianceSystem.alliance.messages.unreadMessageCount);
      }
      this.ui_newMessageNotification.label = _loc2_.toString();
      this.ui_newMessageNotification.visible = _loc2_ > 0;
   }
   
   private function onButtonClicked(param1:MouseEvent) : void
   {
      var _loc2_:PushButton = PushButton(param1.target);
      this.menuItemSelected.dispatch(String(_loc2_.data));
   }
   
   public function get selected() : String
   {
      return this._selected;
   }
   
   public function set selected(param1:String) : void
   {
      var _loc2_:PushButton = null;
      for each(_loc2_ in this._btns)
      {
         if(_loc2_.data == param1)
         {
            _loc2_.selected = true;
         }
         else if(_loc2_.selected)
         {
            _loc2_.selected = false;
         }
      }
      this._selected = param1;
   }
   
   public function get memberMode() : Boolean
   {
      return this._memberMode;
   }
   
   public function set memberMode(param1:Boolean) : void
   {
      if(param1 == this._memberMode)
      {
         return;
      }
      this._memberMode = param1;
      this.updatelayout();
   }
}
