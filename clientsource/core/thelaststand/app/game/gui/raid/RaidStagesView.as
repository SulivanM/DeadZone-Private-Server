package thelaststand.app.game.gui.raid
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.assignment.AssignmentStageState;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.data.raid.RaidStageData;
   import thelaststand.app.game.data.raid.RaidStageObjectiveState;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class RaidStagesView extends UIComponent
   {
      
      private const PADDING:int = 10;
      
      private var _raidData:RaidData;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _stageButtons:Vector.<UIRaidStageButton>;
      
      private var _stageObjectiveList:Vector.<StageObjectiveRow>;
      
      private var _selectedButton:UIRaidStageButton;
      
      private var _selectedStageIndex:int;
      
      private var ui_title:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var mc_objectives:Sprite;
      
      public function RaidStagesView()
      {
         var _loc2_:StageObjectiveRow = null;
         super();
         this._stageButtons = new Vector.<UIRaidStageButton>();
         this.ui_title = new UITitleBar(null,RaidDialogue.COLOR);
         this.ui_title.filters = [Effects.TEXT_SHADOW_DARK];
         this.ui_title.height = 32;
         this.ui_title.x = 3;
         this.ui_title.y = 3;
         addChild(this.ui_title);
         this.txt_title = new BodyTextField({
            "color":16747020,
            "size":18,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.text = Language.getInstance().getString("raid.missionobjs").toUpperCase();
         addChild(this.txt_title);
         this.mc_objectives = new Sprite();
         addChild(this.mc_objectives);
         this._stageObjectiveList = new Vector.<StageObjectiveRow>(2);
         var _loc1_:int = 0;
         while(_loc1_ < this._stageObjectiveList.length)
         {
            _loc2_ = new StageObjectiveRow();
            this.mc_objectives.addChild(_loc2_);
            this._stageObjectiveList[_loc1_] = _loc2_;
            _loc1_++;
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
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
      
      public function setData(param1:RaidData) : void
      {
         this._raidData = param1;
         this._raidData.survivorsChanged.add(this.onRaidSurvivorsChanged);
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._raidData.survivorsChanged.remove(this.onRaidSurvivorsChanged);
         this._raidData = null;
      }
      
      private function disposeButtons() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._stageButtons.length)
         {
            this._stageButtons[_loc1_].dispose();
            _loc1_++;
         }
         this._stageButtons.length = 0;
      }
      
      override protected function draw() : void
      {
         var _loc7_:UIRaidStageButton = null;
         this.disposeButtons();
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_title.width = this._width - this.ui_title.x * 2;
         this.txt_title.x = int(this.ui_title.x + (this.ui_title.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.ui_title.y + (this.ui_title.height - this.txt_title.height) * 0.5);
         var _loc1_:int = this._width - this.PADDING * 2 - (this._raidData.stageCount - 1) * this.PADDING;
         var _loc2_:int = _loc1_ / this._raidData.stageCount;
         var _loc3_:int = 158;
         var _loc4_:int = this.PADDING;
         var _loc5_:int = int(this.ui_title.y + this.ui_title.height + this.PADDING);
         var _loc6_:int = 0;
         while(_loc6_ < this._raidData.stageCount)
         {
            _loc7_ = new UIRaidStageButton();
            _loc7_.setData(this._raidData.getRaidStage(_loc6_));
            _loc7_.width = _loc2_;
            _loc7_.height = _loc3_;
            _loc7_.x = _loc4_;
            _loc7_.y = _loc5_;
            _loc7_.clicked.add(this.onClickStageButton);
            addChild(_loc7_);
            this._stageButtons.push(_loc7_);
            _loc4_ += int(_loc7_.width + this.PADDING);
            _loc6_++;
         }
         this.displayStageObjectives(this._selectedStageIndex);
      }
      
      private function displayStageObjectives(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc6_:StageObjectiveRow = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:RaidStageData = this._raidData.getRaidStage(param1);
         _loc3_ = 4;
         this.mc_objectives.x = this.PADDING;
         this.mc_objectives.y = int(this._height - this.PADDING - (this._stageObjectiveList.length * (StageObjectiveRow.HEIGHT + _loc3_) - _loc3_));
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < this._stageObjectiveList.length)
         {
            _loc6_ = this._stageObjectiveList[_loc5_];
            _loc6_.width = int(this._width - this.PADDING * 2);
            _loc6_.x = 0;
            _loc6_.y = _loc4_;
            if(_loc5_ == 0)
            {
               _loc7_ = this._raidData.maxSurvivorCount;
               _loc8_ = this._raidData.maxSurvivorMissionPoints;
               if(_loc2_.state == AssignmentStageState.COMPLETE)
               {
                  _loc7_ = _loc2_.survivorCount;
                  _loc8_ = _loc7_ * this._raidData.pointsPerSurvivor;
               }
               else if(this._raidData.survivorIds.length > 0)
               {
                  _loc7_ = int(this._raidData.survivorIds.length);
                  _loc8_ = _loc7_ * this._raidData.pointsPerSurvivor;
               }
               _loc6_.label = Language.getInstance().getString("raid.obj_survivors",NumberFormatter.format(_loc7_,0));
               _loc6_.points = _loc8_;
               _loc6_.state = _loc2_.state == AssignmentStageState.COMPLETE ? RaidStageObjectiveState.COMPLETE : RaidStageObjectiveState.INCOMPLETE;
            }
            else if(_loc2_.state == AssignmentStageState.COMPLETE)
            {
               _loc6_.label = Language.getInstance().getString("raid." + this._raidData.name + ".obj_" + _loc2_.objectiveXML.lang.toString());
               _loc6_.points = _loc2_.objectiveState == RaidStageObjectiveState.FAILED ? 0 : _loc2_.objectivePoints;
               _loc6_.state = _loc2_.objectiveState;
            }
            else
            {
               _loc6_.label = Language.getInstance().getString("raid.obj_unknown");
               _loc6_.points = 0;
               _loc6_.state = RaidStageObjectiveState.INCOMPLETE;
            }
            _loc4_ += int(_loc6_.height + 4);
            _loc5_++;
         }
      }
      
      public function selectStage(param1:int) : void
      {
         if(this._selectedButton != null)
         {
            this._selectedButton.selected = false;
            this._selectedButton = null;
         }
         this._selectedStageIndex = param1;
         this._selectedButton = this._stageButtons[this._selectedStageIndex];
         this._selectedButton.selected = true;
         if(!isInvalid)
         {
            this.displayStageObjectives(this._selectedStageIndex);
         }
      }
      
      private function selectStageById(param1:String) : void
      {
         var _loc3_:UIRaidStageButton = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._stageButtons.length)
         {
            _loc3_ = this._stageButtons[_loc2_];
            if(RaidStageData(_loc3_.data).name == param1)
            {
               this.selectStage(_loc2_);
               break;
            }
            _loc2_++;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.selectStage(this._selectedStageIndex);
      }
      
      private function onClickStageButton(param1:MouseEvent) : void
      {
         var _loc2_:UIRaidStageButton = UIRaidStageButton(param1.currentTarget);
         var _loc3_:int = int(this._stageButtons.indexOf(_loc2_));
         if(_loc3_ > -1)
         {
            this.selectStage(_loc3_);
         }
      }
      
      private function onRaidSurvivorsChanged() : void
      {
         this.displayStageObjectives(this._selectedStageIndex);
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.raid.RaidStageObjectiveState;
import thelaststand.app.gui.UIComponent;
import thelaststand.common.lang.Language;

class StageObjectiveRow extends UIComponent
{
   
   public static const HEIGHT:int = 28;
   
   private var _width:int;
   
   private var _label:String;
   
   private var _points:int;
   
   private var _state:uint = 0;
   
   private var _bmd_check:BitmapData = new BmpIconTradeTickGreen();
   
   private var _bmd_fail:BitmapData = new BmpIconTradeCrossRed();
   
   private var txt_label:BodyTextField;
   
   private var txt_points:BodyTextField;
   
   private var bmp_check:Bitmap;
   
   public function StageObjectiveRow()
   {
      super();
      this.bmp_check = new Bitmap(this._bmd_check,"auto",false);
      addChild(this.bmp_check);
      this.txt_label = new BodyTextField({
         "text":" ",
         "color":13882323,
         "bold":true,
         "size":15,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addChild(this.txt_label);
      this.txt_points = new BodyTextField({
         "text":" ",
         "color":13882323,
         "bold":true,
         "size":15,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addChild(this.txt_points);
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
      return HEIGHT;
   }
   
   override public function set height(param1:Number) : void
   {
   }
   
   public function get label() : String
   {
      return this._label;
   }
   
   public function set label(param1:String) : void
   {
      this._label = param1;
      invalidate();
   }
   
   public function get points() : int
   {
      return this._points;
   }
   
   public function set points(param1:int) : void
   {
      this._points = param1;
      invalidate();
   }
   
   public function get state() : uint
   {
      return this._state;
   }
   
   public function set state(param1:uint) : void
   {
      this._state = param1;
      invalidate();
   }
   
   override public function dispose() : void
   {
      super.dispose();
      this._bmd_check.dispose();
      this._bmd_fail.dispose();
      this.txt_label.dispose();
      this.txt_points.dispose();
      this.bmp_check.bitmapData = null;
   }
   
   override protected function draw() : void
   {
      var _loc1_:int = 0;
      graphics.clear();
      graphics.beginFill(460551);
      graphics.drawRect(0,0,this._width,HEIGHT);
      graphics.endFill();
      switch(this._state)
      {
         case RaidStageObjectiveState.COMPLETE:
            graphics.beginFill(3358494);
            this.bmp_check.bitmapData = this._bmd_check;
            this.bmp_check.filters = [];
            this.bmp_check.transform.colorTransform = Effects.CT_DEFAULT;
            this.bmp_check.visible = true;
            this.txt_label.textColor = this.txt_points.textColor = 9360403;
            break;
         case RaidStageObjectiveState.FAILED:
            graphics.beginFill(4136478);
            this.bmp_check.bitmapData = this._bmd_fail;
            this.bmp_check.filters = [];
            this.bmp_check.transform.colorTransform = Effects.CT_WARNING;
            this.bmp_check.visible = true;
            this.txt_label.textColor = this.txt_points.textColor = 16068399;
            break;
         case RaidStageObjectiveState.INCOMPLETE:
         default:
            graphics.beginFill(855309);
            this.bmp_check.bitmapData = this._bmd_check;
            this.bmp_check.visible = false;
            this.txt_label.textColor = this.txt_points.textColor = 13882323;
      }
      _loc1_ = int(HEIGHT);
      graphics.drawRect(0,0,_loc1_,_loc1_);
      graphics.endFill();
      this.bmp_check.x = int((_loc1_ - this.bmp_check.width) * 0.5);
      this.bmp_check.y = int((_loc1_ - this.bmp_check.height) * 0.5);
      this.txt_points.text = this._points > 0 ? "+" + NumberFormatter.format(this._points,0) + " " + Language.getInstance().getString("raid.rp") : "";
      this.txt_points.x = int(this._width - this.txt_points.width - 8);
      this.txt_points.y = int((HEIGHT - this.txt_points.height) * 0.5);
      this.txt_label.x = int(_loc1_ + 8);
      this.txt_label.y = int((HEIGHT - this.txt_label.height) * 0.5);
      this.txt_label.maxWidth = int(this.txt_points.x - this.txt_label.x - 8);
      this.txt_label.text = this._label;
   }
}
