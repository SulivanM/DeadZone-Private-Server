package thelaststand.app.game.gui.arena
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.gui.tab.TabBar;
   import thelaststand.app.game.gui.tab.TabBarButton;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class ArenaPageLeaderboard extends ArenaDialoguePage
   {
      
      private var _rows:Vector.<ArenaLeaderboardRow> = new Vector.<ArenaLeaderboardRow>();
      
      private var _rowPool:Vector.<ArenaLeaderboardRow> = new Vector.<ArenaLeaderboardRow>();
      
      private var _leaderboards:Dictionary = new Dictionary(true);
      
      private var _disposed:Boolean;
      
      private var _resetTime:Date;
      
      private var _resetTimer:Timer;
      
      private var _currentLeaderboardId:String;
      
      private var _requesting:Boolean;
      
      private var _pageOffset:int = 0;
      
      private var _rowsPerPage:int = 6;
      
      private var _rowHeight:int = 47;
      
      private var ui_pagination:UIPagination;
      
      private var mc_leaderboard:Sprite;
      
      private var txt_reset:BodyTextField;
      
      private var ui_tabs:TabBar;
      
      private var ui_tab_thisWeek:TabBarButton;
      
      private var ui_tab_lastWeek:TabBarButton;
      
      private var ui_busy:UIBusySpinner;
      
      private var ui_header:ArenaLeaderboardHeaderRow;
      
      public function ArenaPageLeaderboard(param1:ArenaSession)
      {
         super(param1);
         this._resetTimer = new Timer(1000 * 60);
         this._resetTimer.addEventListener(TimerEvent.TIMER,this.onResetTimerTick,false,0,true);
         this.mc_leaderboard = new Sprite();
         addChild(this.mc_leaderboard);
         this.ui_header = new ArenaLeaderboardHeaderRow();
         this.mc_leaderboard.addChild(this.ui_header);
         this.ui_busy = new UIBusySpinner();
         this.ui_busy.visible = false;
         this.mc_leaderboard.addChild(this.ui_busy);
         this.ui_tab_thisWeek = new TabBarButton("thisweek",Language.getInstance().getString("arena.leaderboard_thisweek"));
         this.ui_tab_thisWeek.minWidth = 126;
         this.ui_tab_lastWeek = new TabBarButton("lastweek",Language.getInstance().getString("arena.leaderboard_lastweek"));
         this.ui_tabs = new TabBar();
         this.ui_tabs.addButton(this.ui_tab_thisWeek);
         this.ui_tabs.addButton(this.ui_tab_lastWeek);
         this.ui_tabs.onChange.add(this.onTabBarChange);
         addChild(this.ui_tabs);
         this.ui_pagination = new UIPagination();
         this.ui_pagination.changed.add(this.onPageChanged);
         addChild(this.ui_pagination);
         this.txt_reset = new BodyTextField({
            "color":11972784,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_reset.htmlText = " ";
         addChild(this.txt_reset);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         var _loc1_:ArenaLeaderboardRow = null;
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         super.dispose();
         this.txt_reset.dispose();
         this.ui_busy.dispose();
         this.ui_pagination.dispose();
         this.ui_tabs.dispose();
         this.ui_tab_thisWeek.dispose();
         this.ui_tab_lastWeek.dispose();
         this.ui_header.dispose();
         for each(_loc1_ in this._rowPool)
         {
            _loc1_.dispose();
         }
         for each(_loc1_ in this._rows)
         {
            _loc1_.dispose();
         }
      }
      
      override protected function draw() : void
      {
         this.updateResetTime();
         this.ui_pagination.x = int((width - this.ui_pagination.width) / 2);
         this.ui_pagination.y = int(height - this.ui_pagination.height);
         this.mc_leaderboard.y = 34;
         var _loc1_:int = this.ui_pagination.y - 16 - this.mc_leaderboard.y;
         this.mc_leaderboard.graphics.clear();
         GraphicUtils.drawUIBlock(this.mc_leaderboard.graphics,width,_loc1_);
         this.ui_tabs.x = 2;
         this.ui_tabs.y = int(this.mc_leaderboard.y - this.ui_tabs.height) + 1;
         this.txt_reset.x = int(width - this.txt_reset.width);
         this.txt_reset.y = int(this.mc_leaderboard.y - this.txt_reset.height);
         this.ui_busy.x = int(this.mc_leaderboard.width / 2);
         this.ui_busy.y = int(this.mc_leaderboard.height / 2);
         this.ui_header.x = this.ui_header.y = 3;
         this.ui_header.width = int(width - this.ui_header.x * 2);
         this.ui_header.height = 26;
      }
      
      private function computeTotalPages() : int
      {
         this._rowsPerPage = Math.floor(height / this._rowHeight);
         var _loc1_:int = _session.minLevel;
         var _loc2_:int = int(Config.constant.MAX_SURVIVOR_LEVEL);
         var _loc3_:int = _loc2_ - _loc1_;
         return int(Math.ceil(_loc3_ / this._rowsPerPage));
      }
      
      private function loadAndDisplayLeaderboard(param1:String) : void
      {
         var type:String = param1;
         if(this._currentLeaderboardId == type && this._requesting)
         {
            return;
         }
         this.returnRows();
         this.ui_busy.visible = true;
         this.ui_pagination.mouseChildren = false;
         this._currentLeaderboardId = type;
         this.loadLeaderboard(type,function(param1:Object):void
         {
            if(_disposed || _currentLeaderboardId != type)
            {
               return;
            }
            var _loc2_:int = _session.minLevel;
            var _loc3_:int = int(Config.constant.MAX_SURVIVOR_LEVEL);
            var _loc4_:int = _loc3_ - _loc2_;
            var _loc5_:int = Math.ceil(_loc4_ / _rowsPerPage);
            ui_pagination.mouseChildren = true;
            ui_pagination.numPages = _loc5_;
            displayLeaderboard(param1);
            invalidate();
         });
      }
      
      private function loadLeaderboard(param1:String, param2:Function = null) : void
      {
         var request:Object = null;
         var type:String = param1;
         var callback:Function = param2;
         if(this._leaderboards.hasOwnProperty(type))
         {
            if(callback != null)
            {
               callback(this._leaderboards[type]);
            }
            return;
         }
         this._requesting = true;
         request = {
            "name":_session.name,
            "type":type
         };
         Network.getInstance().save(request,SaveDataMethod.ARENA_LEADERBOARD,function(param1:Object):void
         {
            var _loc2_:Object = null;
            _requesting = false;
            if(_disposed)
            {
               return;
            }
            if(param1 == null || param1.success == false)
            {
               _loc2_ = processLeaderboardData({});
            }
            else
            {
               _loc2_ = processLeaderboardData(param1.data);
            }
            _leaderboards[request.type] = _loc2_;
            _resetTime = new Date(param1.reset);
            _resetTime.minutes -= _resetTime.getTimezoneOffset();
            updateResetTime();
            if(callback != null)
            {
               callback(_loc2_);
            }
         });
      }
      
      private function processLeaderboardData(param1:Object) : Object
      {
         var _loc5_:Object = null;
         var _loc2_:int = _session.minLevel;
         var _loc3_:int = int(Config.constant.MAX_SURVIVOR_LEVEL);
         var _loc4_:int = _loc2_;
         while(_loc4_ <= _loc3_)
         {
            _loc5_ = param1[_loc4_.toString()];
            if(_loc5_ == null)
            {
               _loc5_ = {};
               param1[_loc4_.toString()] = _loc5_;
            }
            _loc5_.level = _loc4_;
            _loc4_++;
         }
         return param1;
      }
      
      private function displayLeaderboard(param1:Object) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:ArenaLeaderboardRow = null;
         this.returnRows();
         this.ui_busy.visible = false;
         var _loc2_:int = 3;
         var _loc3_:int = 0;
         var _loc4_:int = _loc2_ + this.ui_header.height;
         var _loc5_:int = _session.minLevel;
         var _loc6_:int = int(Config.constant.MAX_SURVIVOR_LEVEL);
         var _loc7_:int = 0;
         while(_loc7_ < this._rowsPerPage)
         {
            _loc8_ = _loc6_ - (_loc7_ + this._pageOffset * this._rowsPerPage);
            if(_loc8_ < _loc5_)
            {
               break;
            }
            _loc9_ = param1 != null ? param1[_loc8_.toString()] : null;
            _loc10_ = this.getRow();
            _loc10_.alternate = _loc7_ % 2 == 0;
            _loc10_.data = _loc9_;
            _loc10_.width = int(width - _loc2_ * 2);
            _loc10_.height = this._rowHeight;
            _loc10_.x = _loc2_;
            _loc10_.y = _loc4_;
            _loc4_ += int(_loc10_.height + _loc3_);
            this.mc_leaderboard.addChild(_loc10_);
            _loc7_++;
         }
      }
      
      private function getRow() : ArenaLeaderboardRow
      {
         var _loc1_:ArenaLeaderboardRow = null;
         if(this._rowPool.length > 0)
         {
            _loc1_ = this._rowPool.pop();
         }
         else
         {
            _loc1_ = new ArenaLeaderboardRow();
         }
         this._rows.push(_loc1_);
         return _loc1_;
      }
      
      private function returnRows() : void
      {
         var _loc1_:ArenaLeaderboardRow = null;
         for each(_loc1_ in this._rows)
         {
            if(_loc1_.parent != null)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
            this._rowPool.push(_loc1_);
         }
         this._rows.length = 0;
      }
      
      private function updateResetTime() : void
      {
         if(this._resetTime == null)
         {
            this.txt_reset.htmlText = "";
            return;
         }
         var _loc1_:Date = new Date();
         var _loc2_:int = (this._resetTime.time - _loc1_.time) / 1000;
         var _loc3_:String = DateTimeUtils.secondsToString(_loc2_,true,false,true);
         this.txt_reset.htmlText = Language.getInstance().getString("arena.leaderboard_refresh_time",_loc3_);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.ui_tabs.selectedIndex = 0;
         this._resetTimer.start();
         this.loadAndDisplayLeaderboard(this.ui_tabs.selectedId);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._resetTimer.stop();
      }
      
      private function onResetTimerTick(param1:TimerEvent) : void
      {
         this.updateResetTime();
      }
      
      private function onTabBarChange(param1:String) : void
      {
         this._pageOffset = 0;
         this.ui_pagination.changed.remove(this.onPageChanged);
         this.ui_pagination.currentPage = 0;
         this.ui_pagination.changed.add(this.onPageChanged);
         this.loadAndDisplayLeaderboard(param1);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this._pageOffset = param1;
         this.loadAndDisplayLeaderboard(this._currentLeaderboardId);
      }
   }
}

