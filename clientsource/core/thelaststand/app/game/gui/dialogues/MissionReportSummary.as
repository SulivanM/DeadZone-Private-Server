package thelaststand.app.game.gui.dialogues
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Global;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.gui.UIXPCounterBar;
   import thelaststand.app.game.gui.mission.UIResourceLootReport;
   import thelaststand.app.game.gui.tooltip.UIMissionXPTooltip;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class MissionReportSummary extends Sprite
   {
      
      private const RETURNING_FILTER:GlowFilter = new GlowFilter(new Color(Effects.COLOR_WARNING).adjustBrightness(0.25).RGB,1,4,4,10,1);
      
      private const RETURNED_FILTER:GlowFilter = new GlowFilter(new Color(Effects.COLOR_GREEN).adjustBrightness(0.25).RGB,1,4,4,10,1);
      
      private var _missionData:MissionData;
      
      private var _lang:Language;
      
      private var _width:int = 328;
      
      private var _spacing:int = 10;
      
      private var _xpCount:int;
      
      private var _levelCount:int;
      
      private var bmp_iconLoot:Bitmap;
      
      private var bmp_iconFuel:Bitmap;
      
      private var mc_bgOverviewArea:Shape;
      
      private var mc_bgLootArea:Shape;
      
      private var mc_bgSurvivorArea:Shape;
      
      private var mc_resultImage:UIImage;
      
      private var mc_imageOverlay:Shape;
      
      private var mc_loot:Sprite;
      
      private var mc_lootResources:UIResourceLootReport;
      
      private var mc_fuel:Sprite;
      
      private var mc_levelUp:Sprite;
      
      private var mc_injuries:Sprite;
      
      private var txt_missionArea:BodyTextField;
      
      private var txt_missionLevel:BodyTextField;
      
      private var txt_result:BodyTextField;
      
      private var txt_return:BodyTextField;
      
      private var txt_lootAmount:BodyTextField;
      
      private var txt_fuelAmount:BodyTextField;
      
      private var ui_xpCounter:UIXPCounterBar;
      
      private var ui_xpTooltip:UIMissionXPTooltip;
      
      public function MissionReportSummary(param1:MissionData)
      {
         super();
         this._missionData = param1;
         this._lang = Language.getInstance();
         if(!this._missionData.complete && this._missionData.returnTimer != null)
         {
            this._missionData.returnTimer.completed.addOnce(this.onMissionCompleted);
         }
         this.drawOverview();
         this.drawXP();
         this.drawLoot();
         this.drawSurvivors();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(this._missionData.returnTimer != null)
         {
            this._missionData.returnTimer.completed.remove(this.onMissionCompleted);
         }
         this._lang = null;
         this._missionData = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this.bmp_iconLoot != null)
         {
            this.bmp_iconLoot.bitmapData.dispose();
            this.bmp_iconLoot.bitmapData = null;
            this.bmp_iconLoot.filters = [];
         }
         if(this.bmp_iconFuel != null)
         {
            this.bmp_iconFuel.bitmapData.dispose();
            this.bmp_iconFuel.bitmapData = null;
            this.bmp_iconFuel.filters = [];
         }
         if(this.txt_fuelAmount != null)
         {
            this.txt_fuelAmount.dispose();
         }
         if(this.txt_lootAmount != null)
         {
            this.txt_lootAmount.dispose();
         }
         if(this.mc_lootResources != null)
         {
            this.mc_lootResources.dispose();
         }
         this.ui_xpCounter.dispose();
         TooltipManager.getInstance().removeAllFromParent(this.ui_xpCounter);
         if(this.ui_xpTooltip != null)
         {
            this.ui_xpTooltip.dispose();
         }
         this.txt_missionArea.dispose();
         this.txt_missionLevel.dispose();
         this.txt_result.dispose();
         this.txt_return.dispose();
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function drawOverview() : void
      {
         var _loc3_:String = null;
         var _loc4_:BitmapData = null;
         var _loc5_:AssignmentData = null;
         var _loc6_:* = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc1_:int = 110;
         this.mc_bgOverviewArea = new Shape();
         GraphicUtils.drawUIBlock(this.mc_bgOverviewArea.graphics,this._width,_loc1_);
         var _loc2_:Number = 1;
         if(this._missionData.highActivityIndex > -1)
         {
            _loc4_ = new BmpRedHazardTile();
            this.mc_bgOverviewArea.graphics.beginBitmapFill(_loc4_,null,true);
            this.mc_bgOverviewArea.graphics.drawRect(3,3,this._width - 6,22);
            this.mc_bgOverviewArea.graphics.endFill();
            _loc2_ = 0.5;
         }
         this.mc_bgOverviewArea.graphics.beginFill(1381653,_loc2_);
         this.mc_bgOverviewArea.graphics.drawRect(3,3,this._width - 6,22);
         this.mc_bgOverviewArea.graphics.endFill();
         addChild(this.mc_bgOverviewArea);
         this.mc_resultImage = new UIImage(width - 6,80,0,0,true);
         this.mc_resultImage.x = 3;
         this.mc_resultImage.y = 27;
         addChild(this.mc_resultImage);
         if(this._missionData.assignmentId)
         {
            _loc5_ = Network.getInstance().playerData.assignments.getById(this._missionData.assignmentId) || Global.completedAssignment;
            _loc6_ = _loc5_.type.toLowerCase() + ".";
            _loc7_ = Language.getInstance().getString(_loc6_ + _loc5_.name + ".name");
            _loc8_ = Language.getInstance().getString(_loc6_ + _loc5_.name + ".stage_" + _loc5_.getStage(_loc5_.currentStageIndex).stageXml.@id.toString());
            _loc3_ = (_loc7_ + " - " + _loc8_).toUpperCase();
         }
         else if(this._missionData.opponent.isPlayer)
         {
            _loc3_ = this._lang.getString("locations.compound_raid",this._missionData.opponent.nickname).toUpperCase();
         }
         else
         {
            _loc3_ = this._lang.getString("locations." + this._missionData.type,this._lang.getString("suburbs." + this._missionData.suburb)).toUpperCase();
         }
         this.txt_missionArea = new BodyTextField({
            "text":_loc3_,
            "color":10066329,
            "size":14,
            "bold":true,
            "maxWidth":270
         });
         this.txt_missionArea.text = _loc3_;
         this.txt_missionArea.x = 6;
         this.txt_missionArea.y = int(3 + (22 - this.txt_missionArea.height) * 0.5);
         addChild(this.txt_missionArea);
         this.txt_missionLevel = new BodyTextField({
            "text":this._lang.getString("lvl",this._missionData.opponent.level + 1),
            "color":12026112,
            "bold":true,
            "size":14
         });
         this.txt_missionLevel.y = int(this.txt_missionArea.y);
         this.txt_missionLevel.x = int(this._width - this.txt_missionLevel.width - 6);
         addChild(this.txt_missionLevel);
         this.mc_imageOverlay = new Shape();
         this.mc_imageOverlay.x = 3;
         this.mc_imageOverlay.y = this.mc_resultImage.y + this.mc_resultImage.height - 22;
         this.mc_imageOverlay.graphics.beginFill(0,0.7);
         this.mc_imageOverlay.graphics.drawRect(0,0,this.mc_resultImage.width,22);
         this.mc_imageOverlay.graphics.endFill();
         addChild(this.mc_imageOverlay);
         this.txt_result = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         addChild(this.txt_result);
         this.updateResultField();
         this.txt_return = new BodyTextField({
            "color":13381383,
            "size":14,
            "bold":true
         });
         this.txt_return.text = " ";
         this.txt_return.x = int(this.mc_resultImage.x + this.mc_resultImage.width - this.txt_return.width - 3);
         this.txt_return.y = this.txt_result.y;
         addChild(this.txt_return);
      }
      
      private function drawXP() : void
      {
         var _loc1_:int = 26;
         var _loc2_:int = this.mc_bgOverviewArea.y + this.mc_bgOverviewArea.height + this._spacing + 20;
         this.ui_xpCounter = new UIXPCounterBar(this._width,_loc1_);
         this.ui_xpCounter.x = 0;
         this.ui_xpCounter.y = _loc2_;
         addChild(this.ui_xpCounter);
         if(!this._missionData.automated && !this._missionData.isPvPPractice && this._missionData.xpBreakdown != null && Boolean(this._missionData.xpBreakdown.hasOwnProperty("total")))
         {
            this.ui_xpTooltip = new UIMissionXPTooltip();
            this.ui_xpTooltip.data = this._missionData.xpBreakdown;
            TooltipManager.getInstance().add(this.ui_xpCounter,this.ui_xpTooltip,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
      }
      
      private function drawLoot() : void
      {
         var _loc7_:Item = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:BodyTextField = null;
         var _loc11_:BodyTextField = null;
         var _loc12_:XML = null;
         var _loc13_:String = null;
         var _loc1_:int = 75;
         var _loc2_:int = this.ui_xpCounter.y + this.ui_xpCounter.height + this._spacing;
         if(this.mc_bgLootArea == null)
         {
            this.mc_bgLootArea = new Shape();
            GraphicUtils.drawUIBlock(this.mc_bgLootArea.graphics,this._width,_loc1_);
            this.mc_bgLootArea.x = 0;
            this.mc_bgLootArea.y = _loc2_;
            addChild(this.mc_bgLootArea);
         }
         if(this._missionData.type == "compound")
         {
            _loc10_ = new BodyTextField({
               "color":16777215,
               "size":13,
               "bold":true
            });
            _loc10_.name = "txt_loot";
            _loc10_.text = this._lang.getString("mission_report_noloot").toUpperCase();
            _loc10_.x = int(this.mc_bgLootArea.x + (this.mc_bgLootArea.width - _loc10_.width) * 0.5);
            _loc10_.y = int(this.mc_bgLootArea.y + (this.mc_bgLootArea.height - _loc10_.height) * 0.5);
            addChild(_loc10_);
            return;
         }
         if(!this._missionData.complete)
         {
            _loc11_ = new BodyTextField({
               "color":16777215,
               "size":13,
               "bold":true
            });
            _loc11_.name = "txt_loot";
            _loc11_.text = this._lang.getString("mission_report_unknown_loot").toUpperCase();
            _loc11_.x = int(this.mc_bgLootArea.x + (this.mc_bgLootArea.width - _loc11_.width) * 0.5);
            _loc11_.y = int(this.mc_bgLootArea.y + (this.mc_bgLootArea.height - _loc11_.height) * 0.5);
            addChild(_loc11_);
            return;
         }
         if(getChildByName("txt_loot") != null)
         {
            removeChild(getChildByName("txt_loot"));
         }
         var _loc3_:int = 6;
         var _loc4_:int = 28;
         this.mc_bgLootArea.graphics.beginFill(3750201);
         this.mc_bgLootArea.graphics.drawRect(_loc3_,_loc3_,this._width - _loc3_ * 2,_loc4_);
         this.mc_bgLootArea.graphics.endFill();
         var _loc5_:Dictionary = new Dictionary(true);
         var _loc6_:Array = GameResources.getResourceList();
         for each(_loc7_ in this._missionData.loot)
         {
            if(_loc7_.category == "resource")
            {
               for each(_loc12_ in _loc7_.xml.res.res)
               {
                  _loc13_ = _loc12_.@id.toString();
                  if(_loc5_[_loc13_] == null)
                  {
                     _loc5_[_loc13_] = 0;
                  }
                  _loc5_[_loc13_] += int(_loc12_.toString()) * _loc7_.quantity;
               }
            }
            else
            {
               if(_loc5_.loot == null)
               {
                  _loc5_.loot = 0;
               }
               ++_loc5_.loot;
            }
         }
         this.mc_lootResources = new UIResourceLootReport(_loc5_);
         this.mc_lootResources.x = int(_loc3_ + 10);
         this.mc_lootResources.width = int(this._width - _loc3_ * 2 - this.mc_lootResources.x - _loc3_);
         this.mc_lootResources.scaleY = this.mc_lootResources.scaleX;
         addChild(this.mc_lootResources);
         this.mc_lootResources.y = int(_loc2_ + _loc3_ + _loc4_ * 0.5);
         _loc8_ = this._width * 0.5;
         _loc9_ = 20;
         this.mc_loot = new Sprite();
         this.bmp_iconLoot = new Bitmap(new BmpIconLoot(),"auto",true);
         this.bmp_iconLoot.filters = [Effects.ICON_SHADOW];
         this.mc_loot.addChild(this.bmp_iconLoot);
         this.txt_lootAmount = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         this.txt_lootAmount.text = this._lang.getString("mission_report_num_loot",isNaN(_loc5_.loot) ? 0 : _loc5_.loot);
         this.txt_lootAmount.filters = [Effects.STROKE];
         this.txt_lootAmount.x = int(this.bmp_iconLoot.x + this.bmp_iconLoot.width + 2);
         this.txt_lootAmount.y = int(this.bmp_iconLoot.y + (this.bmp_iconLoot.height - this.txt_lootAmount.height) * 0.5);
         this.mc_loot.addChild(this.txt_lootAmount);
         this.mc_loot.x = int(_loc9_ + (_loc8_ - this.mc_loot.width) * 0.5);
         this.mc_loot.y = int(_loc2_ + _loc3_ + _loc4_ + (_loc1_ - _loc4_ - _loc3_ * 2 - this.mc_loot.height) * 0.5) + 2;
         addChild(this.mc_loot);
         this.mc_fuel = new Sprite();
         this.bmp_iconFuel = new Bitmap(new BmpIconFuel(),"auto",true);
         this.bmp_iconFuel.scaleX = this.bmp_iconFuel.scaleY = 0.8;
         this.bmp_iconFuel.filters = [Effects.ICON_SHADOW];
         this.mc_fuel.addChild(this.bmp_iconFuel);
         this.txt_fuelAmount = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         this.txt_fuelAmount.text = this._lang.getString("mission_report_num_fuel",isNaN(_loc5_[GameResources.CASH]) ? 0 : _loc5_[GameResources.CASH]);
         this.txt_fuelAmount.filters = [Effects.STROKE.clone()];
         this.txt_fuelAmount.x = int(this.bmp_iconFuel.x + this.bmp_iconFuel.width + 2);
         this.txt_fuelAmount.y = int(this.bmp_iconFuel.y + (this.bmp_iconFuel.height - this.txt_fuelAmount.height) * 0.5);
         this.mc_fuel.addChild(this.txt_fuelAmount);
         this.mc_fuel.x = int(_loc8_ - _loc9_ + (_loc8_ - this.mc_fuel.width) * 0.5);
         this.mc_fuel.y = int(_loc2_ + _loc3_ + _loc4_ + (_loc1_ - _loc4_ - _loc3_ * 2 - this.mc_fuel.height) * 0.5) + 2;
         addChild(this.mc_fuel);
      }
      
      private function animateLoot(param1:Number = 0) : void
      {
         if(this._missionData.type == "compound")
         {
            return;
         }
         this.mc_lootResources.transitionIn(param1);
         TweenMax.from(this.mc_loot,0.5,{
            "delay":param1,
            "alpha":0,
            "transformAroundCenter":{
               "scaleX":0.75,
               "scaleY":0.75
            }
         });
         TweenMax.from(this.mc_fuel,0.5,{
            "delay":param1,
            "alpha":0,
            "transformAroundCenter":{
               "scaleX":0.75,
               "scaleY":0.75
            }
         });
      }
      
      private function drawSurvivors() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:Survivor = null;
         var _loc6_:Bitmap = null;
         var _loc7_:BodyTextField = null;
         var _loc8_:Bitmap = null;
         var _loc9_:BodyTextField = null;
         var _loc10_:BodyTextField = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         _loc1_ = 33;
         _loc2_ = this.mc_bgLootArea.y + this.mc_bgLootArea.height + this._spacing;
         if(this.mc_bgSurvivorArea == null)
         {
            this.mc_bgSurvivorArea = new Shape();
            GraphicUtils.drawUIBlock(this.mc_bgSurvivorArea.graphics,this._width,_loc1_);
            this.mc_bgSurvivorArea.x = 0;
            this.mc_bgSurvivorArea.y = _loc2_;
            addChild(this.mc_bgSurvivorArea);
         }
         if(!this._missionData.complete)
         {
            _loc10_ = new BodyTextField({
               "color":16777215,
               "size":13,
               "bold":true
            });
            _loc10_.name = "txt_srv_unknown";
            _loc10_.text = this._lang.getString("mission_report_unknown_srv").toUpperCase();
            _loc10_.x = int(this.mc_bgSurvivorArea.x + (this.mc_bgSurvivorArea.width - _loc10_.width) * 0.5);
            _loc10_.y = int(this.mc_bgSurvivorArea.y + (this.mc_bgSurvivorArea.height - _loc10_.height) * 0.5);
            addChild(_loc10_);
            return;
         }
         if(getChildByName("txt_srv_unknown") != null)
         {
            removeChild(getChildByName("txt_srv_unknown"));
         }
         var _loc4_:int = int(this._missionData.survivorsDowned.length);
         for each(_loc5_ in this._missionData.survivors)
         {
            _loc11_ = this._missionData.getSurvivorData(_loc5_).startLevel;
            _loc12_ = this._missionData.getSurvivorData(_loc5_).endLevel;
            if(_loc12_ > _loc11_)
            {
               _loc3_ += _loc12_ - _loc11_;
            }
         }
         this.mc_levelUp = new Sprite();
         addChild(this.mc_levelUp);
         _loc6_ = new Bitmap(new BmpIconLevelUps());
         this.mc_levelUp.addChild(_loc6_);
         _loc7_ = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         _loc7_.text = this._lang.getString("mission_report_leveled_up",_loc3_);
         _loc7_.x = int(_loc6_.x + _loc6_.width + 4);
         _loc7_.y = int(_loc6_.y + (_loc6_.height - _loc7_.height) * 0.5);
         this.mc_levelUp.addChild(_loc7_);
         this.mc_injuries = new Sprite();
         addChild(this.mc_injuries);
         _loc8_ = new Bitmap(new BmpIconInjuries());
         this.mc_injuries.addChild(_loc8_);
         _loc9_ = new BodyTextField({
            "color":(_loc4_ > 0 ? Effects.COLOR_WARNING : 16777215),
            "size":14,
            "bold":true
         });
         _loc9_.text = this._lang.getString("mission_report_injuries",_loc4_);
         _loc9_.x = int(_loc8_.x + _loc8_.width + 4);
         _loc9_.y = int(_loc8_.y + (_loc8_.height - _loc9_.height) * 0.5);
         this.mc_injuries.addChild(_loc9_);
         this.mc_levelUp.x = 8;
         this.mc_levelUp.y = Math.round(_loc2_ + (_loc1_ - this.mc_levelUp.height) * 0.5);
         this.mc_injuries.x = int(this._width - 6 - this.mc_injuries.width);
         this.mc_injuries.y = Math.round(_loc2_ + (_loc1_ - this.mc_injuries.height) * 0.5);
      }
      
      private function animateSurvivors(param1:Number = 0) : void
      {
         TweenMax.from(this.mc_levelUp,0.5,{
            "delay":param1,
            "alpha":0,
            "transformAroundCenter":{
               "scaleX":0.75,
               "scaleY":0.75
            }
         });
         TweenMax.from(this.mc_injuries,0.5,{
            "delay":param1 + 0.25,
            "alpha":0,
            "transformAroundCenter":{
               "scaleX":0.75,
               "scaleY":0.75
            }
         });
      }
      
      private function animateXP() : void
      {
         this.ui_xpCounter.levelMax = Network.getInstance().playerData.getPlayerSurvivor().levelMax;
         this.ui_xpCounter.xpTotal = this._missionData.xpEarned;
         this.ui_xpCounter.startXP = this._missionData.getPlayerSurvivorData().startXP;
         this.ui_xpCounter.startLevel = this._missionData.getPlayerSurvivorData().startLevel;
         this.ui_xpCounter.endXP = this._missionData.getPlayerSurvivorData().endXP;
         this.ui_xpCounter.endLevel = this._missionData.getPlayerSurvivorData().endLevel;
         this.ui_xpCounter.animate();
      }
      
      private function updateResultField() : void
      {
         var _loc1_:Boolean = this._missionData.type == "compound" || this._missionData.complete;
         var _loc2_:uint = !_loc1_ ? Effects.COLOR_NEUTRAL : Effects.COLOR_GREEN;
         var _loc3_:String = _loc1_ ? "complete" : "inprogress";
         this.txt_result.text = this._lang.getString("mission_report_" + _loc3_).toUpperCase();
         this.txt_result.textColor = _loc2_;
         this.txt_result.x = int(this.mc_resultImage.x + 3);
         this.txt_result.y = int(this.mc_imageOverlay.y + (this.mc_imageOverlay.height - this.txt_result.height) * 0.5);
         this.txt_result.filters = [new GlowFilter(_loc2_,0.1,4,4,10,1)];
      }
      
      private function getImageURI() : String
      {
         var _loc1_:String = "complete";
         if(this._missionData.type == "compound")
         {
            _loc1_ = "complete";
         }
         else if(!this._missionData.complete)
         {
            _loc1_ = "inprogress";
         }
         else if(this._missionData.survivorsDowned.length > 0)
         {
            _loc1_ = "injury";
         }
         return "images/ui/mission-" + _loc1_ + ".jpg";
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.mc_resultImage.uri = this.getImageURI();
         TweenMax.from(this.txt_result,1,{
            "alpha":0,
            "ease":Linear.easeNone
         });
         TweenMax.from(this.txt_return,1,{
            "delay":0.25,
            "alpha":0,
            "ease":Linear.easeNone
         });
         this.animateXP();
         if(this._missionData.complete)
         {
            this.animateLoot(0.5);
            this.animateSurvivors(0.75);
         }
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this.onEnterFrame(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         TweenMax.killDelayedCallsTo(this.animateXP);
         TweenMax.killChildTweensOf(this,true);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Object = null;
         if(this._missionData.returnTimer == null || this._missionData.returnTimer.hasEnded())
         {
            if(this.txt_return.parent != null)
            {
               this.txt_return.parent.removeChild(this.txt_return);
            }
            this.updateResultField();
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            return;
         }
         _loc2_ = this._missionData.returnTimer.getTimeRemaining();
         var _loc3_:String = DateTimeUtils.timeDataToString(_loc2_,true,true);
         this.txt_return.text = this._lang.getString("mission_report_return_time",_loc3_);
         this.txt_return.textColor = Effects.COLOR_WARNING;
         this.txt_return.x = int(this.mc_resultImage.x + this.mc_resultImage.width - this.txt_return.width);
         this.txt_return.filters = [this.RETURNING_FILTER];
      }
      
      private function onMissionCompleted(param1:TimerData) : void
      {
         this.mc_resultImage.uri = this.getImageURI();
         this.drawLoot();
         this.drawSurvivors();
         this.animateLoot();
         this.animateSurvivors(0.25);
      }
   }
}

