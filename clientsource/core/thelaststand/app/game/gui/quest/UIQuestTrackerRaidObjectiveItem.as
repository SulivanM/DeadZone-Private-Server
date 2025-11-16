package thelaststand.app.game.gui.quest
{
   import com.exileetiquette.utils.NumberFormatter;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.gui.raid.RaidDialogue;
   import thelaststand.common.lang.Language;
   
   public class UIQuestTrackerRaidObjectiveItem extends UIQuestTrackerItem
   {
      
      private var _raid:RaidData;
      
      private var _missionData:MissionData;
      
      private var _objectives:Vector.<Object>;
      
      private var _langPath:String;
      
      public function UIQuestTrackerRaidObjectiveItem(param1:RaidData, param2:MissionData)
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         super(false);
         this._raid = param1;
         this._missionData = param2;
         color = RaidDialogue.COLOR;
         icon = new BmpIconSkull();
         label = Language.getInstance().getString("raid.raid_objective").toUpperCase();
         var _loc3_:XML = this._raid.getRaidStage(this._raid.currentStageIndex).objectiveXML;
         this._langPath = "raid." + this._raid.name + ".obj_" + _loc3_.lang.toString();
         this._objectives = new Vector.<Object>();
         for each(_loc4_ in _loc3_.trigger)
         {
            _loc5_ = _loc4_.@id.toString();
            _loc6_ = int(_loc4_);
            _loc7_ = {
               "id":_loc5_,
               "total":_loc6_,
               "count":0
            };
            this._objectives.push(_loc7_);
         }
         this._missionData.triggerActivated.add(this.onMissionTriggerActivated);
         this.updateObjectiveRequirementList();
         this.updateProgressBar();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._missionData.triggerActivated.remove(this.onMissionTriggerActivated);
         this._missionData = null;
         this._raid = null;
      }
      
      private function updateObjectiveRequirementList() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:Object = null;
         var _loc1_:int = headerWidth - 8;
         clearRequirementsList();
         var _loc2_:UIQuestTrackerItemRow = addRequirementRow();
         _loc2_.spacing = -1;
         var _loc5_:int = 0;
         while(_loc5_ < this._objectives.length)
         {
            _loc9_ = this._objectives[_loc5_];
            _loc3_ += _loc9_.total;
            _loc4_ += _loc9_.count;
            _loc5_++;
         }
         var _loc6_:String = Language.getInstance().getString(this._langPath);
         var _loc7_:String = NumberFormatter.format(_loc4_,0) + " / " + NumberFormatter.format(_loc3_,0);
         var _loc8_:int = _loc2_.addColumn("- " + _loc7_);
         _loc2_.addColumn("<b>" + Language.getInstance().getString("raid.objective_optional",_loc6_).toUpperCase() + "</b>",_loc1_ - _loc8_,10592673);
         updateRequirementsDisplay();
      }
      
      private function updateProgressBar() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._objectives.length)
         {
            _loc5_ = this._objectives[_loc3_];
            _loc1_ += _loc5_.total;
            _loc2_ += _loc5_.count;
            _loc3_++;
         }
         var _loc4_:Number = Math.min(_loc2_ / _loc1_,1);
         setProgress(_loc4_);
      }
      
      private function onMissionTriggerActivated(param1:String, param2:int) : void
      {
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._objectives.length)
         {
            _loc4_ = this._objectives[_loc3_];
            if(_loc4_.id == param1)
            {
               _loc4_.count = param2;
            }
            _loc3_++;
         }
         this.updateProgressBar();
         this.updateObjectiveRequirementList();
      }
   }
}

