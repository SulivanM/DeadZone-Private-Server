package thelaststand.app.game.data.raid
{
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.assignment.AssignmentStageData;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.common.resources.ResourceManager;
   
   public class RaidData extends AssignmentData
   {
      
      private var _ptsPerSurvivor:int;
      
      private var _maxSurvivorMissionPoints:int;
      
      private var _points:int;
      
      public function RaidData()
      {
         super();
         _type = AssignmentType.Raid;
      }
      
      public function get pointsPerSurvivor() : int
      {
         return this._ptsPerSurvivor;
      }
      
      public function get maxSurvivorMissionPoints() : int
      {
         return this._maxSurvivorMissionPoints;
      }
      
      public function get points() : int
      {
         return this._points;
      }
      
      public function set points(param1:int) : void
      {
         this._points = param1;
      }
      
      public function getRaidStage(param1:int) : RaidStageData
      {
         return _stages[param1] as RaidStageData;
      }
      
      override protected function getCurrentRewardTier() : int
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc1_:int = -1;
         for each(_loc2_ in _xml.rewards.tier)
         {
            _loc3_ = int(_loc2_.@score);
            if(_loc3_ > this.points)
            {
               break;
            }
            _loc1_++;
         }
         return _loc1_;
      }
      
      override protected function onParse(param1:Object) : Boolean
      {
         this._points = int(param1.points);
         return true;
      }
      
      override protected function onSetXML(param1:XML) : Boolean
      {
         this._ptsPerSurvivor = Math.max(int(_xml.rp_survivor),0);
         _rewardTierCount = _xml.rewards.tier.length();
         this._maxSurvivorMissionPoints = _maxSurvivorCount * this._ptsPerSurvivor;
         return true;
      }
      
      override protected function createStageData(param1:int) : AssignmentStageData
      {
         return new RaidStageData(xml,param1,0,0);
      }
      
      override protected function getXmlNode(param1:String) : XML
      {
         var id:String = param1;
         return ResourceManager.getInstance().get("xml/raids.xml").raid.(@id == id)[0];
      }
   }
}

