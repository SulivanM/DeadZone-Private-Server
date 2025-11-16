package thelaststand.app.game.gui.quest
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Cubic;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.text.AntiAliasType;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TextFieldTyper;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.quests.MiniTask;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.common.lang.Language;
   
   public class UIQuestCompletedNotification extends Sprite
   {
      
      public static const COLOR_ACHIEVEMENT:uint = 8305705;
      
      public static const COLOR_TASK:uint = 1474240;
      
      public static const COLOR_FAIL:uint = 11994112;
      
      public static const COLOR_REPEAT_ACHIEVEMENT:uint = 15161347;
      
      public static const COLOR_ALLIANCE_TASK:uint = 10472219;
      
      public static const COLOR_INFECTED_BOUNTY:uint = 14090240;
      
      public static const COLOR_RESEARCH_TASK:uint = 7063274;
      
      private var _width:int = 240;
      
      private var _height:int = 52;
      
      private var _color:uint;
      
      private var _message:String;
      
      private var _timedAch:MiniTask;
      
      private var _timer:Timer;
      
      private var _name:String;
      
      private var _sound:String;
      
      private var _xp:int;
      
      private var bmp_icon:Bitmap;
      
      private var mc_background:Shape;
      
      private var mc_iconBackground:Sprite;
      
      private var mc_container:Sprite;
      
      private var txt_message:TitleTextField;
      
      private var txt_name:TitleTextField;
      
      private var txt_xp:BodyTextField;
      
      public var completed:Signal;
      
      public function UIQuestCompletedNotification(param1:uint, param2:BitmapData, param3:String, param4:String, param5:int, param6:String)
      {
         var _loc7_:String = null;
         super();
         mouseChildren = mouseEnabled = false;
         this._color = param1;
         this._message = param3;
         this._name = param4;
         this._xp = param5;
         this._sound = param6;
         this._timer = new Timer(5000,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,0,true);
         this.mc_background = new Shape();
         addChild(this.mc_background);
         this.mc_container = new Sprite();
         addChild(this.mc_container);
         this.mc_iconBackground = new Sprite();
         this.bmp_icon = new Bitmap(param2,"never",true);
         this.txt_message = new TitleTextField({
            "text":this._message.toUpperCase(),
            "color":this._color,
            "size":16,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_name = new TitleTextField({
            "text":this._name.toUpperCase(),
            "color":16777215,
            "size":22,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.mc_container.addChild(this.mc_iconBackground);
         this.mc_container.addChild(this.bmp_icon);
         this.mc_container.addChild(this.txt_message);
         this.mc_container.addChild(this.txt_name);
         if(this._xp > 0)
         {
            _loc7_ = Language.getInstance().getString("msg_xp_awarded",NumberFormatter.format(this._xp,0));
            this.txt_xp = new BodyTextField({
               "text":_loc7_,
               "color":16363264,
               "size":12,
               "bold":true,
               "antiAliasType":AntiAliasType.ADVANCED,
               "filters":[Effects.TEXT_SHADOW_DARK]
            });
            this.mc_container.addChild(this.txt_xp);
         }
         this.completed = new Signal();
         this.draw();
      }
      
      public static function fromInfectedBounty(param1:InfectedBounty) : UIQuestCompletedNotification
      {
         var _loc2_:uint = 0;
         var _loc3_:String = null;
         var _loc4_:BitmapData = null;
         var _loc5_:String = null;
         if(param1.isCompleted)
         {
            _loc2_ = COLOR_INFECTED_BOUNTY;
            _loc3_ = Language.getInstance().getString("bounty.infected_note_completed");
            _loc4_ = new BmpIconSkull();
            _loc5_ = "sound/interface/int-complete-task.mp3";
         }
         var _loc6_:String = Language.getInstance().getString("bounty.infected_bounty");
         return new UIQuestCompletedNotification(_loc2_,_loc4_,_loc3_,_loc6_,0,_loc5_);
      }
      
      public static function fromInfectedBountyTask(param1:InfectedBountyTask) : UIQuestCompletedNotification
      {
         var _loc2_:uint = COLOR_INFECTED_BOUNTY;
         var _loc3_:String = Language.getInstance().getString("bounty.infected_bounty_task",Language.getInstance().getString("suburbs." + param1.suburb));
         var _loc4_:String = Language.getInstance().getString("bounty.infected_task_complete");
         var _loc5_:BitmapData = new BmpIconSkull();
         var _loc6_:String = "sound/interface/int-complete-task.mp3";
         return new UIQuestCompletedNotification(_loc2_,_loc5_,_loc4_,_loc3_,0,_loc6_);
      }
      
      public static function fromQuest(param1:Quest) : UIQuestCompletedNotification
      {
         var _loc2_:uint = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:BitmapData = null;
         var _loc7_:int = 0;
         _loc4_ = param1.getName();
         if(param1.isAchievement)
         {
            _loc2_ = COLOR_ACHIEVEMENT;
            _loc3_ = Language.getInstance().getString("quest_achievement_complete");
            _loc6_ = Quest.getIcon(param1.type);
            _loc5_ = "sound/interface/int-complete-achievement.mp3";
            if(param1.xml.reward.xp.length() > 0)
            {
               _loc7_ = int(param1.xml.reward.xp[0].toString());
            }
         }
         else if(param1.failed)
         {
            _loc2_ = COLOR_FAIL;
            _loc3_ = Language.getInstance().getString("quest_task_failed");
            _loc6_ = new BmpExitZoneBad();
            _loc5_ = "sound/interface/int-fail-task.mp3";
         }
         else
         {
            _loc2_ = COLOR_TASK;
            _loc3_ = Language.getInstance().getString("quest_task_complete");
            _loc6_ = Quest.getIcon(param1.type);
            _loc5_ = "sound/interface/int-complete-task.mp3";
         }
         return new UIQuestCompletedNotification(_loc2_,_loc6_,_loc3_,_loc4_,_loc7_,_loc5_);
      }
      
      public static function fromResearchTask(param1:ResearchTask) : UIQuestCompletedNotification
      {
         var _loc2_:uint = COLOR_RESEARCH_TASK;
         var _loc3_:String = Language.getInstance().getString("research_alert_name",ResearchSystem.getCategoryGroupName(param1.category,param1.group,param1.level));
         var _loc4_:String = Language.getInstance().getString("research_alert_msg");
         var _loc5_:BitmapData = new BmpIconResearchSmall();
         var _loc6_:String = "sound/interface/int-complete-task.mp3";
         return new UIQuestCompletedNotification(_loc2_,_loc5_,_loc4_,_loc3_,0,_loc6_);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this._timer.stop();
      }
      
      public function transitionIn() : void
      {
         this.txt_message.text = "";
         this.txt_name.text = "";
         if(this.txt_xp != null)
         {
            this.txt_xp.alpha = 0;
         }
         TweenMax.from(this,0.6,{
            "colorTransform":{"exposure":2},
            "ease":Linear.easeNone
         });
         TweenMax.from(this.mc_container,0.3,{
            "delay":0.4,
            "x":int(this._width * 0.5 - this.mc_iconBackground.width * 0.5),
            "ease":Cubic.easeOut
         });
         TweenMax.from(this.mc_background,0.3,{
            "transformAroundCenter":{
               "scaleX":0.75,
               "scaleY":0
            },
            "alpha":0,
            "ease":Back.easeOut,
            "easeParams":[0.95]
         });
         TweenMax.from(this.mc_iconBackground,0.25,{
            "delay":0.15,
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeOut,
            "onComplete":function():void
            {
               new TextFieldTyper(txt_message).type(_message.toUpperCase(),60);
               new TextFieldTyper(txt_name).type(_name.toUpperCase(),40);
               if(txt_xp != null)
               {
                  TweenMax.to(txt_xp,0.25,{
                     "delay":0.25,
                     "alpha":1
                  });
               }
            }
         });
         TweenMax.from(this.bmp_icon,0.35,{
            "delay":0.3,
            "transformAroundCenter":{
               "scaleX":1.5,
               "scaleY":1.5
            },
            "ease":Cubic.easeOut
         });
         TweenMax.from(this.bmp_icon,0.15,{
            "delay":0.3,
            "alpha":0
         });
         TweenMax.to(this.mc_iconBackground,0.3,{
            "delay":0.3,
            "glowFilter":{
               "color":this._color,
               "alpha":1,
               "blurX":40,
               "blurY":40,
               "strength":1.5,
               "quality":2
            }
         });
         if(this._sound != null)
         {
            Audio.sound.play(this._sound);
         }
         this._timer.start();
      }
      
      public function transitionOut() : void
      {
         this._timer.stop();
         this.mc_iconBackground.filters = [];
         this.mc_iconBackground.cacheAsBitmap = false;
         TweenMax.to(this.txt_message,0.15,{
            "alpha":0,
            "y":"-5"
         });
         TweenMax.to(this.txt_name,0.15,{
            "alpha":0,
            "y":"+5"
         });
         if(this.txt_xp != null)
         {
            TweenMax.to(this.txt_xp,0.15,{
               "alpha":0,
               "y":"+5"
            });
         }
         TweenMax.to(this.mc_iconBackground,0.25,{
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeIn
         });
         TweenMax.to(this.bmp_icon,0.25,{
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeIn
         });
         TweenMax.to(this.mc_background,0.25,{
            "delay":0.15,
            "transformAroundCenter":{
               "scaleX":0.5,
               "scaleY":0
            },
            "ease":Back.easeIn,
            "onComplete":function():void
            {
               completed.dispatch();
               dispose();
            }
         });
      }
      
      private function draw() : void
      {
         var _loc1_:Matrix = new Matrix();
         _loc1_.createGradientBox(this._width,this._height);
         this.mc_background.graphics.beginGradientFill("linear",[0,0,0,0],[0,0.5,0.5,0],[0,50,205,255],_loc1_);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_iconBackground.graphics.beginFill(3158064);
         this.mc_iconBackground.graphics.drawRoundRect(0,0,32,28,6,6);
         this.mc_iconBackground.graphics.endFill();
         this.mc_iconBackground.graphics.beginFill(new Color(this._color).adjustBrightness(0.75).RGB);
         this.mc_iconBackground.graphics.drawRoundRect(2,2,28,24,4,4);
         this.mc_iconBackground.graphics.endFill();
         _loc1_.identity();
         _loc1_.tx = 50;
         _loc1_.ty = 2;
         this.mc_iconBackground.graphics.beginBitmapFill(new BmpButtonPaint(),_loc1_,true,true);
         this.mc_iconBackground.graphics.drawRoundRect(2,2,28,24,4,4);
         this.mc_iconBackground.graphics.endFill();
         this.mc_iconBackground.y = -int(this.mc_iconBackground.height * 0.5);
         this.bmp_icon.x = Math.round(this.mc_iconBackground.x + (this.mc_iconBackground.width - this.bmp_icon.width) * 0.5);
         this.bmp_icon.y = int(this.mc_iconBackground.y + (this.mc_iconBackground.height - this.bmp_icon.height) * 0.5);
         this.txt_message.x = int(this.mc_iconBackground.x + this.mc_iconBackground.width + 6);
         this.txt_message.y = int(-this.txt_message.height);
         this.txt_name.x = int(this.txt_message.x - 2);
         this.txt_name.y = int(this.txt_message.y + this.txt_message.height - 8);
         if(this.txt_xp != null)
         {
            this.txt_xp.x = int(this.txt_name.x + this.txt_name.width + 2);
            this.txt_xp.y = int(this.txt_name.y + (this.txt_name.height - this.txt_xp.height) * 0.5);
         }
         this.mc_container.y = int(this._height * 0.5);
         this.mc_container.x = int((this._width - this.mc_container.width) * 0.5) - 6;
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         this.transitionOut();
      }
   }
}

