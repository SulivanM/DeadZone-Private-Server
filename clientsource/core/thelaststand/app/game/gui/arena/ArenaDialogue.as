package thelaststand.app.game.gui.arena
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Global;
   import thelaststand.app.data.Currency;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.arena.ArenaSystem;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.raid.AssignmentAmmoView;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class ArenaDialogue extends BaseDialogue
   {
      
      private static const _rightColWidth:int = 214;
      
      private static const _navigation:Array = [{
         "id":"home",
         "width":86
      },{
         "id":"leaderboard",
         "width":120
      },{
         "id":"help",
         "width":100
      }];
      
      private var _bmdIcon:BitmapData;
      
      private var _session:ArenaSession;
      
      private var _currentPageId:String;
      
      private var _currentPage:ArenaDialoguePage;
      
      private var _navButtons:Vector.<PushButton>;
      
      private var _selectedNavButton:PushButton;
      
      private var _pages:Dictionary;
      
      private var mc_container:Sprite;
      
      private var btn_launch:PurchasePushButton;
      
      private var btn_bailout:PushButton;
      
      private var ui_ammo:AssignmentAmmoView;
      
      private var ui_survivors:ArenaSurvivorsView;
      
      private var ui_leaderPanel:ArenaLeaderboardPanelView;
      
      private var bmp_stripes:Bitmap;
      
      private var mc_pageHome:ArenaPageHome;
      
      private var mc_pageLeaderboard:ArenaPageLeaderboard;
      
      private var mc_pageHelp:ArenaPageHelp;
      
      public function ArenaDialogue(param1:*)
      {
         var i:int;
         var pageWidth:int;
         var pageHeight:int;
         var pageY:int;
         var stripePadding:int;
         var sessionName:String = null;
         var sessionData:ArenaSession = null;
         var btn_tx:int = 0;
         var data:Object = null;
         var label:String = null;
         var btn:PushButton = null;
         var nameOrSessionData:* = param1;
         if(nameOrSessionData is String)
         {
            sessionName = String(nameOrSessionData);
            sessionData = new ArenaSession();
            sessionData.setXML(ResourceManager.getInstance().getResource("xml/arenas.xml").content.arena.(@id == sessionName)[0]);
         }
         else if(nameOrSessionData is ArenaSession)
         {
            sessionData = ArenaSession(nameOrSessionData);
            sessionName = sessionData.name;
         }
         this.mc_container = new Sprite();
         super("arena-" + sessionName,this.mc_container,true,true);
         _autoSize = false;
         _width = 758;
         _height = 470;
         this._session = sessionData;
         this._session.survivorsChanged.add(this.onSurvivorsChanged);
         this._session.survivorLoadoutChanged.add(this.onSurvivorsChanged);
         this._bmdIcon = new BmpBountySkull();
         addTitle(Language.getInstance().getString("arena." + this._session.name + ".name"),BaseDialogue.TITLE_COLOR_GREY,-1,this._bmdIcon);
         this._navButtons = new Vector.<PushButton>(_navigation.length);
         i = 0;
         while(i < _navigation.length)
         {
            data = _navigation[i];
            label = Language.getInstance().getString("arena." + this._session.name + ".nav_" + data.id);
            if(!label || label == "?")
            {
               label = Language.getInstance().getString("arena.nav_" + data.id);
            }
            btn = new PushButton(label);
            btn.x = btn_tx;
            btn.y = int(_padding / 2);
            btn.width = data.width;
            btn.data = data.id;
            btn.clicked.add(this.onClickNavButton);
            btn_tx += int(btn.width + 14);
            this.mc_container.addChild(btn);
            this._navButtons[i] = btn;
            i++;
         }
         this._pages = new Dictionary(true);
         pageWidth = int(_width - _padding * 2 - _rightColWidth - 12);
         pageHeight = int(_height - _padding * 2 - this._navButtons[0].y - this._navButtons[0].height - _padding);
         pageY = int(this._navButtons[0].y + this._navButtons[0].height + 14);
         this.mc_pageHome = new ArenaPageHome(this._session);
         this.mc_pageHome.y = pageY;
         this.mc_pageHome.width = pageWidth;
         this.mc_pageHome.height = pageHeight;
         this._pages["home"] = this.mc_pageHome;
         this.mc_pageLeaderboard = new ArenaPageLeaderboard(this._session);
         this.mc_pageLeaderboard.y = pageY;
         this.mc_pageLeaderboard.width = pageWidth;
         this.mc_pageLeaderboard.height = pageHeight;
         this._pages["leaderboard"] = this.mc_pageLeaderboard;
         this.mc_pageHelp = new ArenaPageHelp(this._session);
         this.mc_pageHelp.y = pageY;
         this.mc_pageHelp.width = pageWidth;
         this.mc_pageHelp.height = pageHeight;
         this._pages["help"] = this.mc_pageHelp;
         this.ui_survivors = new ArenaSurvivorsView();
         this.ui_survivors.width = _rightColWidth;
         this.ui_survivors.height = 180;
         this.ui_survivors.x = int(_width - _padding * 2 - this.ui_survivors.width);
         this.ui_survivors.y = int(_padding / 2);
         this.ui_survivors.setData(this._session);
         this.mc_container.addChild(this.ui_survivors);
         this.ui_ammo = new AssignmentAmmoView();
         this.ui_ammo.setData(this._session);
         this.ui_ammo.width = _rightColWidth;
         this.ui_ammo.height = 34;
         this.ui_ammo.x = int(this.ui_survivors.x);
         this.ui_ammo.y = int(this.ui_survivors.y + this.ui_survivors.height + 6);
         this.mc_container.addChild(this.ui_ammo);
         this.ui_leaderPanel = new ArenaLeaderboardPanelView(this._session);
         this.ui_leaderPanel.width = _rightColWidth;
         this.ui_leaderPanel.height = 98;
         this.ui_leaderPanel.x = int(_width - _padding * 2 - this.ui_leaderPanel.width);
         this.ui_leaderPanel.y = int(this.ui_ammo.y + this.ui_ammo.height + 6);
         this.mc_container.addChild(this.ui_leaderPanel);
         this.btn_bailout = new PushButton(Language.getInstance().getString("arena.btn_bailout"),new BmpIconButtonClose(),Effects.COLOR_WARNING);
         this.btn_bailout.width = _rightColWidth - 8;
         this.btn_bailout.height = 34;
         this.btn_bailout.x = int(_width - _padding * 2 - this.btn_bailout.width - 4);
         this.btn_bailout.y = int(_height - _padding * 2 - this.btn_bailout.height - _padding / 2);
         this.btn_bailout.clicked.add(this.onClickBailOut);
         this.mc_container.addChild(this.btn_bailout);
         this.btn_launch = new PurchasePushButton(Language.getInstance().getString("arena.btn_launch"),0,true);
         this.btn_launch.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         this.btn_launch.currency = Currency.FUEL;
         this.btn_launch.width = this.btn_bailout.width;
         this.btn_launch.height = 40;
         this.btn_launch.x = int(this.btn_bailout.x);
         this.btn_launch.y = int(this.btn_bailout.y - this.btn_launch.height - 18);
         this.btn_launch.clicked.add(this.onClickLaunch);
         this.mc_container.addChild(this.btn_launch);
         stripePadding = 20;
         this.bmp_stripes = new Bitmap(new BmpMissionLaunchBG(),"auto",true);
         this.bmp_stripes.x = this.btn_launch.x - stripePadding;
         this.bmp_stripes.y = this.btn_launch.y - stripePadding;
         this.bmp_stripes.width = this.btn_launch.width + stripePadding * 2;
         this.bmp_stripes.height = this.btn_launch.height + stripePadding * 2;
         this.mc_container.addChildAt(this.bmp_stripes,0);
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
         this.gotoPage(_navigation[0].id);
         sprite.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         sprite.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         var _loc1_:PushButton = null;
         super.dispose();
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         for each(_loc1_ in this._navButtons)
         {
            _loc1_.dispose();
         }
         this._navButtons = null;
         this._bmdIcon.dispose();
         this._bmdIcon = null;
         this._session.survivorsChanged.remove(this.onSurvivorsChanged);
         this._session.survivorLoadoutChanged.remove(this.onSurvivorsChanged);
         this._session = null;
         this.ui_survivors.dispose();
         this.ui_leaderPanel.dispose();
         this.ui_ammo.dispose();
      }
      
      private function refresh() : void
      {
         this.btn_bailout.enabled = this._session.hasStarted;
         this.btn_launch.enabled = !this._session.isCompleted;
         if(!this._session.isCompleted && this._session.hasStarted)
         {
            this.btn_launch.label = Language.getInstance().getString("arena.btn_continue",this._session.currentStageIndex + 1);
            this.btn_launch.cost = 0;
            this.btn_launch.showIcon = false;
         }
         else
         {
            this.btn_launch.label = Language.getInstance().getString("arena.btn_launch");
            this.btn_launch.cost = this.computeCost();
            this.btn_launch.showIcon = true;
         }
         this.ui_ammo.setData(this._session);
         this.ui_ammo.redraw();
         this.updateLaunchButtonState();
      }
      
      private function updateLaunchButtonState() : void
      {
         var _loc3_:Survivor = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this._session.survivorIds.length < this._session.minSurvivorCount)
         {
            this.btn_launch.enabled = false;
            TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("arena.launch_tooltip_error_minsrv",this._session.minSurvivorCount),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
            return;
         }
         var _loc1_:Vector.<Survivor> = this._session.getSurvivorList();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            if(_loc3_.loadoutOffence.weapon.item == null)
            {
               this.btn_launch.enabled = false;
               TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("arena.launch_tooltip_error_minsrv",this._session.minSurvivorCount),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               return;
            }
            _loc2_++;
         }
         if(!this._session.hasStarted || this._session.currentStageIndex == 0)
         {
            _loc4_ = Network.getInstance().playerData.compound.resources.getAmount(GameResources.AMMUNITION);
            _loc5_ = MissionData.calculateAmmoCost(this._session.getSurvivorList());
            if(_loc4_ < _loc5_)
            {
               this.btn_launch.enabled = false;
               TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("arena.launch_tooltip_error_ammo"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               return;
            }
         }
         this.btn_launch.enabled = true;
         TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("arena.launch_tooltip"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
      }
      
      private function computeCost() : int
      {
         var _loc1_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         return this._session.getLaunchCost(_loc1_);
      }
      
      private function launch() : void
      {
         if(this._session == null || this._session.survivorIds.length <= 0)
         {
            return;
         }
         if(this._session.isCompleted)
         {
            return;
         }
         ArenaSystem.launchSession(this._session,function(param1:Boolean):void
         {
            if(param1)
            {
               close();
            }
         });
      }
      
      private function abandon() : void
      {
         if(!this._session.hasStarted || this._session.isCompleted)
         {
            return;
         }
         ArenaSystem.abortSession(this._session,function(param1:Boolean):void
         {
            if(param1)
            {
               close();
            }
         });
      }
      
      private function gotoPage(param1:String) : void
      {
         if(param1 == this._currentPageId)
         {
            return;
         }
         this._currentPageId = param1;
         if(this._selectedNavButton != null)
         {
            this._selectedNavButton.selected = false;
            this._selectedNavButton = null;
         }
         this._selectedNavButton = this.getNavButtonById(this._currentPageId);
         if(this._selectedNavButton != null)
         {
            this._selectedNavButton.selected = true;
         }
         if(this._currentPage != null)
         {
            if(this._currentPage.parent != null)
            {
               this._currentPage.parent.removeChild(this._currentPage);
            }
            this._currentPage = null;
         }
         this._currentPage = this._pages[this._currentPageId];
         if(this._currentPage != null)
         {
            this._currentPage.redraw();
            if(this._currentPage.parent != this.mc_container)
            {
               this.mc_container.addChild(this._currentPage);
            }
         }
      }
      
      private function getNavButtonById(param1:String) : PushButton
      {
         var _loc2_:PushButton = null;
         for each(_loc2_ in this._navButtons)
         {
            if(_loc2_.data == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.refresh();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onSurvivorsChanged() : void
      {
         this.ui_ammo.invalidate();
         this.updateLaunchButtonState();
      }
      
      private function onClickLaunch(param1:MouseEvent) : void
      {
         var cost:int = 0;
         var player:PlayerData = null;
         var msg:ArenaConfirmLaunchDialogue = null;
         var e:MouseEvent = param1;
         if(this._session.hasStarted)
         {
            this.launch();
         }
         else
         {
            cost = this.computeCost();
            player = Network.getInstance().playerData;
            if(player.compound.resources.getAmount(GameResources.CASH) < cost)
            {
               PaymentSystem.getInstance().openBuyCoinsScreen(true);
            }
            else
            {
               msg = new ArenaConfirmLaunchDialogue(cost);
               msg.onConfirm = function():void
               {
                  launch();
               };
               msg.open();
            }
         }
      }
      
      private function onClickBailOut(param1:MouseEvent) : void
      {
         var body:String = null;
         var msg:MessageBox = null;
         var e:MouseEvent = param1;
         if(this._session.hasStarted)
         {
            body = Language.getInstance().getString("arena.bail_message",Language.getInstance().getString("arena." + this._session.name + ".name"),NumberFormatter.format(this._session.points,0));
            msg = new MessageBox(body,"arena-bail-out",true,true);
            msg.addTitle(Language.getInstance().getString("arena.bail_title"),BaseDialogue.TITLE_COLOR_RUST);
            msg.addButton(Language.getInstance().getString("arena.bail_ok"),true).clicked.addOnce(function(param1:MouseEvent):void
            {
               var e:MouseEvent = param1;
               ArenaSystem.finishSession(_session,null,function(param1:Boolean):void
               {
                  var arenaEndedDlg:ArenaEndedDialogue = null;
                  var success:Boolean = param1;
                  if(success)
                  {
                     arenaEndedDlg = new ArenaEndedDialogue(_session);
                     arenaEndedDlg.closed.addOnce(function(param1:Dialogue):void
                     {
                        Global.completedAssignment = null;
                     });
                     arenaEndedDlg.open();
                     close();
                  }
               });
            });
            msg.addButton(Language.getInstance().getString("arena.bail_cancel"));
            msg.open();
         }
         else
         {
            close();
         }
      }
      
      private function onClickNavButton(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         this.gotoPage(String(_loc2_.data));
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         if(param1 == GameResources.AMMUNITION)
         {
            this.ui_ammo.invalidate();
            this.updateLaunchButtonState();
         }
      }
   }
}

