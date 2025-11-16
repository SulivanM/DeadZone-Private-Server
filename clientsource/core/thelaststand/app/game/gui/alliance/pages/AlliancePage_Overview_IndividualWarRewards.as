package thelaststand.app.game.gui.alliance.pages
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.UIAllianceIndividualRewardsProgressBar;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_Overview_IndividualWarRewards extends UIComponent
   {
      
      private var _width:int = 477;
      
      private var _height:int = 155;
      
      private var _padding:int = 3;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _resetTimer:Timer;
      
      private var _newRoundWaiting:Boolean = false;
      
      private var btn_help:HelpButton;
      
      private var ui_titleBar:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var mc_blocker:Sprite;
      
      private var ui_background:UIImage;
      
      private var txt_score:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_warpts:BodyTextField;
      
      private var txt_rollover:BodyTextField;
      
      private var progressBar:UIAllianceIndividualRewardsProgressBar;
      
      public function AlliancePage_Overview_IndividualWarRewards()
      {
         super();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.add(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.add(this.onAllianceRoundEnded);
         this.ui_titleBar = new UITitleBar(null,4205912);
         this.ui_titleBar.width = int(this._width - 6);
         this.ui_titleBar.height = 26;
         this.ui_titleBar.x = this.ui_titleBar.y = this._padding;
         addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "text":" ",
            "color":15188587,
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.text = Language.getInstance().getString("alliance.overview_indi_title").toUpperCase();
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         this.txt_title.x = int(this.txt_title.y + 2);
         addChild(this.txt_title);
         this.txt_time = new BodyTextField({
            "text":" ",
            "color":13945818,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_time.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_time.height) * 0.5);
         addChild(this.txt_time);
         this.btn_help = new HelpButton("alliance.indi_help");
         this.btn_help.height = 18;
         this.btn_help.scaleX = this.btn_help.scaleY;
         this.btn_help.x = int(this.txt_title.x + this.txt_title.width + 6);
         this.btn_help.y = int(this.txt_title.y + (this.txt_title.height - this.btn_help.height) * 0.5);
         addChild(this.btn_help);
         this.ui_background = new UIImage(469,118,2367017,1,false,"images/alliances/alliance_indioverview_bg.jpg");
         this.ui_background.x = this._padding;
         this.ui_background.y = int(this.ui_titleBar.y + this.ui_titleBar.height + this._padding);
         this.txt_score = new BodyTextField({
            "text":"0",
            "color":15527148,
            "size":36,
            "bold":true
         });
         this.txt_score.maxWidth = 74;
         this.txt_score.x = this.ui_background.x + 53;
         this.txt_warpts = new BodyTextField({
            "color":15527148,
            "size":12,
            "bold":false,
            "wordWrap":true,
            "multiline":true,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_warpts.htmlText = Language.getInstance().getString("alliance.overview_indi_warpoints");
         this.txt_warpts.x = this.ui_background.x + 127;
         this.txt_warpts.y = this.ui_background.y + 13;
         this.updateScore(0);
         this.txt_desc = new BodyTextField({
            "color":15527148,
            "size":14,
            "wordWrap":true,
            "multiline":true,
            "align":"center"
         });
         this.txt_desc.htmlText = Language.getInstance().getString("alliance.overview_indi_desc");
         this.txt_desc.width = 280;
         this.txt_desc.height = 40;
         this.txt_desc.x = this.ui_background.x + 177;
         this.txt_desc.y = this.ui_background.y + 9;
         this.txt_rollover = new BodyTextField({
            "color":7561354,
            "size":10,
            "bold":false,
            "multiline":false,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_rollover.htmlText = Language.getInstance().getString("alliance.overview_indi_rollover");
         this.txt_rollover.x = this.ui_background.x + (this.ui_background.width - this.txt_rollover.width) * 0.5;
         this.txt_rollover.y = this.ui_background.y + 100;
         this.progressBar = new UIAllianceIndividualRewardsProgressBar();
         this.progressBar.width = 447;
         this.progressBar.x = this.ui_background.x + 10;
         this.progressBar.y = this.ui_background.y + 56;
         addChild(this.ui_background);
         addChild(this.txt_score);
         addChild(this.txt_warpts);
         addChild(this.txt_desc);
         addChild(this.txt_rollover);
         addChild(this.progressBar);
         this._resetTimer = new Timer(60000);
         this._resetTimer.addEventListener(TimerEvent.TIMER,this.onResetTimerTick,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
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
         super.dispose();
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.remove(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.remove(this.onAllianceRoundEnded);
         this._allianceSystem = null;
         this._resetTimer.stop();
         this.ui_titleBar.dispose();
         this.txt_time.dispose();
         this.txt_title.dispose();
         this.txt_desc.dispose();
         this.txt_score.dispose();
         this.btn_help.dispose();
         this.txt_warpts.dispose();
         this.txt_rollover.dispose();
         this.progressBar.dispose();
         this.ui_background.dispose();
      }
      
      private function updateResetTime() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(AllianceSystem.getInstance().warActive == false)
         {
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_comingSoon");
         }
         else if(!this._allianceSystem.canContributeToRound)
         {
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_availnextround");
         }
         else if(this._newRoundWaiting)
         {
            _loc1_ = int((this._allianceSystem.round.activeTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_indi_available",DateTimeUtils.secondsToString(_loc1_,true,false,true).replace("<","&lt;"));
         }
         else
         {
            _loc2_ = int((this._allianceSystem.round.endTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc2_ <= 0)
            {
               _loc2_ = 0;
            }
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_indi_reset",DateTimeUtils.secondsToString(_loc2_,true,false,true).replace("<","&lt;"));
         }
         this.txt_time.x = int(this.ui_titleBar.x + this.ui_titleBar.width - this.txt_time.width - 2);
      }
      
      private function lock() : void
      {
         if(this.mc_blocker == null)
         {
            this.mc_blocker = new Sprite();
            this.mc_blocker.buttonMode = true;
            this.mc_blocker.useHandCursor = false;
         }
         this.mc_blocker.x = this.ui_background.x - 2;
         this.mc_blocker.y = this.ui_background.y - 2;
         this.mc_blocker.graphics.clear();
         this.mc_blocker.graphics.beginFill(0,0.8);
         this.mc_blocker.graphics.drawRect(0,0,this.ui_background.width + 4,this.ui_background.height + 4);
         this.mc_blocker.graphics.endFill();
         addChild(this.mc_blocker);
      }
      
      private function unlock() : void
      {
         if(this.mc_blocker == null)
         {
            return;
         }
         mouseChildren = true;
         if(this.mc_blocker.parent != null)
         {
            this.mc_blocker.parent.removeChild(this.mc_blocker);
         }
      }
      
      private function updateScore(param1:Number) : void
      {
         this.txt_score.text = param1.toString();
         this.txt_score.y = int(this.ui_background.y - this.txt_score.height * 0.5) + 30;
         this.txt_warpts.x = this.txt_score.x + this.txt_score.width + 4;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._resetTimer.start();
         this._newRoundWaiting = Network.getInstance().serverTime < this._allianceSystem.round.activeTime.time;
         var _loc2_:AllianceMember = AllianceSystem.getInstance().clientMember;
         var _loc3_:int = _loc2_ == null || this._newRoundWaiting ? 0 : int(_loc2_.points);
         this.updateScore(_loc3_);
         this.progressBar.SolidValue = _loc3_;
         this.updateResetTime();
         if(this._newRoundWaiting)
         {
            this.lock();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._resetTimer.stop();
      }
      
      private function onResetTimerTick(param1:TimerEvent) : void
      {
         this.updateResetTime();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         this._resetTimer.stop();
         this.lock();
      }
      
      private function onAllianceRoundStarted() : void
      {
         this._newRoundWaiting = false;
         this.updateResetTime();
         this.unlock();
      }
      
      private function onAllianceRoundEnded() : void
      {
         this._newRoundWaiting = true;
         this.updateResetTime();
         this.updateScore(0);
         this.lock();
      }
   }
}

