package thelaststand.app.game.data.arena
{
   import thelaststand.app.game.data.assignment.AssignmentStageData;
   
   public class ArenaStageData extends AssignmentStageData
   {
      
      private var _survivorPoints:int;
      
      private var _objectivePoints:int;
      
      public function ArenaStageData(param1:XML, param2:int, param3:int)
      {
         super(param1,param2,param3);
      }
      
      public function get survivorPoints() : int
      {
         return this._survivorPoints;
      }
      
      public function set survivorPoints(param1:int) : void
      {
         this._survivorPoints = param1;
      }
      
      public function get objectivePoints() : int
      {
         return this._objectivePoints;
      }
      
      public function set objectivePoints(param1:int) : void
      {
         this._objectivePoints = param1;
      }
      
      override protected function getLanguageNamePath() : String
      {
         var _loc1_:String = assignmentXml.@id.toString();
         return String("arena." + _loc1_ + ".stage_" + name);
      }
      
      override protected function onParse(param1:Object) : void
      {
         this._survivorPoints = int(param1.srvpoints);
         this._objectivePoints = int(param1.objpoints);
      }
   }
}

