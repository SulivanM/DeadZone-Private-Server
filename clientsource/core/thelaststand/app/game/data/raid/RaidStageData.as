package thelaststand.app.game.data.raid
{
   import thelaststand.app.game.data.assignment.AssignmentStageData;
   
   public class RaidStageData extends AssignmentStageData
   {
      
      private var _objectiveIndex:int;
      
      private var _objectiveState:uint = RaidStageObjectiveState.INCOMPLETE;
      
      private var _objectiveXML:XML;
      
      private var _imageURI:String;
      
      public function RaidStageData(param1:XML, param2:int, param3:int, param4:int)
      {
         super(param1,param2,param3);
         this.setMapAndObjective(param3,param4);
         this._imageURI = String("images/raids/" + param1.@id.toString() + "_" + name + ".jpg").toLowerCase();
      }
      
      public function get imageURI() : String
      {
         return this._imageURI;
      }
      
      public function get objectiveXML() : XML
      {
         return this._objectiveXML;
      }
      
      public function get objectiveState() : uint
      {
         return this._objectiveState;
      }
      
      public function set objectiveState(param1:uint) : void
      {
         this._objectiveState = param1;
      }
      
      public function get objectivePoints() : int
      {
         return this._objectiveXML != null ? int(this._objectiveXML.rp[0]) : 0;
      }
      
      override protected function onParse(param1:Object) : void
      {
         this.setMapAndObjective(int(param1.map),int(param1.obj));
      }
      
      override protected function getLanguageNamePath() : String
      {
         var _loc1_:String = assignmentXml.@id.toString();
         return String("raid." + _loc1_ + ".stage_" + name);
      }
      
      public function setMapAndObjective(param1:int, param2:int) : void
      {
         if(param2 <= -1)
         {
            return;
         }
         this._objectiveXML = stageXml.map[param1].objective[param2];
      }
   }
}

