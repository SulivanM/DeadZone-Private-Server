package thelaststand.app.game.gui.bounty
{
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.bounty.InfectedBountyTaskCondition;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIBountyInfectedConditionList extends UIComponent
   {
      
      private const _maxRows:int = 3;
      
      private const _rowHeight:int = 32;
      
      private const _rowSpacing:int = 2;
      
      private const _titleSpacing:int = 5;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _rows:Vector.<UIBountyInfectedConditionRow>;
      
      private var _task:InfectedBountyTask;
      
      private var txt_title:BodyTextField;
      
      public function UIBountyInfectedConditionList()
      {
         var _loc2_:UIBountyInfectedConditionRow = null;
         super();
         this.txt_title = new BodyTextField({
            "color":13882323,
            "size":12,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.text = Language.getInstance().getString("bounty.infected_task_requirements");
         addChild(this.txt_title);
         this._height = int(this.txt_title.height + this._titleSpacing + this._rowHeight * this._maxRows + this._rowSpacing * (this._maxRows - 1));
         this._rows = new Vector.<UIBountyInfectedConditionRow>(this._maxRows);
         var _loc1_:int = 0;
         while(_loc1_ < this._maxRows)
         {
            _loc2_ = new UIBountyInfectedConditionRow();
            addChild(_loc2_);
            this._rows[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      public function get task() : InfectedBountyTask
      {
         return this._task;
      }
      
      public function set task(param1:InfectedBountyTask) : void
      {
         this._task = param1;
         invalidate();
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
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIBountyInfectedConditionRow = null;
         super.dispose();
         this.txt_title.dispose();
         for each(_loc1_ in this._rows)
         {
            _loc1_.dispose();
         }
         this._task = null;
      }
      
      override protected function draw() : void
      {
         var _loc3_:UIBountyInfectedConditionRow = null;
         this.txt_title.x = 0;
         this.txt_title.y = 0;
         var _loc1_:int = this.txt_title.y + this.txt_title.height + this._titleSpacing;
         var _loc2_:int = 0;
         while(_loc2_ < this._rows.length)
         {
            _loc3_ = this._rows[_loc2_];
            _loc3_.height = this._rowHeight;
            _loc3_.width = this._width;
            _loc3_.x = 0;
            _loc3_.y = _loc1_;
            _loc3_.condition = this._task != null ? this._task.getCondition(_loc2_) : null;
            _loc3_.redraw();
            _loc1_ += int(this._rowHeight + this._rowSpacing);
            _loc2_++;
         }
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.bounty.InfectedBountyTaskCondition;
import thelaststand.app.gui.UIComponent;
import thelaststand.common.lang.Language;

class UIBountyInfectedConditionRow extends UIComponent
{
   
   private static const _rowColor:uint = 1447446;
   
   private static const _stateAreaIncompleteColor:uint = 855309;
   
   private static const _stateAreaCompleteColor:uint = 3358494;
   
   private static const _stateAreaWidth:int = 32;
   
   private static const _textIncompleteColor:uint = 13882323;
   
   private static const _textCompleteColor:uint = 9360403;
   
   private static const _textPadding:int = 6;
   
   private var _width:int;
   
   private var _height:int;
   
   private var _condition:InfectedBountyTaskCondition;
   
   private var bmp_complete:Bitmap;
   
   private var txt_condition:BodyTextField;
   
   private var txt_progress:BodyTextField;
   
   public function UIBountyInfectedConditionRow()
   {
      super();
      this.bmp_complete = new Bitmap(new BmpIconTradeTickGreen());
      this.txt_condition = new BodyTextField({
         "color":_textIncompleteColor,
         "size":15,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_condition.text = "Kill all the infected everywhere";
      this.txt_progress = new BodyTextField({
         "color":_textIncompleteColor,
         "size":15,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
   }
   
   public function get condition() : InfectedBountyTaskCondition
   {
      return this._condition;
   }
   
   public function set condition(param1:InfectedBountyTaskCondition) : void
   {
      if(this._condition != null)
      {
         this._condition.completed.remove(this.onConditionCompleted);
         this._condition.killsChanged.remove(this.onConditionKillsChanged);
         this._condition = null;
      }
      this._condition = param1;
      if(this._condition != null)
      {
         this._condition.completed.addOnce(this.onConditionCompleted);
         this._condition.killsChanged.add(this.onConditionKillsChanged);
      }
      invalidate();
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = Math.max(_stateAreaWidth,param1);
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
      if(this._condition != null)
      {
         this._condition.completed.remove(this.onConditionCompleted);
         this._condition.killsChanged.remove(this.onConditionKillsChanged);
         this._condition = null;
      }
      this.bmp_complete.bitmapData.dispose();
      this.txt_condition.dispose();
      this.txt_progress.dispose();
   }
   
   override protected function draw() : void
   {
      graphics.clear();
      graphics.beginFill(this._condition != null && Boolean(this._condition.isComplete) ? uint(_stateAreaCompleteColor) : uint(_stateAreaIncompleteColor),1);
      graphics.drawRect(0,0,_stateAreaWidth,this._height);
      graphics.endFill();
      graphics.beginFill(_rowColor,1);
      graphics.drawRect(_stateAreaWidth,0,this._width - _stateAreaWidth,this._height);
      graphics.endFill();
      if(this._condition == null)
      {
         if(this.bmp_complete.parent != null)
         {
            this.bmp_complete.parent.removeChild(this.bmp_complete);
         }
         if(this.txt_condition.parent != null)
         {
            this.txt_condition.parent.removeChild(this.txt_condition);
         }
      }
      else
      {
         addChild(this.bmp_complete);
         this.bmp_complete.x = int((_stateAreaWidth - this.bmp_complete.width) * 0.5);
         this.bmp_complete.y = int((this._height - this.bmp_complete.height) * 0.5);
         this.bmp_complete.filters = this._condition.isComplete ? [] : [Effects.GREYSCALE.filter];
         this.bmp_complete.alpha = this._condition.isComplete ? 1 : 0.3;
         addChild(this.txt_condition);
         this.txt_condition.x = int(_stateAreaWidth + _textPadding);
         this.txt_condition.y = int((this._height - this.txt_condition.height) * 0.5);
         this.txt_condition.maxWidth = int(this.txt_condition.x - _stateAreaWidth - _textPadding);
         this.txt_condition.textColor = this._condition.isComplete ? uint(_textCompleteColor) : uint(_textIncompleteColor);
         this.txt_condition.text = Language.getInstance().getString("bounty.infected_task_kill",Language.getInstance().getString("zombie_types." + this._condition.zombieType),Language.getInstance().getString("suburbs." + this._condition.suburb));
      }
      this.updateProgress();
   }
   
   private function updateProgress() : void
   {
      if(this._condition == null)
      {
         if(this.txt_progress.parent != null)
         {
            this.txt_progress.parent.removeChild(this.txt_progress);
         }
         return;
      }
      var _loc1_:String = NumberFormatter.format(this._condition.kills,0);
      var _loc2_:String = NumberFormatter.format(this._condition.killsRequired,0);
      this.txt_progress.visible = true;
      this.txt_progress.text = _loc1_ + " / " + _loc2_;
      this.txt_progress.x = int(this._width - this.txt_progress.width) - _textPadding;
      this.txt_progress.y = int((this._height - this.txt_progress.height) * 0.5);
      this.txt_progress.textColor = this._condition.isComplete ? uint(_textCompleteColor) : uint(_textIncompleteColor);
      addChild(this.txt_progress);
   }
   
   private function onConditionCompleted(param1:InfectedBountyTaskCondition) : void
   {
      invalidate();
   }
   
   private function onConditionKillsChanged(param1:InfectedBountyTaskCondition) : void
   {
      this.updateProgress();
   }
}
