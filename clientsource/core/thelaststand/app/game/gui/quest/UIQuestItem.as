package thelaststand.app.game.gui.quest
{
   import com.exileetiquette.utils.NumberFormatter;
   import thelaststand.app.game.data.quests.Quest;
   
   public class UIQuestItem extends UIQuestTrackerItem
   {
      
      private var _quest:Quest;
      
      public function UIQuestItem(param1:Quest)
      {
         super(false);
         this._quest = param1;
         this._quest.progressChanged.add(this.onProgressChanged);
         color = Quest.getColor(this._quest.type);
         icon = Quest.getIcon(this._quest.type);
         label = this._quest.getName().toUpperCase();
         this.updateQuestRequirementList();
         this.updateProgressBar();
      }
      
      public function get quest() : Quest
      {
         return this._quest;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._quest.progressChanged.remove(this.onProgressChanged);
         this._quest = null;
      }
      
      private function updateProgressBar() : void
      {
         var _loc1_:Number = this._quest == null ? 0 : Math.min(this._quest.getTotalProgress() / this._quest.getAllGoalsTotal(),1);
         setProgress(_loc1_);
      }
      
      private function updateQuestRequirementList() : void
      {
         var _loc1_:UIQuestTrackerItemRow = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc2_:int = headerWidth - 8;
         clearRequirementsList();
         var _loc3_:int = 0;
         var _loc4_:* = this._quest.xml.@stubOnly == "1";
         var _loc5_:String = this._quest.getShortDescription();
         if(_loc4_ || _loc5_ != "?" && _loc5_.length > 0)
         {
            _loc1_ = addRequirementRow();
            _loc1_.addColumn(_loc5_,_loc2_,10592673);
         }
         if(!_loc4_)
         {
            _loc6_ = this._quest.getNonItemResourceGoals().concat(this._quest.getItemResourceGoals());
            _loc6_.sortOn("total",Array.NUMERIC);
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc8_ = _loc6_[_loc7_];
               _loc9_ = NumberFormatter.format(_loc8_.prog,0) + " / " + NumberFormatter.format(_loc8_.total,0);
               _loc1_ = addRequirementRow();
               _loc1_.spacing = -1;
               _loc10_ = _loc1_.addColumn("- " + _loc9_);
               _loc1_.addColumn("<b>" + _loc8_.name.toUpperCase() + "</b>",_loc2_ - _loc10_,10592673);
               _loc7_++;
            }
         }
         updateRequirementsDisplay();
      }
      
      private function onProgressChanged(param1:Quest, param2:int, param3:int) : void
      {
         this.updateProgressBar();
         this.updateQuestRequirementList();
      }
   }
}

