package thelaststand.app.game.data.arena
{
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.assignment.AssignmentStageData;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.network.Network;
   import thelaststand.common.resources.ResourceManager;
   
   public class ArenaSession extends AssignmentData
   {
      
      private var _points:int;
      
      private var _state:Object;
      
      public function ArenaSession()
      {
         super();
         _type = AssignmentType.Arena;
         this._state = {"hp":{}};
      }
      
      public function get state() : Object
      {
         return this._state;
      }
      
      public function get points() : int
      {
         return this._points;
      }
      
      public function set points(param1:int) : void
      {
         this._points = param1;
      }
      
      public function getArenaStage(param1:int) : ArenaStageData
      {
         return _stages[param1] as ArenaStageData;
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
         this._state = param1.state;
         return true;
      }
      
      override protected function onSetXML(param1:XML) : Boolean
      {
         return true;
      }
      
      override protected function getXmlNode(param1:String) : XML
      {
         var id:String = param1;
         return ResourceManager.getInstance().get("xml/arenas.xml").arena.(@id == id)[0];
      }
      
      override protected function createStageData(param1:int) : AssignmentStageData
      {
         return new ArenaStageData(xml,param1,0);
      }
      
      public function getLaunchCost(param1:int) : int
      {
         var _loc2_:Object = Network.getInstance().data.costTable.getItemByKey("ArenaLaunch_" + name);
         var _loc3_:int = _loc2_.hasOwnProperty("round") ? int(_loc2_.round) : 1;
         var _loc4_:Number = Number(_loc2_.hasOwnProperty("lvlMultiplier") ? Number(_loc2_.lvlMultiplier) || 1 : 1);
         var _loc5_:int = Math.floor((param1 + 1) * _loc4_);
         return int(Math.ceil(_loc5_ / _loc3_) * _loc3_);
      }
   }
}

