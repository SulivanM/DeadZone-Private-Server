package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Linear;
   import com.greensock.easing.Quad;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.alliance.UIAllianceIndividualRewardsProgressBar;
   import thelaststand.app.game.gui.bounty.BountyStyleBox;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class AllianceMissionSummaryDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _missionData:MissionData;
      
      private var _contentWidth:Number = 320;
      
      private var _tweenDummy:Object;
      
      private var _disposed:Boolean = false;
      
      private var bmd_divider:BitmapData;
      
      private var bmd_stars:BitmapData;
      
      private var bmd_title:BitmapData;
      
      private var bmp_starsLeft:Bitmap;
      
      private var bmp_starsRight:Bitmap;
      
      private var bmp_div1:Bitmap;
      
      private var bmp_div2:Bitmap;
      
      private var bmp_div3:Bitmap;
      
      private var bmp_div4:Bitmap;
      
      private var mc_background:BountyStyleBox;
      
      private var mc_content:Sprite;
      
      private var mc_container:Sprite;
      
      private var txt_heading:BodyTextField;
      
      private var txt_ptsHeading:BodyTextField;
      
      private var txt_ptsTotal:BodyTextField;
      
      private var txt_ptsReward:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_indititle:BodyTextField;
      
      private var indiProgress:UIAllianceIndividualRewardsProgressBar;
      
      private var success:Boolean = false;
      
      public function AllianceMissionSummaryDialogue(param1:MissionData)
      {
         var _loc7_:Survivor = null;
         this._tweenDummy = {};
         this.mc_container = new Sprite();
         super("alliance-messageCreate",this.mc_container,true);
         this._missionData = param1;
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 354;
         _height = 380;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this.success = false;
         if(this._missionData.isPvP)
         {
            this.success = this._missionData.allianceFlagCaptured;
         }
         else if(this._missionData.allContainersSearched)
         {
            for each(_loc7_ in this._missionData.survivors)
            {
               if(_loc7_.health > 0)
               {
                  this.success = true;
                  break;
               }
            }
         }
         this.bmd_title = new BmpTitle_AllianceHistory();
         addTitle("",TITLE_COLOR_GREY,-1,this.bmd_title);
         addButton(this._lang.getString("alliance.raidresult_ok"),true,{"width":150});
         this.mc_background = new BountyStyleBox(326,300);
         this.mc_background.y = _padding * 0.5;
         this.mc_container.addChild(this.mc_background);
         this.mc_content = new Sprite();
         this.mc_background.container.addChild(this.mc_content);
         var _loc2_:int = 1;
         var _loc3_:int = 51;
         this.mc_content.graphics.beginFill(this.success ? 3364613 : 7536640,this.success ? 0.6 : 0.7);
         this.mc_content.graphics.drawRect(1,_loc2_,this._contentWidth - 2,_loc3_);
         this.bmd_divider = new BmpBountyDivider();
         this.bmp_div1 = new Bitmap(this.bmd_divider);
         this.bmp_div1.x = -2;
         this.bmp_div1.y = int(_loc2_ + _loc3_ + 1);
         this.mc_content.addChild(this.bmp_div1);
         this.bmd_stars = new BmpBountyStars();
         this.bmp_starsLeft = new Bitmap(this.bmd_stars);
         this.bmp_starsLeft.x = 14;
         this.bmp_starsLeft.y = 16;
         this.mc_content.addChild(this.bmp_starsLeft);
         this.bmp_starsRight = new Bitmap(this.bmd_stars);
         this.bmp_starsRight.x = int(this._contentWidth - this.bmp_starsRight.width - this.bmp_starsLeft.x);
         this.bmp_starsRight.y = this.bmp_starsLeft.y;
         this.mc_content.addChild(this.bmp_starsRight);
         this.txt_heading = new BodyTextField({
            "size":30,
            "bold":true,
            "color":16777215,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_heading.maxWidth = int(this.bmp_starsRight.x - (this.bmp_starsLeft.x + this.bmp_starsLeft.width));
         var _loc4_:String = "";
         if(param1.isPvP)
         {
            _loc4_ = this._lang.getString(this.success ? "alliance.raidresult_success_title" : "alliance.raidresult_fail_title");
         }
         else
         {
            _loc4_ = this._lang.getString(this.success ? "alliance.raidresult_missionSuccess_title" : "alliance.raidresult_missionFail_title");
         }
         this.txt_heading.text = _loc4_;
         this.txt_heading.x = int(this.bmp_starsLeft.x + this.bmp_starsLeft.width + (this.txt_heading.maxWidth - this.txt_heading.width) * 0.5);
         this.txt_heading.y = int(this.bmp_starsLeft.y + (this.bmp_starsLeft.height - this.txt_heading.height) * 0.5);
         this.mc_content.addChild(this.txt_heading);
         this.txt_ptsHeading = new BodyTextField({
            "size":18,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_ptsHeading.maxWidth = this._contentWidth;
         this.txt_ptsHeading.text = this._lang.getString("alliance.raidresult_warpts_msg").toUpperCase();
         this.txt_ptsHeading.x = int((this._contentWidth - this.txt_ptsHeading.width) * 0.5);
         this.txt_ptsHeading.y = int(this.bmp_div1.y + 5);
         this.mc_content.addChild(this.txt_ptsHeading);
         this.bmp_div2 = new Bitmap(this.bmd_divider);
         this.bmp_div2.x = int(this.bmp_div1.x);
         this.bmp_div2.y = int(this.txt_ptsHeading.y + this.txt_ptsHeading.height + 5);
         this.mc_content.addChild(this.bmp_div2);
         var _loc5_:int = int(this.bmp_div2.y + 3);
         var _loc6_:int = 60;
         this.mc_content.graphics.beginFill(3881524,0.7);
         this.mc_content.graphics.drawRect(1,_loc5_,this._contentWidth - 2,_loc6_);
         this.txt_ptsTotal = new BodyTextField({
            "text":"0",
            "size":53,
            "bold":true,
            "color":16777215
         });
         this.txt_ptsTotal.x = int((this._contentWidth - this.txt_ptsTotal.width) * 0.5);
         this.txt_ptsTotal.y = int(_loc5_ + (_loc6_ - this.txt_ptsTotal.height) * 0.5);
         this.mc_content.addChild(this.txt_ptsTotal);
         this.txt_ptsReward = new BodyTextField({
            "text":"0",
            "size":53,
            "bold":true,
            "color":(this.success ? 9557306 : 13172993)
         });
         this.txt_ptsReward.x = int((this._contentWidth - this.txt_ptsReward.width) * 0.5);
         this.txt_ptsReward.y = int(_loc5_ + (_loc6_ - this.txt_ptsReward.height) * 0.5);
         this.txt_ptsReward.visible = false;
         this.mc_content.addChild(this.txt_ptsReward);
         this.bmp_div3 = new Bitmap(this.bmd_divider);
         this.bmp_div3.x = int(this.bmp_div1.x);
         this.bmp_div3.y = int(_loc5_ + _loc6_ + 1);
         this.mc_content.addChild(this.bmp_div3);
         this.txt_desc = new BodyTextField({
            "size":12,
            "color":4276025,
            "multiline":true,
            "align":TextFormatAlign.CENTER
         });
         this.txt_desc.x = 4;
         this.txt_desc.y = int(this.bmp_div3.y + 5);
         this.txt_desc.width = int(this._contentWidth - this.txt_desc.x * 2);
         this.txt_desc.htmlText = this._lang.getString(this.success ? "alliance.raidresult_success_desc" : "alliance.raidresult_fail_desc");
         this.mc_content.addChild(this.txt_desc);
         this.bmp_div4 = new Bitmap(this.bmd_divider);
         this.bmp_div4.x = int(this.bmp_div1.x);
         this.bmp_div4.y = this.txt_desc.y + this.txt_desc.height + 5;
         this.mc_content.addChild(this.bmp_div4);
         this.txt_indititle = new BodyTextField({
            "size":14,
            "color":4276025,
            "bold":true,
            "multiline":true,
            "align":TextFormatAlign.CENTER
         });
         this.txt_indititle.x = 4;
         this.txt_indititle.y = int(this.bmp_div4.y + 5);
         this.txt_indititle.width = int(this._contentWidth - this.txt_indititle.x * 2);
         this.txt_indititle.htmlText = this._lang.getString("alliance.raidresult_indiprogress");
         this.mc_content.addChild(this.txt_indititle);
         _loc5_ = int(this.txt_indititle.y + this.txt_indititle.height + 3);
         _loc6_ = 60;
         this.mc_content.graphics.beginFill(3881524,0.7);
         this.mc_content.graphics.drawRect(1,_loc5_,this._contentWidth - 2,_loc6_);
         this.indiProgress = new UIAllianceIndividualRewardsProgressBar();
         this.indiProgress.x = 12;
         this.indiProgress.y = _loc5_ + 10;
         this.indiProgress.width = this._contentWidth - (this.indiProgress.x * 2 + 12);
         this.mc_content.addChild(this.indiProgress);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TweenMax.killTweensOf(this._tweenDummy);
         TweenMax.killChildTweensOf(this.mc_content);
         this._lang = null;
         this._missionData = null;
         this._disposed = true;
         this.bmd_title.dispose();
         this.bmd_stars.dispose();
         this.bmd_divider.dispose();
         this.mc_background.dispose();
         this.txt_heading.dispose();
         this.txt_ptsHeading.dispose();
         this.txt_desc.dispose();
         this.txt_indititle.dispose();
         this.indiProgress.dispose();
         this.mc_container.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.mc_container.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function updatePointsDisplay() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.txt_ptsReward.visible)
         {
            _loc1_ = 8;
            _loc2_ = this.txt_ptsTotal.width + _loc1_ + this.txt_ptsReward.width;
            this.txt_ptsTotal.x = int((this._contentWidth - _loc2_) * 0.5);
            this.txt_ptsReward.x = int(this.txt_ptsTotal.x + this.txt_ptsTotal.width + _loc1_);
         }
         else
         {
            this.txt_ptsTotal.x = int((this._contentWidth - this.txt_ptsTotal.width) * 0.5);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var absPts:Number;
         var pts:int = 0;
         var indiTotalPts:int = 0;
         var e:Event = param1;
         mc_icon.y += 4;
         mc_icon.filters = [];
         pts = this.success ? this._missionData.allianceAttackerWinPoints : this._missionData.allianceAttackerLosePoints;
         this.txt_ptsTotal.text = NumberFormatter.format(this._missionData.allianceScore,0);
         absPts = Math.abs(pts);
         if(absPts == 0)
         {
            this.txt_ptsReward.visible = false;
            this.txt_ptsReward.scaleX = this.txt_ptsReward.scaleY = 0;
            this.updatePointsDisplay();
            return;
         }
         this.txt_ptsReward.visible = true;
         this.txt_ptsReward.text = (pts < 0 ? "-" : "+") + NumberFormatter.format(absPts,0);
         indiTotalPts = this.success ? this._missionData.allianceIndiScore + this._missionData.allianceAttackerWinPoints : this._missionData.allianceIndiScore + this._missionData.allianceAttackerLosePoints;
         this.indiProgress.FadedValue = indiTotalPts;
         this.indiProgress.SolidValue = this._missionData.allianceIndiScore;
         this._tweenDummy.pts = pts;
         this._tweenDummy.indiValue = this._missionData.allianceIndiScore;
         TweenMax.from(this.txt_ptsReward,0.5,{
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeOut,
            "onUpdate":this.updatePointsDisplay,
            "onComplete":function():void
            {
               if(_disposed)
               {
                  return;
               }
               TweenMax.to(_tweenDummy,Math.max(pts / 20,0.25),{
                  "pts":0,
                  "indiValue":indiTotalPts,
                  "delay":1,
                  "ease":Linear.easeNone,
                  "onUpdate":function():void
                  {
                     txt_ptsTotal.text = NumberFormatter.format(Math.max(_missionData.allianceScore + (pts - _tweenDummy.pts),0),0);
                     var _loc1_:* = Math.abs(_tweenDummy.pts);
                     txt_ptsReward.text = _loc1_ == 0 ? "" : (pts < 0 ? "-" : "+") + NumberFormatter.format(_loc1_,0);
                     updatePointsDisplay();
                     indiProgress.SolidValue = _tweenDummy.indiValue;
                  },
                  "onComplete":function():void
                  {
                     if(_disposed)
                     {
                        return;
                     }
                     TweenMax.to(txt_ptsReward,0.05,{
                        "ease":Quad.easeOut,
                        "transformAroundCenter":{
                           "scaleX":0,
                           "scaleY":0
                        },
                        "onUpdate":updatePointsDisplay
                     });
                  }
               });
            }
         });
         this.updatePointsDisplay();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
   }
}

