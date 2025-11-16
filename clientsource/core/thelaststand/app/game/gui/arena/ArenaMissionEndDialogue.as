package thelaststand.app.game.gui.arena
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.arena.ArenaStageData;
   import thelaststand.app.game.data.arena.ArenaSystem;
   import thelaststand.app.game.gui.UIRewardsProgressBar;
   import thelaststand.app.game.gui.tooltip.UIArenaRewardTooltip;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class ArenaMissionEndDialogue extends BaseDialogue
   {
      
      private var _missionData:MissionData;
      
      private var _arenaSession:ArenaSession;
      
      private var _arenaStage:ArenaStageData;
      
      private var _objectiveRows:Vector.<ObjectiveRow>;
      
      private var _stagePts:int;
      
      private var mc_container:Sprite;
      
      private var mc_title:Sprite;
      
      private var mc_objectives:Sprite;
      
      private var mc_totalPoints:Sprite;
      
      private var mc_rewards:Sprite;
      
      private var txt_titlefield:BodyTextField;
      
      private var txt_pointsLabel:BodyTextField;
      
      private var txt_gamePoints:BodyTextField;
      
      private var txt_stagePoints:BodyTextField;
      
      private var txt_pointsInfo:BodyTextField;
      
      private var txt_rewardsLabel:BodyTextField;
      
      private var ui_rewardProgress:UIRewardsProgressBar;
      
      private var ui_rewardTooltip:UIArenaRewardTooltip;
      
      private var bmp_starsL:Bitmap;
      
      private var bmp_starsR:Bitmap;
      
      private var bmp_background:Bitmap;
      
      private var bmp_seperator1:Bitmap;
      
      private var bmp_seperator2:Bitmap;
      
      private var bmp_seperator3:Bitmap;
      
      private var bmp_tape_tl:Bitmap;
      
      private var bmp_tape_tr:Bitmap;
      
      private var bmp_tape_bl:Bitmap;
      
      private var bmp_tape_br:Bitmap;
      
      public function ArenaMissionEndDialogue(param1:ArenaSession, param2:MissionData)
      {
         var _loc6_:int = 0;
         var _loc7_:ColorTransform = null;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:ObjectiveRow = null;
         this.mc_container = new Sprite();
         super("arena-mission-end",this.mc_container,true);
         _width = 365;
         _autoSize = false;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this._arenaSession = param1;
         this._arenaStage = this._arenaSession.getArenaStage(this._arenaSession.completedStageIndex);
         this._missionData = param2;
         var _loc3_:String = Language.getInstance().getString("arena." + this._arenaSession.name + ".name");
         addTitle(Language.getInstance().getString("arena.title",_loc3_),BaseDialogue.TITLE_COLOR_GREY);
         var _loc4_:* = this._arenaSession.completedStageIndex == this._arenaSession.stageCount - 1;
         if(!_loc4_)
         {
            _loc16_ = Language.getInstance().getString("arena.mission_bail");
            addButton(_loc16_,false,{
               "backgroundColor":7545099,
               "width":150
            }).clicked.add(this.onClickBailOut);
         }
         var _loc5_:String = _loc4_ ? Language.getInstance().getString("arena.mission_ok") : Language.getInstance().getString("arena.mission_continue",this._arenaSession.completedStageIndex + 2);
         addButton(_loc5_,true,{"width":150});
         _loc6_ = 13;
         this.bmp_background = new Bitmap(new BmpRaidMissionBg());
         this.bmp_background.scale9Grid = new Rectangle(14,14,this.bmp_background.width - 28,this.bmp_background.height - 28);
         this.bmp_background.height = 320;
         this.mc_container.addChild(this.bmp_background);
         _height = int(this.bmp_background.y + this.bmp_background.height + _padding * 2 + 40);
         _loc7_ = new ColorTransform(0,0,0,1);
         this.bmp_seperator1 = new Bitmap(new BmpDivider());
         this.bmp_seperator1.width = int(this.bmp_background.width - _loc6_ * 2);
         this.bmp_seperator1.x = int(this.bmp_background.x + _loc6_);
         this.bmp_seperator1.transform.colorTransform = _loc7_;
         this.mc_container.addChild(this.bmp_seperator1);
         this.bmp_seperator2 = new Bitmap(new BmpDivider());
         this.bmp_seperator2.width = this.bmp_seperator1.width;
         this.bmp_seperator2.x = int(this.bmp_seperator1.x);
         this.bmp_seperator2.transform.colorTransform = _loc7_;
         this.mc_container.addChild(this.bmp_seperator2);
         this.bmp_seperator3 = new Bitmap(new BmpDivider());
         this.bmp_seperator3.width = this.bmp_seperator1.width;
         this.bmp_seperator3.x = int(this.bmp_seperator1.x);
         this.bmp_seperator3.transform.colorTransform = _loc7_;
         this.mc_container.addChild(this.bmp_seperator3);
         var _loc8_:int = int(this.bmp_background.width - _loc6_ * 2);
         this.mc_title = new Sprite();
         this.mc_title.x = int(this.bmp_background.x + _loc6_);
         this.mc_title.y = int(this.bmp_background.y + _loc6_);
         this.mc_title.graphics.beginFill(11364392);
         this.mc_title.graphics.drawRect(0,0,_loc8_,38);
         this.mc_title.graphics.endFill();
         this.mc_container.addChild(this.mc_title);
         this.txt_titlefield = new BodyTextField({
            "color":16381939,
            "size":22,
            "bold":true
         });
         this.txt_titlefield.text = this._arenaStage.survivorCount > 0 ? Language.getInstance().getString("arena.success").toUpperCase() : Language.getInstance().getString("arena.failed").toUpperCase();
         this.txt_titlefield.x = int((this.mc_title.width - this.txt_titlefield.width) * 0.5);
         this.txt_titlefield.y = int((this.mc_title.height - this.txt_titlefield.height) * 0.5);
         this.mc_title.addChild(this.txt_titlefield);
         this.bmp_starsL = new Bitmap(new BmpBountyStars(),"auto",true);
         this.bmp_starsL.x = 12;
         this.bmp_starsL.y = int((this.mc_title.height - this.bmp_starsL.height) * 0.5);
         this.mc_title.addChild(this.bmp_starsL);
         this.bmp_starsR = new Bitmap(new BmpBountyStars(),"auto",true);
         this.bmp_starsR.x = int(this.mc_title.width - 12 - this.bmp_starsR.width);
         this.bmp_starsR.y = int((this.mc_title.height - this.bmp_starsL.height) * 0.5);
         this.mc_title.addChild(this.bmp_starsR);
         this._objectiveRows = new Vector.<ObjectiveRow>();
         this.mc_objectives = new Sprite();
         this.mc_objectives.x = int(this.bmp_background.x + _loc6_);
         this.mc_objectives.y = int(this.bmp_background.y + _loc6_ + 46);
         this.mc_container.addChild(this.mc_objectives);
         this._stagePts = 0;
         var _loc9_:ObjectiveRow = new ObjectiveRow(Language.getInstance().getString("arena.obj_survivors",this._arenaStage.survivorCount),this._arenaStage.survivorPoints,new BmpIconRaidObjSurvivors(),this._arenaStage.survivorCount > 0);
         this._objectiveRows.push(_loc9_);
         var _loc10_:String = Language.getInstance().getString("arena." + this._arenaSession.name + ".objectives");
         var _loc11_:ObjectiveRow = new ObjectiveRow(_loc10_,this._arenaStage.objectivePoints,new BmpIconRaidObjSecondary(),this._arenaStage.objectivePoints > 0);
         this._objectiveRows.push(_loc11_);
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         while(_loc13_ < this._objectiveRows.length)
         {
            _loc17_ = this._objectiveRows[_loc13_];
            this.mc_objectives.addChild(_loc17_);
            _loc17_.y = _loc12_;
            _loc17_.width = _loc8_;
            _loc17_.height = 34;
            _loc17_.alternate = _loc13_ % 2 != 0;
            _loc12_ += int(_loc17_.height);
            _loc13_++;
         }
         this.mc_totalPoints = new Sprite();
         this.mc_totalPoints.graphics.beginFill(0,0.8);
         this.mc_totalPoints.graphics.drawRect(0,0,_loc8_,56);
         this.mc_totalPoints.graphics.endFill();
         this.mc_totalPoints.x = int(this.mc_objectives.x);
         this.mc_totalPoints.y = int(this.mc_objectives.y + 68);
         this.mc_container.addChild(this.mc_totalPoints);
         this.txt_pointsLabel = new BodyTextField({
            "color":14736333,
            "size":18,
            "bold":true
         });
         this.txt_pointsLabel.text = Language.getInstance().getString("arena.mission_points_total").toUpperCase();
         this.txt_pointsLabel.x = 10;
         this.txt_pointsLabel.y = int((this.mc_totalPoints.height - this.txt_pointsLabel.height) * 0.5);
         this.mc_totalPoints.addChild(this.txt_pointsLabel);
         this._stagePts += this._arenaStage.survivorPoints;
         this._stagePts += this._arenaStage.objectivePoints;
         this.txt_stagePoints = new BodyTextField({
            "color":15712580,
            "size":22,
            "bold":true
         });
         this.txt_stagePoints.text = "+" + NumberFormatter.format(this._stagePts,0);
         this.txt_stagePoints.x = int(this.mc_totalPoints.width - this.txt_stagePoints.width - 10);
         this.txt_stagePoints.y = int((this.mc_totalPoints.height - this.txt_stagePoints.height) * 0.5);
         this.mc_totalPoints.addChild(this.txt_stagePoints);
         this.txt_gamePoints = new BodyTextField({
            "color":14736333,
            "size":32,
            "bold":true,
            "align":TextFormatAlign.RIGHT
         });
         this.txt_gamePoints.text = NumberFormatter.format(this._arenaSession.points - this._stagePts,0);
         this.txt_gamePoints.x = int(this.txt_stagePoints.x - this.txt_gamePoints.width - 10);
         this.txt_gamePoints.y = int((this.mc_totalPoints.height - this.txt_gamePoints.height) * 0.5);
         this.mc_totalPoints.addChild(this.txt_gamePoints);
         this.txt_pointsInfo = new BodyTextField({
            "color":4276025,
            "size":12,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_pointsInfo.text = Language.getInstance().getString("arena.mission_points_desc");
         this.txt_pointsInfo.x = int((_width - _padding * 2 - this.txt_pointsInfo.width) * 0.5);
         this.txt_pointsInfo.y = int(this.mc_totalPoints.y + this.mc_totalPoints.height + 10);
         this.mc_container.addChild(this.txt_pointsInfo);
         this.mc_rewards = new Sprite();
         this.mc_rewards.graphics.beginFill(0,0.7);
         this.mc_rewards.graphics.drawRect(0,0,_loc8_,60);
         this.mc_rewards.graphics.endFill();
         this.mc_rewards.x = int(this.bmp_background.x + _loc6_);
         this.mc_rewards.y = int(this.bmp_background.y + this.bmp_background.height - 60 - _loc6_);
         this.mc_container.addChild(this.mc_rewards);
         this.ui_rewardTooltip = new UIArenaRewardTooltip();
         this.ui_rewardProgress = new UIRewardsProgressBar();
         this.ui_rewardProgress.borderColor = 7812366;
         this.ui_rewardProgress.barColor = 11098127;
         this.ui_rewardProgress.tooltip = this.ui_rewardTooltip;
         this.ui_rewardProgress.setData(this._arenaSession.xml.rewards.tier);
         this.ui_rewardProgress.width = int(this.mc_rewards.width - 30);
         this.ui_rewardProgress.x = 10;
         this.ui_rewardProgress.y = 10;
         this.ui_rewardProgress.fadedValue = this._arenaSession.points;
         this.ui_rewardProgress.solidValue = this._arenaSession.currentRewardTier > -1 ? int(this._arenaSession.xml.rewards.tier[this._arenaSession.currentRewardTier].@score) : 0;
         this.mc_rewards.addChild(this.ui_rewardProgress);
         var _loc14_:String = Language.getInstance().getString("arena.reward_title",Language.getInstance().getString("arena." + this._arenaSession.name + ".name")).toUpperCase();
         this.txt_rewardsLabel = new BodyTextField({
            "color":4276025,
            "size":14,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_rewardsLabel.text = _loc14_;
         this.txt_rewardsLabel.x = int((_width - _padding * 2 - this.txt_rewardsLabel.width) * 0.5);
         this.txt_rewardsLabel.y = int(this.mc_rewards.y - this.txt_rewardsLabel.height - 4);
         this.mc_container.addChild(this.txt_rewardsLabel);
         this.bmp_seperator1.y = int(this.bmp_background.y + _loc6_ + 42);
         this.bmp_seperator2.y = int(this.mc_totalPoints.y + this.mc_totalPoints.height + 2);
         this.bmp_seperator3.y = int(this.txt_pointsInfo.y + this.txt_pointsInfo.height + 8);
         _loc15_ = -1;
         this.bmp_tape_tl = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_tl.x = this.bmp_background.x - _loc15_;
         this.bmp_tape_tl.y = this.bmp_background.y - _loc15_;
         this.mc_container.addChild(this.bmp_tape_tl);
         this.bmp_tape_tr = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_tr.scaleX = -1;
         this.bmp_tape_tr.x = this.bmp_background.x + this.bmp_background.width + _loc15_;
         this.bmp_tape_tr.y = this.bmp_background.y - _loc15_;
         this.mc_container.addChild(this.bmp_tape_tr);
         this.bmp_tape_bl = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_bl.scaleY = -1;
         this.bmp_tape_bl.x = this.bmp_background.x - _loc15_;
         this.bmp_tape_bl.y = this.bmp_background.y + this.bmp_background.height + _loc15_;
         this.mc_container.addChild(this.bmp_tape_bl);
         this.bmp_tape_br = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_br.scaleX = -1;
         this.bmp_tape_br.scaleY = -1;
         this.bmp_tape_br.x = this.bmp_background.x + this.bmp_background.width + _loc15_;
         this.bmp_tape_br.y = this.bmp_background.y + this.bmp_background.height + _loc15_;
         this.mc_container.addChild(this.bmp_tape_br);
      }
      
      override public function dispose() : void
      {
         var _loc2_:ObjectiveRow = null;
         super.dispose();
         TweenMax.killChildTweensOf(this.mc_container);
         this._arenaSession = null;
         this._arenaStage = null;
         this.txt_pointsLabel.dispose();
         this.txt_stagePoints.dispose();
         this.txt_gamePoints.dispose();
         this.txt_pointsInfo.dispose();
         this.txt_rewardsLabel.dispose();
         this.ui_rewardProgress.dispose();
         this.ui_rewardTooltip.dispose();
         this.bmp_starsL.bitmapData.dispose();
         this.bmp_starsR.bitmapData.dispose();
         this.bmp_background.bitmapData.dispose();
         this.bmp_seperator1.bitmapData.dispose();
         this.bmp_seperator2.bitmapData.dispose();
         this.bmp_seperator3.bitmapData.dispose();
         this.bmp_tape_tl.bitmapData.dispose();
         this.bmp_tape_tr.bitmapData.dispose();
         this.bmp_tape_bl.bitmapData.dispose();
         this.bmp_tape_br.bitmapData.dispose();
         var _loc1_:int = 0;
         while(_loc1_ < this._objectiveRows.length)
         {
            _loc2_ = this._objectiveRows[_loc1_];
            _loc2_.dispose();
            _loc1_++;
         }
      }
      
      override public function open() : void
      {
         super.open();
         this.playPointsAnimation();
      }
      
      private function playPointsAnimation() : void
      {
         var pts:Object = null;
         var rPtsX:int = 0;
         var time:Number = NaN;
         if(this._stagePts > 0)
         {
            pts = {
               "stage":this._stagePts,
               "game":Math.max(this._arenaSession.points - this._stagePts,0)
            };
            this.txt_stagePoints.autoSize = TextFieldAutoSize.RIGHT;
            this.txt_stagePoints.text = "+" + NumberFormatter.format(pts.stage,0);
            this.txt_gamePoints.text = NumberFormatter.format(pts.game,0);
            rPtsX = this.txt_gamePoints.x + this.txt_gamePoints.width;
            time = Math.min(this._stagePts * 0.02,5);
            TweenMax.to(pts,time,{
               "stage":0,
               "game":this._arenaSession.points,
               "delay":1,
               "ease":Linear.easeNone,
               "onUpdate":function():void
               {
                  txt_stagePoints.text = "+" + NumberFormatter.format(pts.stage,0);
                  txt_gamePoints.text = NumberFormatter.format(pts.game,0);
                  txt_gamePoints.x = rPtsX - txt_gamePoints.width;
               },
               "onComplete":function():void
               {
                  TweenMax.to(txt_stagePoints,0.25,{
                     "delay":1,
                     "alpha":0
                  });
                  TweenMax.to(txt_gamePoints,0.25,{
                     "delay":1.15,
                     "x":int(mc_totalPoints.width - txt_gamePoints.width - 10)
                  });
               }
            });
         }
         else
         {
            this.txt_stagePoints.visible = false;
            this.txt_gamePoints.text = "0";
            this.txt_gamePoints.x = int(this.mc_totalPoints.width - this.txt_gamePoints.width - 10);
         }
      }
      
      private function onClickBailOut(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var body:String = Language.getInstance().getString("arena.bail_message",Language.getInstance().getString("arena." + this._arenaSession.name + ".name"),NumberFormatter.format(this._arenaSession.points,0));
         var msg:MessageBox = new MessageBox(body,"arena-bail-out",true,true);
         msg.addTitle(Language.getInstance().getString("arena.bail_title"),BaseDialogue.TITLE_COLOR_RUST);
         msg.addButton(Language.getInstance().getString("arena.bail_ok"),true).clicked.addOnce(function(param1:MouseEvent):void
         {
            var e:MouseEvent = param1;
            ArenaSystem.finishSession(_arenaSession,_missionData,function(param1:Boolean):void
            {
               if(param1)
               {
                  close();
               }
            });
         });
         msg.addButton(Language.getInstance().getString("arena.bail_cancel"));
         msg.open();
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.gui.UIComponent;

class ObjectiveRow extends UIComponent
{
   
   private var _width:int;
   
   private var _height:int;
   
   private var _altRow:Boolean;
   
   private var _success:Boolean;
   
   private var mc_background:Shape;
   
   private var txt_objective:BodyTextField;
   
   private var txt_points:BodyTextField;
   
   private var bmp_image:Bitmap;
   
   private var bmp_success:Bitmap;
   
   public function ObjectiveRow(param1:String, param2:int, param3:BitmapData, param4:Boolean)
   {
      super();
      this._success = param4;
      this.mc_background = new Shape();
      addChild(this.mc_background);
      var _loc5_:uint = this._success ? 7905868 : 13319999;
      this.txt_objective = new BodyTextField({
         "color":_loc5_,
         "size":16,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_objective.text = param1;
      addChild(this.txt_objective);
      this.txt_points = new BodyTextField({
         "color":_loc5_,
         "size":16,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_points.text = (param2 > 0 ? "+" : "") + NumberFormatter.format(param2,0);
      addChild(this.txt_points);
      this.bmp_image = new Bitmap(param3);
      addChild(this.bmp_image);
      this.bmp_success = new Bitmap(this._success ? new BmpIconTradeTickGreen() : new BmpIconTradeCrossRed());
      addChild(this.bmp_success);
   }
   
   public function get alternate() : Boolean
   {
      return this._altRow;
   }
   
   public function set alternate(param1:Boolean) : void
   {
      this._altRow = param1;
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = param1;
      invalidate();
   }
   
   override public function get height() : Number
   {
      return this._height;
   }
   
   override public function set height(param1:Number) : void
   {
      this._height = param1;
      invalidate();
   }
   
   override public function dispose() : void
   {
      super.dispose();
      if(this.bmp_image.bitmapData != null)
      {
         this.bmp_image.bitmapData.dispose();
      }
      this.bmp_success.bitmapData.dispose();
      this.txt_objective.dispose();
      this.txt_points.dispose();
   }
   
   override protected function draw() : void
   {
      this.mc_background.graphics.clear();
      this.mc_background.graphics.beginFill(0,this._altRow ? 0.7 : 0.8);
      this.mc_background.graphics.drawRect(0,0,this._width,this._height);
      this.mc_background.graphics.endFill();
      this.bmp_image.x = int(this.bmp_image.width * 0.5);
      this.bmp_image.y = int((this._height - this.bmp_image.height) * 0.5);
      this.bmp_success.x = 44;
      this.bmp_success.y = int((this._height - this.bmp_success.height) * 0.5);
      this.txt_objective.x = 68;
      this.txt_objective.y = int((this._height - this.txt_objective.height) * 0.5);
      this.txt_points.x = int(this._width - this.txt_points.width - 8);
      this.txt_points.y = this.txt_objective.y;
      this.txt_objective.maxWidth = int(this.txt_points.x - this.txt_objective.x - 6);
      this.txt_objective.text = this.txt_objective.text;
   }
}
