package thelaststand.app.game.gui.alliance.pages
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_Overview_Scores extends UIComponent
   {
      
      private var _allianceSystem:AllianceSystem;
      
      private var _panelWidth:int = 234;
      
      private var _panelHeight:int = 94;
      
      private var _roundTimer:Timer;
      
      private var _newRoundWaiting:Boolean = false;
      
      private var _animDummy:Object = {
         "tokens":0,
         "score":0
      };
      
      private var ui_roundScore:Sprite;
      
      private var ui_roundScore_bg:UIImage;
      
      private var txt_roundScore_title:BodyTextField;
      
      private var txt_roundScore_score:BodyTextField;
      
      private var txt_roundScore_time:BodyTextField;
      
      private var btn_roundWar:PushButton;
      
      private var btn_tokenHelp:HelpButton;
      
      private var ui_tokens:Sprite;
      
      private var ui_tokens_bg:UIImage;
      
      private var txt_tokens_title:BodyTextField;
      
      private var txt_tokens_amount:BodyTextField;
      
      private var warActive:Boolean = AllianceSystem.getInstance().warActive;
      
      public function AlliancePage_Overview_Scores()
      {
         super();
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.disconnected.addOnce(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.add(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.add(this.onAllianceRoundEnded);
         this._allianceSystem.alliance.tokensChanged.add(this.onAllianceTokensChanged);
         this._allianceSystem.alliance.pointsChanged.add(this.onAllianceScoreChanged);
         this.ui_roundScore = new Sprite();
         this.ui_tokens = new Sprite();
         this.drawRoundScore();
         this.drawTokens();
         this.ui_roundScore.x = 0;
         this.ui_roundScore.y = 0;
         addChild(this.ui_roundScore);
         this.ui_tokens.x = int(this.ui_roundScore.x + this._panelWidth + 9);
         this.ui_tokens.y = int(this.ui_roundScore.y);
         addChild(this.ui_tokens);
         this._roundTimer = new Timer(60000);
         this._roundTimer.addEventListener(TimerEvent.TIMER,this.onRoundTimerTick,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TweenMax.killTweensOf(this._animDummy);
         this._roundTimer.stop();
         if(this._allianceSystem.alliance != null)
         {
            this._allianceSystem.alliance.tokensChanged.remove(this.onAllianceTokensChanged);
            this._allianceSystem.alliance.pointsChanged.remove(this.onAllianceScoreChanged);
         }
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.remove(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.remove(this.onAllianceRoundEnded);
         this._allianceSystem = null;
         this.txt_roundScore_score.dispose();
         this.txt_roundScore_time.dispose();
         this.txt_roundScore_title.dispose();
         this.txt_tokens_amount.dispose();
         this.txt_tokens_title.dispose();
         this.ui_roundScore_bg.dispose();
         this.ui_tokens_bg.dispose();
         this.btn_tokenHelp.dispose();
      }
      
      private function drawRoundScore() : void
      {
         GraphicUtils.drawUIBlock(this.ui_roundScore.graphics,this._panelWidth,this._panelHeight);
         this.ui_roundScore_bg = new UIImage(225,this._panelHeight - 6,0,0,false,"images/ui/alliance-war-bg.jpg");
         this.ui_roundScore_bg.x = this.ui_roundScore_bg.y = 3;
         this.ui_roundScore.addChild(this.ui_roundScore_bg);
         this.txt_roundScore_title = new BodyTextField({
            "color":15066597,
            "size":12,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_roundScore_title.htmlText = Language.getInstance().getString("alliance.overview_round_score_title",this._allianceSystem.round.number).toUpperCase();
         this.txt_roundScore_title.x = 68;
         this.txt_roundScore_title.y = 8;
         this.ui_roundScore.addChild(this.txt_roundScore_title);
         this.txt_roundScore_score = new BodyTextField({
            "color":16053492,
            "size":(this.warActive ? 36 : 15),
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_roundScore_score.htmlText = "0";
         this.txt_roundScore_score.x = int(this.txt_roundScore_title.x - 3);
         this.txt_roundScore_score.y = int(47 - this.txt_roundScore_score.height * 0.5);
         this.ui_roundScore.addChild(this.txt_roundScore_score);
         this.txt_roundScore_score.maxWidth = 96;
         this.txt_roundScore_time = new BodyTextField({
            "color":9737364,
            "size":11,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_roundScore_time.htmlText = "0";
         this.txt_roundScore_time.x = int(this.txt_roundScore_title.x);
         this.txt_roundScore_time.y = 71;
         if(this.warActive && this._allianceSystem.round.number > 0)
         {
            this.ui_roundScore.addChild(this.txt_roundScore_time);
         }
         this.btn_roundWar = new PushButton(null,new BmpIconAllianceWAR());
         this.btn_roundWar.width = 52;
         this.btn_roundWar.height = 46;
         this.btn_roundWar.x = int(this._panelWidth - this.btn_roundWar.width - 12);
         this.btn_roundWar.y = int((this._panelHeight - this.btn_roundWar.height) * 0.5);
         this.btn_roundWar.clicked.add(this.onWarClicked);
         this.ui_roundScore.addChild(this.btn_roundWar);
         this.btn_roundWar.enabled = this.warActive && AllianceSystem.getInstance().round.number > 0;
      }
      
      private function drawTokens() : void
      {
         GraphicUtils.drawUIBlock(this.ui_tokens.graphics,this._panelWidth,this._panelHeight);
         this.ui_tokens_bg = new UIImage(225,this._panelHeight - 6,0,0,false,"images/ui/alliance-tokens-bg.jpg");
         this.ui_tokens_bg.x = this.ui_tokens_bg.y = 3;
         this.ui_tokens.addChild(this.ui_tokens_bg);
         this.txt_tokens_title = new BodyTextField({
            "color":12655360,
            "size":12,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_tokens_title.htmlText = Language.getInstance().getString("alliance.overview_tokens_title").toUpperCase();
         this.txt_tokens_title.x = 78;
         this.txt_tokens_title.y = 8;
         this.ui_tokens.addChild(this.txt_tokens_title);
         this.txt_tokens_amount = new BodyTextField({
            "color":16053492,
            "size":36,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_tokens_amount.htmlText = "0";
         this.txt_tokens_amount.x = int(this.txt_tokens_title.x - 3);
         this.txt_tokens_amount.y = int(47 - this.txt_tokens_amount.height * 0.5);
         this.ui_tokens.addChild(this.txt_tokens_amount);
         this.btn_tokenHelp = new HelpButton("alliance.token_help");
         this.btn_tokenHelp.height = 18;
         this.btn_tokenHelp.scaleX = this.btn_tokenHelp.scaleY;
         this.btn_tokenHelp.x = int(this.ui_tokens_bg.x + this.ui_tokens_bg.width - this.btn_tokenHelp.width);
         this.btn_tokenHelp.y = int(this.ui_tokens_bg.y + 2);
         this.ui_tokens.addChild(this.btn_tokenHelp);
      }
      
      private function updateRoundEndTime() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!this.warActive || this._allianceSystem.round.number < 1)
         {
            this.txt_roundScore_title.htmlText = Language.getInstance().getString("alliance.overview_round_score_title",Math.max(this._allianceSystem.round.number,0)).toUpperCase();
            return;
         }
         if(this._newRoundWaiting)
         {
            _loc1_ = int((this._allianceSystem.round.activeTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
            if(this.txt_roundScore_time.visible)
            {
               this.txt_roundScore_title.htmlText = Language.getInstance().getString("alliance.overview_round_score_comp_title").toUpperCase();
               this.txt_roundScore_time.textColor = 16763904;
               this.txt_roundScore_time.htmlText = Language.getInstance().getString("alliance.overview_round_starts",DateTimeUtils.secondsToString(_loc1_,true,false,true).replace("<","&lt;"));
            }
         }
         else
         {
            _loc2_ = int((this._allianceSystem.round.endTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            if(this.txt_roundScore_time.visible)
            {
               this.txt_roundScore_title.htmlText = Language.getInstance().getString("alliance.overview_round_score_title",Math.max(this._allianceSystem.round.number,1)).toUpperCase();
               this.txt_roundScore_time.textColor = 9737364;
               this.txt_roundScore_time.htmlText = Language.getInstance().getString("alliance.overview_round_ends",DateTimeUtils.secondsToString(_loc2_,true,false,true).replace("<","&lt;"));
            }
         }
      }
      
      private function updateTokenCount() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc1_:int = this._allianceSystem.alliance != null ? this._allianceSystem.alliance.tokens : 0;
         if(this.stage == null)
         {
            this._animDummy.tokens = _loc1_;
            this.updateTokenCountDisplay();
         }
         else
         {
            _loc2_ = Math.abs(_loc1_ - this._animDummy.tokens);
            _loc3_ = Math.min(int(_loc2_ / 10) * 0.01,3);
            TweenMax.to(this._animDummy,_loc3_,{
               "tokens":_loc1_,
               "ease":Quad.easeOut,
               "onUpdate":this.updateTokenCountDisplay
            });
         }
      }
      
      private function updateTokenCountDisplay() : void
      {
         var _loc1_:String = NumberFormatter.format(this._animDummy.tokens,0);
         _loc1_ = _loc1_.replace(/,/ig,"<font size=\'18\'>,</font>");
         this.txt_tokens_amount.htmlText = _loc1_;
         this.txt_tokens_amount.x = this.txt_tokens_amount.width < this.txt_tokens_title.width ? int(this.txt_tokens_title.x + (this.txt_tokens_title.width - this.txt_tokens_amount.width) * 0.5) : int(this.txt_tokens_title.x - 1);
      }
      
      private function updateRoundScore() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc1_:int = this._allianceSystem.alliance != null ? this._allianceSystem.alliance.points : 0;
         if(this.stage == null)
         {
            this._animDummy.score = _loc1_;
            this.updateRoundScoreDisplay();
         }
         else
         {
            _loc2_ = Math.abs(_loc1_ - this._animDummy.score);
            _loc3_ = Math.min(int(_loc2_ / 10) * 0.01,3);
            TweenMax.to(this._animDummy,_loc3_,{
               "score":_loc1_,
               "ease":Quad.easeOut,
               "onUpdate":this.updateRoundScoreDisplay
            });
         }
      }
      
      private function updateRoundScoreDisplay() : void
      {
         if(!this.warActive)
         {
            this.txt_roundScore_score.multiline = true;
            this.txt_roundScore_score.htmlText = Language.getInstance().getString("alliance.overview_comingSoon");
            return;
         }
         var _loc1_:int = this._allianceSystem.alliance.points;
         var _loc2_:String = NumberFormatter.format(this._animDummy.score,0);
         _loc2_ = _loc2_.replace(/,/ig,"<font size=\'18\'>,</font>");
         this.txt_roundScore_score.htmlText = _loc2_;
         this.txt_roundScore_score.x = this.txt_roundScore_score.width < this.txt_roundScore_title.width ? int(this.txt_roundScore_title.x + (this.txt_roundScore_title.width - this.txt_roundScore_score.width) * 0.5) : int(this.txt_roundScore_title.x - 1);
         this.txt_roundScore_score.y = int(47 - this.txt_roundScore_score.height * 0.5);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._newRoundWaiting = Network.getInstance().serverTime < this._allianceSystem.round.activeTime.time;
         this._roundTimer.start();
         this.updateRoundScore();
         this.updateRoundEndTime();
         this.updateTokenCount();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._roundTimer.stop();
      }
      
      private function onRoundTimerTick(param1:TimerEvent) : void
      {
         this.updateRoundEndTime();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         mouseChildren = false;
         this._roundTimer.stop();
      }
      
      private function onAllianceTokensChanged() : void
      {
         this.updateTokenCount();
      }
      
      private function onAllianceScoreChanged() : void
      {
         this.updateRoundScore();
      }
      
      private function onAllianceRoundStarted() : void
      {
         this._newRoundWaiting = false;
         this.updateRoundEndTime();
         this.updateRoundScore();
      }
      
      private function onAllianceRoundEnded() : void
      {
         this._newRoundWaiting = true;
         this.updateRoundEndTime();
      }
      
      private function onWarClicked(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("allianceLeaderboard",true,true));
      }
   }
}

