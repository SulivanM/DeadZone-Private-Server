package thelaststand.app.game.data.assignment
{
   public class AssignmentStageData
   {
      
      private var _name:String;
      
      private var _index:int;
      
      private var _state:uint = 0;
      
      private var _level:int;
      
      private var _assignmentXML:XML;
      
      private var _stageXML:XML;
      
      private var _objectiveXML:XML;
      
      private var _missionTime:int;
      
      private var _languageNamePath:String;
      
      private var _survivorCount:int;
      
      public function AssignmentStageData(param1:XML, param2:int, param3:int)
      {
         super();
         this._assignmentXML = param1;
         this._index = param2;
         this._stageXML = param1.stage[param2];
         this._name = this._stageXML.@id.toString();
         this._languageNamePath = this.getLanguageNamePath().toLowerCase();
         this._missionTime = int(this._stageXML.time);
         this._survivorCount = 0;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get languageNamePath() : String
      {
         return this._languageNamePath;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get missionTime() : int
      {
         return this._missionTime;
      }
      
      public function get state() : uint
      {
         return this._state;
      }
      
      public function set state(param1:uint) : void
      {
         this._state = param1;
      }
      
      public function get survivorCount() : int
      {
         return this._survivorCount;
      }
      
      public function set survivorCount(param1:int) : void
      {
         this._survivorCount = param1;
      }
      
      public function get assignmentXml() : XML
      {
         return this._assignmentXML;
      }
      
      public function get stageXml() : XML
      {
         return this._stageXML;
      }
      
      public function parse(param1:Object) : void
      {
         this._level = int(param1.level);
         this._missionTime = int(param1.time);
         this._state = int(param1.state);
         this._survivorCount = int(param1.srvcount);
         this.onParse(param1);
      }
      
      protected function onParse(param1:Object) : void
      {
      }
      
      protected function getLanguageNamePath() : String
      {
         throw new Error("This method must be implemented by sub-classes");
      }
   }
}

