package thelaststand.app.game.gui.quest
{
   import com.exileetiquette.utils.NumberFormatter;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.bounty.InfectedBountyTaskCondition;
   import thelaststand.common.lang.Language;
   
   public class UIQuestTrackerBountyItem extends UIQuestTrackerItem
   {
      
      private var _task:InfectedBountyTask;
      
      public function UIQuestTrackerBountyItem(param1:InfectedBountyTask)
      {
         var _loc3_:InfectedBountyTaskCondition = null;
         super(false);
         this._task = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this._task.numConditions)
         {
            _loc3_ = this._task.getCondition(_loc2_);
            _loc3_.killsChanged.add(this.onConditionChanged);
            _loc2_++;
         }
         color = 13175049;
         icon = new BmpIconSkull();
         label = Language.getInstance().getString("bounty.infected_bounty").toUpperCase();
         this.updateBountyRequirementList();
         this.updateProgressBar();
      }
      
      override public function dispose() : void
      {
         var _loc2_:InfectedBountyTaskCondition = null;
         super.dispose();
         var _loc1_:int = 0;
         while(_loc1_ < this._task.numConditions)
         {
            _loc2_ = this._task.getCondition(_loc1_);
            _loc2_.killsChanged.remove(this.onConditionChanged);
            _loc1_++;
         }
         this._task = null;
      }
      
      private function updateBountyRequirementList() : void
      {
         var _loc3_:InfectedBountyTaskCondition = null;
         var _loc4_:UIQuestTrackerItemRow = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc1_:int = headerWidth - 8;
         clearRequirementsList();
         var _loc2_:int = 0;
         while(_loc2_ < this._task.numConditions)
         {
            _loc3_ = this._task.getCondition(_loc2_);
            _loc4_ = addRequirementRow();
            _loc4_.spacing = -1;
            _loc5_ = Language.getInstance().getString("bounty.infected_task_kill_short",Language.getInstance().getString("zombie_types." + _loc3_.zombieType));
            _loc6_ = NumberFormatter.format(_loc3_.kills,0) + " / " + NumberFormatter.format(_loc3_.killsRequired,0);
            _loc7_ = _loc4_.addColumn("- " + _loc6_);
            _loc4_.addColumn("<b>" + _loc5_.toUpperCase() + "</b>",_loc1_ - _loc7_,10592673);
            _loc2_++;
         }
         updateRequirementsDisplay();
      }
      
      private function updateProgressBar() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:InfectedBountyTaskCondition = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._task.numConditions)
         {
            _loc5_ = this._task.getCondition(_loc3_);
            _loc1_ += _loc5_.killsRequired;
            _loc2_ += _loc5_.kills;
            _loc3_++;
         }
         var _loc4_:Number = Math.min(_loc2_ / _loc1_,1);
         setProgress(_loc4_);
      }
      
      private function onConditionChanged(param1:InfectedBountyTaskCondition) : void
      {
         this.updateProgressBar();
         this.updateBountyRequirementList();
      }
   }
}

